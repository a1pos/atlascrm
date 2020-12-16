import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:atlascrm/services/api.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/services/ApiService.dart';

import 'package:atlascrm/components/shared/CustomAppBar.dart';

class StatementUploader extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map lead;

  StatementUploader(this.lead);

  @override
  _StatementUploaderState createState() => _StatementUploaderState();
}

class _StatementUploaderState extends State<StatementUploader> {
  static const platform = const MethodChannel('com.ces.atlascrm.channel');
  List<Asset> images = [];

  List imageFileList = [];
  List imageDLList = [];
  TextEditingController taskDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStatement();
    loadImages();
  }

  var isLoading = true;
  bool dirtyFlag = false;
  var uploadsComplete = false;
  var dio = Dio();
  var widgetType;
  var lead;
  var leadDocument;
  final picker = ImagePicker();
  var statementId;

  Future<void> loadStatement() async {
    lead = this.widget.lead;

    try {
      QueryOptions options = QueryOptions(documentNode: gql("""
        query GET_STATEMENT {
          statement(where: {lead: {_eq: "${lead["lead"]}"}}) {
            statement
            document
            leadByLead{
              document
            }
          }
        }
      """), fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await authGqlQuery(options);

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
                dirtyFlag = true;
              });
            }
          } else {
            setState(() {
              dirtyFlag = true;
            });
          }
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> createTask() async {
    var successMsg = "Task created!";
    var msgLength = Toast.LENGTH_SHORT;
    var taskEmployee = UserService.employee.employee;

    var openStatus;
    var rateReviewType;

    QueryOptions openStatusOptions = QueryOptions(documentNode: gql("""
      query TaskStatus {
        task_status {
          task_status
          document
          title
        }
      }
    """));

    QueryOptions rateReviewTypeOptions = QueryOptions(documentNode: gql("""
      query MyQuery(\$title: String) {
        task_type(where: {title: {_eq: \$title}}) {
          task_type
          title
        }
      }
    """), variables: {"title": "Rate Review Presentation"});

    final QueryResult result0 = await authGqlQuery(openStatusOptions);
    final QueryResult result1 = await authGqlQuery(rateReviewTypeOptions);

    if (result0 != null && result1 != null) {
      if (result0.hasException == false && result0.hasException == false) {
        //code to nab the task type

        result0.data["task_status"].forEach((item) {
          if (item["title"] == "Open") {
            openStatus = item["task_status"];
          }
        });

        rateReviewType = result1.data["task_type"][0]["task_type"];
      }
    } else {
      print(new Error());
      throw new Error();
    }
    var saveDate = DateTime.parse(taskDateController.text).toUtc();
    var saveDateFormat = DateFormat("yyyy-MM-dd HH:mm").format(saveDate);

    // var timeNow = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());

    Map data = {
      "task_status": openStatus,
      "task_type": rateReviewType,
      "priority": 2,
      "lead": lead["lead"],
      "employee": taskEmployee,
      "document": {
        "notes":
            "This is an automatically generated task for your rate review presentation at " +
                lead["document"]["businessName"],
        "title": "Present at " + lead["document"]["businessName"],
      },
      "date": saveDateFormat
    };

    try {
      MutationOptions options = MutationOptions(documentNode: gql("""
        mutation InsertTask(\$data: [task_insert_input!]! = {}) {
          insert_task(objects: \$data) {
            returning {
              task
            }
          }
        }
            """), variables: {"data": data});

      final QueryResult result = await authGqlMutate(options);

      if (result != null) {
        if (result.hasException == false) {
          Fluttertoast.showToast(
              msg: successMsg,
              toastLength: msgLength,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        print(new Error());
        throw new Error();
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(
          msg: "Failed to create task for employee!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> leaveCheck() async {
    if (!uploadsComplete && imageDLList.length > 0) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Unsent Statement!'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('You have an unsubmitted statement!'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                          ' Would you like to submit this statement before you leave?'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                          'Please enter the date and time you intend to present the rate review to this merchant'),
                    ),
                    DateTimeField(
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                      decoration: InputDecoration(
                          labelText: "Date to Present Rate Review"),
                      format: DateFormat("yyyy-MM-dd HH:mm"),
                      controller: taskDateController,
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now(),
                            ),
                          );
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          child: Text('Submit',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 17)),
                          onPressed: () {
                            if (taskDateController.text != "" &&
                                taskDateController.text != null) {
                              Navigator.pop(context);
                              uploadComplete();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please select a date/time!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.grey[600],
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          },
                        ),
                        FlatButton(
                          child: Text('Leave',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 17)),
                          onPressed: () {
                            Navigator.pushNamed(context, "/viewlead",
                                arguments: lead["lead"]);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            // actions: <Widget>[
            //   FlatButton(
            //     child: Text('Submit', style: TextStyle(fontSize: 17)),
            //     onPressed: () {

            //       Navigator.pop(context);
            //       uploadComplete();
            //     },
            //   ),
            //   FlatButton(
            //     child: Text('Leave',
            //         style: TextStyle(color: Colors.red, fontSize: 17)),
            //     onPressed: () {
            //       Navigator.pushNamed(context, "/viewlead",
            //           arguments: lead["lead"]);
            //     },
            //   ),
            // ],
          );
        },
      );
    } else {
      Navigator.pushNamed(context, "/viewlead", arguments: lead["lead"]);
      // Navigator.pop(context);
      return;
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
                Expanded(child: buildPhotoGallery(context, imgIndex))
              ])));
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

  Future<void> viewPdf(asset) async {
    await writeCounter(await fetchPost(asset["url"]));
    await existsFile();
    var midPath = (await _localFile).path;

    setState(() {
      path = midPath;
    });
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
      var resp = await this.widget.apiService.authDelete(context,
          "/api/upload/statement?lead=${lead["lead"]}&statement=$name", null);

      if (resp.statusCode == 200) {
        if (imageDLList.length == 1) {
          setState(() {
            dirtyFlag = false;
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
      QueryOptions options = QueryOptions(
          documentNode: gql("""
      query LEAD_PHOTOS(\$lead: uuid!) {
        lead_photos(lead: \$lead){
          photos
        }
      }
      """),
          variables: {"lead": lead["lead"]},
          fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await authGqlQuery(options);

      if (result.hasException == false) {
        if (result.data != null && result.data != "") {
          for (var imgUrl in result.data["lead_photos"]["photos"]) {
            print(imgUrl);
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
    setState(() {
      isLoading = false;
    });
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
        "to": [
          "jerrod.lumley@a1pos.com",
          "john.deluga@butlerbizsys.com",
          "ahrindo@gmail.com"
        ],
        "subject":
            "New Statement For Review: ${this.widget.lead["document"]["businessName"]} - ${this.widget.lead["document"]["address"]}",
        "html": 'Lead: ${this.widget.lead["document"]["businessName"]} <br />',
        "type": "STATEMENT",
        "statement": statementId
      });
      final QueryResult result = await authGqlMutate(mutateOptions);

      if (result.hasException == false) {
        if (result.data != null && result.data != "") {
          createTask();
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
          Navigator.pushNamed(context, "/viewlead", arguments: lead["lead"]);
        }
      }
    } catch (err) {
      print("ERROR LOOK AT THIS vvvvvvvvv");
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
          "/api/upload/statement?lead=${lead["lead"]}&employee=${UserService.employee.employee}",
          path);
      if (resp.statusCode == 200) {
        setState(() {
          statementId = resp.data["statement"];
          dirtyFlag = true;
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
    return WillPopScope(
      onWillPop: () async {
        leaveCheck();
        // Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: CustomAppBar(
              key: Key("viewTasksAppBar"),
              title: Text(isLoading
                  ? "Loading..."
                  : "Statements for: " + lead["document"]["businessName"]),
              action: <Widget>[]),
          body: isLoading
              ? CenteredLoadingSpinner()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: RawMaterialButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15.0),
                              fillColor: uploadsComplete
                                  ? Colors.grey
                                  : UniversalStyles.actionColor,
                              onPressed: uploadsComplete
                                  ? () {}
                                  : () async {
                                      var result = await platform
                                          .invokeMethod("openMedia");
                                      addImage(result);
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(15.0),
                            fillColor: uploadsComplete
                                ? Colors.grey
                                : UniversalStyles.actionColor,
                            onPressed: uploadsComplete
                                ? () {}
                                : () async {
                                    var result = await platform
                                        .invokeMethod("openCamera");
                                    addImage(result);
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: RawMaterialButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15.0),
                              fillColor: uploadsComplete
                                  ? Colors.grey
                                  : UniversalStyles.actionColor,
                              onPressed: uploadsComplete
                                  ? () {}
                                  : () async {
                                      var result = await FilePicker.getFilePath(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf']);
                                      addImage(result);
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text("Upload Statements",
                          style: TextStyle(fontSize: 20)),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: buildDLGridView(),
                    ),
                  ],
                )),
    );
  }
}