import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LeadNotes extends StatefulWidget {
  final Map object;

  LeadNotes(
    this.object,
  );

  @override
  _LeadNotesState createState() => _LeadNotesState();
}

bool isFocused = false;
bool isLoading = false;
bool notesEmpty = true;

List notes = [];
List notesDisplay = [];

var notesController = TextEditingController();
var typeUpper;
var type = "lead";

ScrollController _scrollController = ScrollController();

class _LeadNotesState extends State<LeadNotes> {
  FocusNode _focus = new FocusNode();

  @override
  void initState() {
    super.initState();
    typeUpper = type.toUpperCase();
    notesController.clear();
    loadNotes(this.widget.object[type]);

    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() async {
    super.dispose();
    isLoading = false;

    notesEmpty = true;
    notes = [];
  }

  void _onFocusChange() {
    setState(
      () {
        isFocused = _focus.hasFocus;
      },
    );
  }

  Future<void> loadNotes(objectId) async {
    notesController.clear();

    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_LEADS_NOTES (\$id: uuid!) {
        lead_note(
          where: {lead: {_eq: \$id}}
          order_by: {created_at: desc}
          ) {
            lead_note
            lead
            note_text
            document
            created_by
            created_at
            employee
            employeeByEmployee{
              displayName: document(path: "displayName")
            }
          }
      }
      """),
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      variables: {"id": objectId},
    );

    final result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var notesArrDecoded = result.data["lead_note"];
        if (notesArrDecoded != null) {
          var notesArr = List.from(notesArrDecoded);
          if (notesArr.length > 0) {
            setState(
              () {
                isLoading = false;
                notesEmpty = false;
                notes = notesArr;
              },
            );
          }
        }
      }
    }
  }

  Future<void> saveNote({type, objectId, newNote}) async {
    var sendNote = {
      "$type": objectId,
      "note_text": newNote,
    };

    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
     mutation INSERT_${typeUpper}_NOTE (\$object: ${type}_note_insert_input!){
      insert_${type}_note_one(object: \$object){
		    ${type}_note
      }
    }
      """),
      fetchPolicy: FetchPolicy.networkOnly,
      variables: {"object": sendNote},
    );

    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);
    if (result.hasException == true) {
      Fluttertoast.showToast(
          msg: result.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
    loadNotes(this.widget.object[type]);
  }

  @override
  Widget build(BuildContext context) {
    if (!notesEmpty) {
      notes.sort(
        (a, b) {
          var adate = a["created_at"];
          var bdate = b["created_at"];
          return -adate.compareTo(bdate);
        },
      );
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        bottomNavigationBar: Transform.translate(
          offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onEditingComplete: () {
                        saveNote(
                            type: type,
                            objectId: this.widget.object["lead"],
                            newNote: notesController.text);
                        notesController.text = "";
                      },
                      focusNode: _focus,
                      controller: notesController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: UniversalStyles.actionColor, width: 3.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        hintText: 'Additional Notes.',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (notesController.text == null ||
                          notesController.text == "") {
                        Fluttertoast.showToast(
                            msg: "Cannot add blank note!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[600],
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        saveNote(
                            type: type,
                            objectId: this.widget.object["lead"],
                            newNote: notesController.text);
                      }
                      notesController.text = "";
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        appBar: CustomAppBar(
            key: Key("viewTasksAppBar"),
            title: Text(isLoading
                ? "Loading..."
                : "Notes for: " +
                    this.widget.object["document"]["businessName"]),
            action: <Widget>[]),
        body: isLoading
            ? CenteredLoadingSpinner()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  !notesEmpty
                      ? Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom ==
                                            0
                                        ? 0
                                        : 70.0),
                            child: Scrollbar(
                              controller: _scrollController,
                              isAlwaysShown: true,
                              child: ListView(
                                reverse: true,
                                controller: _scrollController,
                                shrinkWrap: true,
                                children: notesDisplay = notes.map(
                                  (note) {
                                    var utcDate =
                                        DateTime.parse(note["created_at"]);
                                    var utcDatetime = DateTime.utc(
                                        utcDate.year,
                                        utcDate.month,
                                        utcDate.day,
                                        utcDate.hour,
                                        utcDate.minute,
                                        utcDate.second);
                                    var localDate = utcDatetime.toLocal();

                                    var viewDate = DateFormat("MM-dd-yyyy,")
                                        .add_jm()
                                        .format(localDate);
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Container(
                                          child: ListTile(
                                            title: note["note_text"] != null
                                                ? Text(note["note_text"],
                                                    style:
                                                        TextStyle(fontSize: 18))
                                                : Text(""),
                                            subtitle: Text(
                                              viewDate,
                                              style: TextStyle(
                                                  color: UniversalStyles
                                                      .actionColor,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                            child: Empty("No Notes"),
                          ),
                        )
                ],
              ),
      ),
    );
  }
}
