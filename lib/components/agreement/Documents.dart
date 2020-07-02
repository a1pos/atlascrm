import 'dart:async';
import 'dart:io';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class Documents extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map isDirtyStatus;
  final Map files;

  Documents({this.files, this.isDirtyStatus});

  @override
  DocumentsState createState() => DocumentsState();
}

class DocumentsState extends State<Documents> with TickerProviderStateMixin {
  static const platform = const MethodChannel('com.ces.atlascrm.channel');

  void initState() {
    super.initState();
  }

  var w9Check = false;
  var voidedCheck = false;

  void openImageUpload(title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload a $title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Take a new picture or upload from gallery?'),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: Color.fromARGB(500, 1, 224, 143),
              onPressed: () async {
                Navigator.pop(context);
                var result = await platform.invokeMethod("openCamera");
                addImage(result, title);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                  ),
                  Text(
                    'Take Picture',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: Color.fromARGB(500, 1, 224, 143),
              onPressed: () async {
                var result = await platform.invokeMethod("openMedia");
                addImage(result, title);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.collections,
                    color: Colors.white,
                  ),
                  Text(
                    'Gallery',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> addImage(path, title) async {
    // print("FILE URI: $path");
    // File file = File(path);
    // print(file);

    if (title == "W-9") {
      this.widget.files["file1"] = path;
    }
    if (title == "Voided Check") {
      this.widget.files["file2"] = path;
    }

    setState(() {
      this.widget.isDirtyStatus["documentsIsDirty"] = true;
    });

    // try {
    //   var resp = await this
    //       .widget
    //       .apiService
    //       .authFilePost(context, "/agreementbuilder/${this.widget}", path);
    //   if (resp.statusCode == 200) {
    //     // await loadLeadData(this.widget.leadId);
    //     Fluttertoast.showToast(
    //         msg: "Image Uploaded!",
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         backgroundColor: Colors.grey[600],
    //         textColor: Colors.white,
    //         fontSize: 16.0);
    //     setState(() {
    //       // imageDLList = [];
    //     });
    //     // loadImages();
    //   } else {
    //     Fluttertoast.showToast(
    //         msg: "Failed to upload image!",
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         backgroundColor: Colors.grey[600],
    //         textColor: Colors.white,
    //         fontSize: 16.0);
    //   }
    // } catch (err) {
    //   print(err);
    // }
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomCard(
              key: Key("documents1"),
              icon: Icons.save,
              title: "Documents",
              child: Column(
                children: <Widget>[
                  //PUT GET INFO ROWS HERE
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                            color: Color.fromARGB(500, 1, 224, 143),
                            onPressed: () {
                              openImageUpload("W-9");
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.check_box_outline_blank,
                                    color: Colors.white),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Text("W-9",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )),
                      ),
                      Text("File path will go here")
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                            color: Color.fromARGB(500, 1, 224, 143),
                            onPressed: () {
                              openImageUpload("Voided Check");
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.check_box_outline_blank,
                                    color: Colors.white),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Text("Voided Check",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )),
                      ),
                      Text("File path will go here")
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
