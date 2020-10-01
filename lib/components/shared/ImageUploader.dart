import 'package:atlascrm/components/shared/PlacesSuggestions.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:atlascrm/screens/leads/ViewLeadScreen.dart';
import 'package:atlascrm/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:http_parser/http_parser.dart';
import 'package:atlascrm/services/ApiService.dart';

import 'CustomAppBar.dart';

class ImageUploader extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String objectId;
  final String type;
  final Map loading;
  final LeadSaveController controller;
  final Map dirtyFlag;
  final Map infoDoc;
  ImageUploader(
      {this.type,
      this.objectId,
      this.loading,
      this.controller,
      this.dirtyFlag,
      this.infoDoc});

  @override
  _ImageUploaderState createState() => _ImageUploaderState(controller);
}

class _ImageUploaderState extends State<ImageUploader> {
  _ImageUploaderState(LeadSaveController controller) {
    controller.methodA = submitCheck;
  }

  static const platform = const MethodChannel('com.ces.atlascrm.channel');
  List<Asset> images = [];

  List imageFileList = [];
  List imageDLList = [];
  String _error = 'No Error Dectected';
  @override
  void initState() {
    super.initState();
    loadStatement();
    loadImages();
  }

  var isLoading = false;

  var uploadsComplete = false;
  var dio = Dio();
  var widgetType;
  var objectId;
  var leadDocument;
  final picker = ImagePicker();
  var statementId;

  Future<void> loadStatement() async {
    widgetType = this.widget.type;
    objectId = this.widget.objectId;

    try {
      QueryOptions options = QueryOptions(documentNode: gql("""
        query GetStatement {
          statement(where: {lead: {_eq: "$objectId"}}) {
            statement
            document
            leadByLead{
              document
            }
          }
        }
      """), fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await client.query(options);

      if (result.hasException == false) {
        if (result.data != null && result.data != "") {
          setState(() {
            statementId = result.data["statement"][0]["statement"];
          });
          if (result.data["statement"][0]["document"] != null) {
            if (result.data["statement"][0]["document"]["emailSent"] != null) {
              setState(() {
                uploadsComplete = true;
              });
            } else {
              setState(() {
                this.widget.dirtyFlag["flag"].text = "true";
              });
            }
          } else {
            setState(() {
              this.widget.dirtyFlag["flag"].text = "true";
            });
          }
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> dirtyCheck() async {
    if (imageDLList.length < 0) {}
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
                Text('Take a new picture, upload from gallery, or upload PDF?'),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              padding: EdgeInsets.all(5),
              color: UniversalStyles.actionColor,
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
              color: UniversalStyles.actionColor,
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
              color: UniversalStyles.actionColor,
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

  Future<void> submitCheck() async {
    if (uploadsComplete || imageDLList.length == 0) {
      return;
    } else {
      setState(() {
        this.widget.dirtyFlag["flag"].text = "false";
      });
      uploadComplete();

      // return showDialog<void>(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('Submit Statement?'),
      //       content: SingleChildScrollView(
      //         child: ListBody(
      //           children: <Widget>[
      //             Text('This will submit your statement to be reviewed. '),
      //             Padding(
      //               padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      //               child: Text(
      //                   'After this statement is submitted you cannot add any more files to it.'),
      //             ),
      //           ],
      //         ),
      //       ),
      //       actions: <Widget>[
      //         FlatButton(
      //           child: Text('Submit', style: TextStyle(fontSize: 17)),
      //           onPressed: () {
      //             uploadComplete();
      //             Navigator.pop(context);
      //           },
      //         ),
      //         FlatButton(
      //           child: Text('Cancel', style: TextStyle(color: Colors.red)),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  var currentImage;
  Future<void> viewImage(asset, imgIndex) async {
    // var newPath = asset. ;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              appBar: CustomAppBar(
                title: Text("Viewing Image"),
                action: <Widget>[
                  uploadsComplete
                      ? Container()
                      : MaterialButton(
                          padding: EdgeInsets.all(5),
                          color: Colors.red,
                          // color: Colors.grey[300],
                          onPressed: () {
                            deleteCheck(currentImage);
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
              ),
              body: Center(
                  child: Column(children: <Widget>[
                Expanded(child: buildPhotoGallery(context, imgIndex)

                    // PhotoView(imageProvider: NetworkImage(asset["url"])),
                    )
              ])));
          // return AlertDialog(
          //   title: Text('View Statement'),
          //   content: SingleChildScrollView(
          //     child: ListBody(
          //       children: <Widget>[
          //         Container(
          //             child:
          //                 PhotoView(imageProvider: NetworkImage(asset["url"])))
          //       ],
          //     ),
          //   ),
          //   actions: <Widget>[
          //     MaterialButton(
          //       padding: EdgeInsets.all(5),
          //       color: Colors.red,
          //       // color: Colors.grey[300],
          //       onPressed: () {
          //         Navigator.pop(context);
          //         deleteCheck(asset);
          //       },
          //       child: Row(
          //         children: <Widget>[
          //           Icon(
          //             Icons.clear,
          //             color: Colors.white,
          //           ),
          //           Text(
          //             'Delete',
          //             style: TextStyle(
          //               color: Colors.white,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // );
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
          return Scaffold(
              appBar: CustomAppBar(
                title: Text("Viewing PDF"),
                action: <Widget>[
                  uploadsComplete
                      ? Container()
                      : MaterialButton(
                          padding: EdgeInsets.all(5),
                          color: Colors.red,
                          // color: Colors.grey[300],
                          onPressed: () {
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
              ),
              body: Center(
                  child: Column(children: <Widget>[
                Expanded(
                  child: PDFView(filePath: path),
                )
              ])));
          // return AlertDialog(
          //   title: Text('View Statement'),
          //   content: SingleChildScrollView(
          //     child: ListBody(
          //       children: <Widget>[
          //         Container(
          //             height: 500, width: 800, child: PDFView(filePath: path))
          //       ],
          //     ),
          //   ),
          //   actions: <Widget>[
          //     MaterialButton(
          //       padding: EdgeInsets.all(5),
          //       color: Colors.red,
          //       // color: Colors.grey[300],
          //       onPressed: () {
          //         Navigator.pop(context);
          //         deleteCheck(asset);
          //       },
          //       child: Row(
          //         children: <Widget>[
          //           Icon(
          //             Icons.clear,
          //             color: Colors.white,
          //           ),
          //           Text(
          //             'Delete',
          //             style: TextStyle(
          //               color: Colors.white,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // );
        });
  }

  List galleryImages = [];

  Widget buildPhotoGallery(BuildContext context, page) {
    PageController pageController = PageController(initialPage: page);

    return Container(
        child: PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(galleryImages[index]["url"]),
          initialScale: PhotoViewComputedScale.contained * 0.8,
          // heroAttributes: HeroAttributes(tag: "image $index"),
        );
      },
      itemCount: galleryImages.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
      // backgroundDecoration: widget.backgroundDecoration,
      pageController: pageController,
      onPageChanged: (newVal) {
        setState(() {
          currentImage = galleryImages[newVal];
        });
      },
    ));
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
                setState(() {
                  galleryImages = [];
                  currentImage = imgFile;
                });
                for (var item in imageDLList) {
                  var stringLen = item["url"].length;
                  var extendo = item["url"].substring(stringLen - 3, stringLen);
                  if (extendo != "pdf") {
                    galleryImages.add(item);
                  }
                }
                var imgIndex = galleryImages.indexOf(imgFile);
                viewImage(imgFile, imgIndex);
              }
            },
            child: extendo == "pdf"
                ? Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: FractionalOffset.topCenter,
                      image: AssetImage("assets/pdf_thumbnail.png"),
                    )),
                  )
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
    Navigator.pop(context);
    try {
      var resp = await this.widget.apiService.authDelete(
          context,
          "/api/upload/statement?lead=${this.widget.objectId}&statement=$name",
          null);

      if (resp.statusCode == 200) {
        if (imageDLList.length == 1) {
          setState(() {
            this.widget.dirtyFlag["flag"].text = "false";
          });
        }
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
      //ORIGINAL REQUEST
      // var resp = await this
      //     .widget
      //     .apiService
      //     .authGet(context, "/api/upload/statement?lead=$objectId");
      QueryOptions options = QueryOptions(
          documentNode: gql("""
      query LEAD_PHOTOS(\$lead: uuid!) {
        lead_photos(lead: \$lead){
          photos
        }
      }
      """),
          variables: {"lead": objectId},
          fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await client.query(options);

      if (result.hasException == false) {
        if (result.data != null && result.data != "") {
          for (var imgUrl in result.data["lead_photos"]["photos"]) {
            print(imgUrl);
            // var url = "a1/uploads/statement_photos/$imgUrl";
            var url =
                "${ConfigSettings.HOOK_API_URL}/uploads/statement/$imgUrl";
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

  Future<void> uploadComplete() async {
    try {
      setState(() {
        isLoading = true;
      });

      MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
        mutation SEND_EMAIL(\$to:[String]!, \$subject:String!, \$html:String!, \$type:String!, \$statement:String!){
          email_statement(to:\$to, subject:\$subject, html:\$html, type:\$type, statement:\$statement){
            email_status
          }
        }
        """), variables: {
        "to": ["joe.pounds@a1pos.com"],
        // "to": ["jerrod.lumley@a1pos.com", "john.deluga@butlerbizsys.com", "andrew.hrindo@butlerbizsys.com"],
        "subject":
            "New Statement For Review: ${this.widget.infoDoc["businessName"]} - ${this.widget.infoDoc["address"]}",
        "html":
            'Lead: ${this.widget.infoDoc["businessName"]} <br /> <a href="">Click Here for Rate Review Tool</a>',
        "type": "STATEMENT",
        "statement": statementId
      });
      final QueryResult result = await client.mutate(mutateOptions);

      if (result.hasException == false) {
        if (result.data != null && result.data != "") {
          setState(() {
            uploadsComplete = true;
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Statement Submited!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Failed to complete upload!",
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
          "/api/upload/statement?lead=$objectId&employee=${UserService.employee.employee}",
          path);
      if (resp.statusCode == 200) {
        setState(() {
          this.widget.dirtyFlag["flag"].text = "true";
        });
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
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
        key: Key("leads5"),
        title: "Statement Uploads",
        icon: Icons.file_upload,
        child: isLoading
            ? CenteredLoadingSpinner()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        // padding: EdgeInsets.all(5),
                        color: uploadsComplete
                            ? Colors.grey
                            : UniversalStyles.actionColor,
                        onPressed: uploadsComplete ? () {} : openImageUpload,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.file_upload,
                              color: Colors.white,
                            ),
                            Text(
                              'Upload Files',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: MaterialButton(
                      //     padding: EdgeInsets.all(5),
                      //     color: uploadsComplete || imageDLList.length == 0
                      //         ? Colors.grey
                      //         : UniversalStyles.actionColor,
                      //     onPressed: uploadsComplete || imageDLList.length == 0
                      //         ? () {}
                      //         : submitCheck,
                      //     child: Row(
                      //       children: <Widget>[
                      //         Icon(
                      //           Icons.done,
                      //           color: Colors.white,
                      //         ),
                      //         Text(
                      //           'Submit Statement',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: buildDLGridView(),
                  ),
                ],
              ));
  }
}
