import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;

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
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: Color.fromARGB(500, 1, 224, 143),
              onPressed: () async {
                var result = await FilePicker.getFilePath(
                    type: FileType.custom, allowedExtensions: ['pdf']);
                addImage(result);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.insert_drive_file,
                    color: Colors.white,
                  ),
                  Text(
                    'PDF',
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
                  Navigator.pop(context);
                  deleteCheck(asset);
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

  String path;
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/test.pdf');
  }

  Future<File> writeCounter(Uint8List stream) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsBytes(stream);
  }

  Future<bool> existsFile() async {
    final file = await _localFile;
    return file.exists();
  }

  Future<Uint8List> fetchPost(getUrl) async {
    final response = await http.get(getUrl);
    final responseJson = response.bodyBytes;

    return responseJson;
  }

  // void loadPdf(getUrl) async {
  //   await writeCounter(await fetchPost(getUrl));
  //   await existsFile();
  //   var midPath = (await _localFile).path;

  //   setState(() {
  //     path = midPath;
  //   });

  //   if (!mounted) return;
  // }

  Future<void> viewPdf(asset) async {
    // var newPath = asset. ;

    // loadPdf();
    await writeCounter(await fetchPost(asset["url"]));
    await existsFile();
    var midPath = (await _localFile).path;

    setState(() {
      path = midPath;
    });
    // Navigator.pop(context);
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return Scaffold(
          //     appBar: AppBar(title: Text("Viewing PDF")),
          //     body: Center(
          //         child: Column(children: <Widget>[
          //       Container(
          //         height: 500,
          //         child: PDFView(filePath: path),
          //       )
          //     ])));
          return AlertDialog(
            title: Text('View Statement'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                      height: 500, width: 800, child: PDFView(filePath: path))
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                padding: EdgeInsets.all(5),
                color: Colors.red,
                // color: Colors.grey[300],
                onPressed: () {
                  Navigator.pop(context);
                  deleteCheck(asset);
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
        var stringLen = imgFile["url"].length;
        var extendo = imgFile["url"].substring(stringLen - 3, stringLen);
        return GestureDetector(
            onTap: () {
              if (extendo == "pdf") {
                viewPdf(
                  imgFile,
                );
              } else {
                viewImage(
                  imgFile,
                );
              }
            },
            child: extendo == "pdf"
                ? Icon(Icons.picture_as_pdf, size: 100)
                : Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: FractionalOffset.topCenter,
                      image: NetworkImage(imgFile["url"]),
                    )),
                  ));
      }),
    );
  }

  Future<void> deleteImage(asset) async {
    var name = asset["name"];
    Navigator.pop(context);

    try {
      var resp = await this.widget.apiService.authDelete(
          context, "/lead/${this.widget.objectId}/statement/$name", null);

      if (resp.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "File Deleted!",
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

  Future<void> deleteCheck(asset) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete this file'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                deleteImage(asset);
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            msg: "File Uploaded!",
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
            msg: "Failed to upload file!",
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
