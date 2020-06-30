import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:path_provider/path_provider.dart';

class ImageUploader extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String objectId;
  final String type;
  ImageUploader({this.type, this.objectId});

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

bool isFocused = false;
var notesController = TextEditingController();
List notes;
List notesDisplay;
var notesEmpty = true;

class _ImageUploaderState extends State<ImageUploader> {
  static const platform = const MethodChannel('com.ces.atlascrm.channel');
  List<Asset> images = [];

  List imageFileList = [];
  List imageDLList = [];
  String _error = 'No Error Dectected';
  @override
  void initState() {
    super.initState();
    loadImages();
  }

  var dio = Dio();

  var _image;
  final picker = ImagePicker();

  void openImageUpload() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload a Statement'),
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
                addImage(result);
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
                addImage(result);
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

  Future<void> imageResult(image) async {
    try {
      var resp = await this.widget.apiService.authFilePost(
          context,
          "/employee/${UserService.employee.employee}/${this.widget.objectId}/${this.widget.type}",
          _image);

      if (resp.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Image Uploaded!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Failed to upload statement!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (err) {
      print(err);
    }
  }

  //started working on downloads

  // void showDownloadProgress(received, total) {
  //   if (total != -1) {
  //     print((received / total * 100).toStringAsFixed(0) + "%");
  //   }
  // }

  // Future download2(Dio dio, String url, String savePath) async {
  //   try {
  //     Response response = await dio.get(
  //       url,
  //       onReceiveProgress: showDownloadProgress,
  //       //Received data with List<int>
  //       options: Options(
  //           responseType: ResponseType.bytes,
  //           followRedirects: false,
  //           validateStatus: (status) {
  //             return status < 500;
  //           }),
  //     );
  //     print(response.headers);
  //     File file = File(savePath);
  //     var raf = file.openSync(mode: FileMode.write);
  //     // response.data is List<int> type
  //     raf.writeFromSync(response.data);
  //     await raf.close();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> viewImage(asset) async {
    // var newPath = asset. ;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('View Statement'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Image.network(asset["url"])],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                padding: EdgeInsets.all(5),
                color: Colors.red,
                // color: Colors.grey[300],
                onPressed: () {
                  deleteImage(asset);
                  Navigator.pop(context);
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget buildDLGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(imageDLList.length, (index) {
        Map imgFile = imageDLList[index];

        return GestureDetector(
            onTap: () {
              viewImage(
                imgFile,
              );
            },
            child: Container(
              height: 300,
              width: 300,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.topCenter,
                image: new NetworkImage(imgFile["url"]),
              )),
            ));
      }),
    );
  }

  Future<void> deleteImage(asset) async {
    var name = asset["name"];
    try {
      var resp = await this.widget.apiService.authDelete(
          context, "/lead/${this.widget.objectId}/statement/$name", null);

      if (resp.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Image Deleted!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          imageDLList = [];
        });
        loadImages();
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(
          msg: "Failed to delete image!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  var loadedImage;

  Future<void> loadImages() async {
    try {
      var resp = await this
          .widget
          .apiService
          .authGet(context, "/lead/${this.widget.objectId}/statement");

      if (resp.statusCode == 200) {
        if (resp.data != null && resp.data != "") {
          for (var imgUrl in resp.data) {
            var url =
                "${ConfigSettings.API_URL}_a1/uploads/statement_photos/$imgUrl";
            setState(() {
              imageDLList.add({"name": imgUrl, "url": url});
            });
          }
          print(imageDLList);
        }
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(
          msg: "Failed to download images!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> addImage(path) async {
    // Uri fileUri = Uri.parse(path);
    // File newFile = File.fromUri(fileUri);
    print("FILE URI: $path");

    try {
      var resp = await this.widget.apiService.authFilePost(
          context,
          "/employee/${UserService.employee.employee}/${this.widget.objectId}/${this.widget.type}",
          path);
      if (resp.statusCode == 200) {
        // await loadLeadData(this.widget.leadId);
        Fluttertoast.showToast(
            msg: "Image Uploaded!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          imageDLList = [];
        });
        loadImages();
      } else {
        Fluttertoast.showToast(
            msg: "Failed to upload image!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (err) {
      print(err);
    }
    // newFile.delete();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
        key: Key("leads5"),
        title: "Statement Uploads",
        icon: Icons.file_upload,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 15),
              child: MaterialButton(
                padding: EdgeInsets.all(5),
                color: Color.fromARGB(500, 1, 224, 143),
                onPressed: openImageUpload,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.file_upload,
                      color: Colors.white,
                    ),
                    Text(
                      'Upload images',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: buildDLGridView(),
            ),
          ],
        ));
  }
}
