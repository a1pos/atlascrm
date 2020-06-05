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
  String _error = 'No Error Dectected';
  @override
  void initState() {
    super.initState();
  }

  var _image;
  final picker = ImagePicker();

  Future<File> writeToFile(ByteData data) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        tempPath + '/file_01.tmp'; // file_01.tmp is dump file, can be anything
    return new File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

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
              // color: Colors.grey[300],
              onPressed: () async {
                // return null;
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
              // color: Colors.grey[300],
              onPressed: () async {
                // Navigator.pop(context);
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

  Future getImage(method) async {
    PickedFile pickedFile;
    if (method == "gallery") {
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    } else if (method == "camera") {
      pickedFile = await picker.getImage(source: ImageSource.camera);
    } else {
      return print("no method specified");
    }

    setState(() {
      _image = pickedFile.path;
    });
    imageResult(_image);
  }

  Future<void> imageResult(image) async {
    try {
      // File fileImage = File(image.path);
      // String imgPath = Uri.encodeComponent(image.path);
      // var bytes = fileImage.file.readAsBytesSync();
      var resp = await this.widget.apiService.authFilePost(
          context,
          "/employee/${UserService.employee.employee}/${this.widget.objectId}/statement",
          _image);
      if (resp.statusCode == 200) {
        // await loadLeadData(this.widget.leadId);

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

  Future<void> viewImage(asset) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('View Statement'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[asset],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                padding: EdgeInsets.all(5),
                color: Color.fromARGB(500, 1, 224, 143),
                // color: Colors.grey[300],
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.file_download,
                      color: Colors.white,
                    ),
                    Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                padding: EdgeInsets.all(5),
                color: Colors.red,
                // color: Colors.grey[300],
                onPressed: () {
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

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(imageFileList.length, (index) {
        // Asset asset = images[index];
        File imgFile = imageFileList[index];
        print(imgFile.path);
        return GestureDetector(
          onTap: () {
            viewImage(
              Image.file(imgFile),

              //   AssetThumb(
              //   asset: asset,
              //   width: asset.originalWidth,
              //   height: asset.originalHeight,
              // )
            );
          },
          child: Image.file(imgFile, width: 300, height: 300),
          //     AssetThumb(
          //   asset: asset,
          //   width: 300,
          //   height: 300,
          // ),
        );
      }),
    );
  }

  Future<void> addImage(path) async {
    print(path);
    Uri fileUri = Uri.parse(path);
    //LOGIC TO SAVE IMAGE TO SERVER GOES HERE
    File newFile = File.fromUri(fileUri);
    print(newFile);
    setState(() {
      imageFileList.add(newFile);
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;

    for (var img in resultList) {
      var currentImg = await img.getByteData();

      final buffer = currentImg.buffer;
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      var filePath = tempPath + '/${img.name}';
      //LOGIC TO SAVE IMAGE TO SERVER GOES HERE
      var newFile = await File(filePath).writeAsBytes(buffer.asUint8List(
          currentImg.offsetInBytes, currentImg.lengthInBytes));
      setState(() {
        imageFileList.add(newFile);
      });
    }
    // setState(() {
    //   images += resultList;
    //   _error = error;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
        key: Key("leads5"),
        title: "Uploads",
        icon: Icons.file_upload,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MaterialButton(
                child: Text("button here"),
                onPressed: () {
                  openImageUpload();
                }),
            Center(child: Text('Error: $_error')),
            RaisedButton(
              child: Text("Pick images"),
              onPressed: loadAssets,
            ),
            Flexible(
              fit: FlexFit.loose,
              child: buildGridView(),
            )
          ],
        ));
  }
}
