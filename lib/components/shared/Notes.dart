import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Notes extends StatefulWidget {
  final String object;
  final String type;

  Notes({
    this.type,
    this.object,
  });

  @override
  _NotesState createState() => _NotesState();
}

bool isFocused = false;
var notesController = TextEditingController();
List notes;
List notesDisplay;
var notesEmpty = true;
var typeUpper;

class _NotesState extends State<Notes> {
  FocusNode _focus = new FocusNode();
  @override
  void initState() {
    super.initState();
    typeUpper = this.widget.type.toUpperCase();
    notesController.clear();
    loadNotes(this.widget.object, this.widget.type);
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    debugPrint("Focus: " + _focus.hasFocus.toString());
    setState(() {
      isFocused = _focus.hasFocus;
    });
  }

  Future<void> loadNotes(objectId, type) async {
    notesController.clear();

    Operation options =
        Operation(operationName: "${typeUpper}_NOTE", documentNode: gql("""
          subscription ${typeUpper}_NOTE(\$id: uuid) {
            ${type}_note(where: {$type: {_eq: \$id}}){
              ${type}_note
              note_text
              created_at
            }
          }
    """), variables: {"id": "$objectId"});
    var result = client.subscribe(options);
    result.listen(
      (data) async {
        var notesArrDecoded = data.data["${type}_note"];
        if (notesArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              notes = notesArrDecoded.toList();
              notesEmpty = false;
            });
          }
        }
      },
      onError: (error) {
        print(error);

        Fluttertoast.showToast(
            msg: "Failed to load Notes!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  Future<void> saveNote({type, object, newNote}) async {
    var sendNote = {
      "$type": this.widget.object,
      "note_text": newNote,
    };

    MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
     mutation INSERT_${typeUpper}_NOTE (\$object: ${type}_note_insert_input!){
      insert_${type}_note_one(object: \$object){
		    ${type}_note
      }
    }
      """), variables: {"object": sendNote});
    final QueryResult result = await client.mutate(mutateOptions);
    if (result.hasException == true) {
      Fluttertoast.showToast(
          msg: result.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Widget build(BuildContext context) {
    if (!notesEmpty) {
      notes.sort((a, b) {
        var adate = a["created_at"];
        var bdate = b["created_at"];
        return -adate.compareTo(bdate);
      });
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: TextField(
              onEditingComplete: () {
                saveNote(
                    type: this.widget.type,
                    object: this.widget.object,
                    newNote: notesController.text);
                notesController.text = "";
              },
              focusNode: _focus,
              controller: notesController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent, width: 3.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.5),
                ),
                hintText: 'Additional Notes.',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (notesController.text == null || notesController.text == "") {
                Fluttertoast.showToast(
                    msg: "Cannot add blank note!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey[600],
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else {
                saveNote(
                    type: this.widget.type,
                    object: this.widget.object,
                    newNote: notesController.text);
              }
              notesController.text = "";
            },
          )
        ]),
        !notesEmpty
            ? Column(
                children: notesDisplay = notes.map((note) {
                  var utcDate = DateTime.parse(note["created_at"]);
                  var utcDatetime = DateTime.utc(
                      utcDate.year,
                      utcDate.month,
                      utcDate.day,
                      utcDate.hour,
                      utcDate.minute,
                      utcDate.second);
                  var localDate = utcDatetime.toLocal();

                  var viewDate =
                      DateFormat("MM-dd-yyyy,").add_jm().format(localDate);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Container(
                            child: ListTile(
                                title: note["note_text"] != null
                                    ? Text(note["note_text"])
                                    : Text(""),
                                subtitle: Text(viewDate,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10))))),
                  );
                }).toList(),
              )
            : Empty("no notes"),
      ],
    );
  }
}
