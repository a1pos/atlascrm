import 'package:flutter/material.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/Empty.dart';

class Notes extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String object;
  final String type;

  Notes({
    this.type,
    this.object,
  });

  @override
  _NotesState createState() => _NotesState();
}

var notesController = TextEditingController();
List notes;
List notesDisplay;
var notesEmpty = true;

class _NotesState extends State<Notes> {
  @override
  void initState() {
    super.initState();
    loadNotes(this.widget.object, this.widget.type);
  }

  Future<void> loadNotes(objectId, type) async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/" + type + "/" + objectId + "/note");

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          notes = bodyDecoded.toList();
          notesEmpty = false;
        });
      }
    }
  }

  Future<void> saveNote({type, object, newNote}) async {
    var sendNote = {"text": newNote};
    var resp = await this
        .widget
        .apiService
        .authPost(context, "/" + type + "/" + object + "/note", sendNote);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        setState(() {
          loadNotes(object, type);
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: TextField(
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
              saveNote(
                  type: this.widget.type,
                  object: this.widget.object,
                  newNote: notesController.text);
              notesController.text = "";
            },
          )
        ]),
        !notesEmpty
            ? Column(
                children: notesDisplay = notes.map((note) {
                  var viewDate = DateFormat("yyyy-MM-dd HH:mm")
                      .add_jm()
                      .format(DateTime.parse(note["created_at"]));
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Container(
                            child: ListTile(
                                title: Text(note["note_text"]),
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
