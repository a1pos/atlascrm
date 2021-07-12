import 'package:round2crm/components/shared/EmployeeDropDown.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/config/ConfigSettings.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/services/ApiService.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:round2crm/components/shared/CustomAppBar.dart';

class StatementUploader extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map lead;

  StatementUploader(this.lead);

  @override
  _StatementUploaderState createState() => _StatementUploaderState();
}

class _StatementUploaderState extends State<StatementUploader> {
  final picker = ImagePicker();
  static const platform = const MethodChannel('com.ces.round2crm.channel');

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  bool isLoading = true;
  bool isBoarded;
  bool dirtyFlag = false;
  bool emailSent = false;
  bool prompt = false;
  bool uploadsComplete = false;
  bool inactiveSelected = false;
  bool statementActive = false;

  List<Asset> images = [];
  List imageFileList = [];
  List imageDLList = [];
  List statements = [];

  TextEditingController taskDateController = TextEditingController();

  var statementEmployee = UserService.employee.employee;

  var widgetType;
  var lead;
  var status;
  var leadStatus;
  var leadDocument;
  var statementId;
  var activeStatement;
  var dropdownValue;
  var activeValueString;
  var saveDateFormat;
  var parentCompany;

  @override
  void initState() {
    super.initState();
    isBoarded = false;
    checkIfBoarded(this.widget.lead["lead_status"]);
    loadStatements();
  }

  Future<void> loadStatements() async {
    lead = this.widget.lead;

    try {
      QueryOptions options = QueryOptions(
        document: gql("""
        query GET_STATEMENTS_FROM_LEAD {
          statement(where: {lead: {_eq: "${lead["lead"]}"}}) {
            employee
            statement
            document
            is_active
            created_at
            leadByLead{
              document
            }
            employeeByEmployee{
              document
            }
          }
        }
      """),
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result.hasException == false) {
        logger.i("Statement data loaded");
        if (result.data != null) {
          var statementsArrDecoded = result.data["statement"];

          if (statementsArrDecoded != null) {
            var statementsArr = List.from(statementsArrDecoded);
            if (statementsArr.length > 0) {
              statements = statementsArr;

              activeStatement = statements
                  .where((element) => element["is_active"] == true)
                  .toList();

              if (activeStatement.length > 0) {
                dropdownValue = activeStatement[0]["statement"] ?? null;
                statementId = activeStatement[0]["statement"];

                setState(() {
                  statementActive = true;
                  isLoading = false;
                  loadImages();
                });
                if (activeStatement[0]["document"] != null) {
                  statementEmployee = activeStatement[0]["employee"];
                  if (activeStatement[0]["document"]["emailSent"] != null) {
                    setState(
                      () {
                        emailSent = true;
                        uploadsComplete = true;
                      },
                    );
                  }
                }
              } else {
                if (UserService.employee.role == "sa" ||
                    UserService.employee.role == "salesmanager") {
                  loadImages();
                  dropdownValue = statements[0]["statement"] ?? null;
                  inactiveSelected = true;
                }
                statementActive = false;
                emailSent = true;
                setState(() {
                  isLoading = false;
                });
              }
            } else {
              setState(() {
                isLoading = false;
                activeStatement = [];
                statements = [];
                dropdownValue = null;
              });
            }
          }
        }
      } else {
        debugPrint("Error getting statement information: " +
            result.exception.toString());
        logger.e("Error getting statement information: " +
            result.exception.toString());
      }
    } catch (err) {
      debugPrint("Error getting statement information: " + err.toString());
      logger.e("Error getting statement information: " + err.toString());
    }
  }

  Future<void> checkIfBoarded(status) async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query LEAD_STATUS {
        lead_status {
          lead_status
          text
        }
      }

    """),
      fetchPolicy: FetchPolicy.noCache,
    );

    final result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        result.data["lead_status"].forEach((item) {
          if (item["text"] == "Boarded") {
            leadStatus = item["lead_status"];
          }
        });

        if (leadStatus == status) {
          isBoarded = true;
          logger.i("Lead is boarded");
        }
      } else {
        debugPrint(
            "Error checking if lead boarded: " + result.exception.toString());
        logger.e(
            "Error checking if lead boarded: " + result.exception.toString());
      }
    }
  }

  Future<void> createTask() async {
    var successMsg = "Task created!";
    var msgLength = Toast.LENGTH_SHORT;
    var taskEmployee = UserService.employee.employee;
    var openStatus;
    var rateReviewType;

    QueryOptions openStatusOptions = QueryOptions(
      document: gql("""
      query TASK_STATUS {
        task_status {
          task_status
          document
          title
        }
      }
    """),
    );

    QueryOptions rateReviewTypeOptions = QueryOptions(
      document: gql("""
      query TASK_TYPES(\$title: String) {
        task_type(where: {title: {_eq: \$title}}) {
          task_type
          title
        }
      }
    """),
      variables: {"title": "Rate Review Presentation"},
    );

    final QueryResult result0 =
        await GqlClientFactory().authGqlquery(openStatusOptions);
    final QueryResult result1 =
        await GqlClientFactory().authGqlquery(rateReviewTypeOptions);

    if (result0 != null && result1 != null) {
      if (result0.hasException == false && result0.hasException == false) {
        logger.i("Task status and type loaded");
        result0.data["task_status"].forEach(
          (item) {
            if (item["title"] == "Open") {
              openStatus = item["task_status"];
            }
          },
        );

        rateReviewType = result1.data["task_type"][0]["task_type"];
      } else {
        debugPrint(
            "Error getting task status: " + result0.exception.toString());
        logger.e("Error getting task status: " + result0.exception.toString());

        debugPrint("Error getting task type: " + result1.exception.toString());
        logger.e("Error getting task type: " + result1.exception.toString());
      }
    }

    if (!UserService.isAdmin && !UserService.isSalesManager) {
      var saveDate = DateTime.parse(taskDateController.text).toUtc();
      var saveDateFormat = DateFormat("yyyy-MM-dd HH:mm").format(saveDate);

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
        MutationOptions options = MutationOptions(
          document: gql("""
        mutation INSERT_TASK(\$data: [task_insert_input!]! = {}) {
          insert_task(objects: \$data) {
            returning {
              task
            }
          }
        }
            """),
          fetchPolicy: FetchPolicy.noCache,
          variables: {"data": data},
        );

        final QueryResult result =
            await GqlClientFactory().authGqlmutate(options);

        if (result != null) {
          if (result.hasException == false) {
            logger.i("Task for rate review successfully scheduled for " +
                data["lead"].toString() +
                " on " +
                data["date"].toString());

            Fluttertoast.showToast(
              msg: successMsg.toString(),
              toastLength: msgLength,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            debugPrint("Error inserting task for rate review: " +
                result.exception.toString());
            logger.e("Error inserting task for rate review: " +
                result.exception.toString());
          }
        }
      } catch (err) {
        debugPrint("Failed to create rate review task: " + err.toString());
        logger.e("Failed to create rate review task: " + err.toString());
        Fluttertoast.showToast(
          msg: "Failed to create task for employee!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<void> leaveCheck() async {
    if (prompt) {
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
                      activeValueString != null
                          ? Text(
                              'You have an unsubmitted statement for ' +
                                  activeValueString,
                            )
                          : Text('You have an unsubmitted statement!'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          ' Would you like to submit this statement before you leave?',
                        ),
                      ),
                      UserService.isAdmin || UserService.isSalesManager
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Text(
                                'Please enter the date and time you intend to present the rate review to this merchant',
                              ),
                            ),
                      UserService.isAdmin || UserService.isSalesManager
                          ? Container()
                          : DateTimeField(
                              onEditingComplete: () =>
                                  FocusScope.of(context).nextFocus(),
                              decoration: InputDecoration(
                                labelText: "Date to Present Rate Review",
                              ),
                              format: DateFormat("yyyy-MM-dd HH:mm"),
                              controller: taskDateController,
                              validator: (DateTime dateTime) {
                                if (dateTime == null) {
                                  logger.i(
                                      "No date specified for date rate review date picker");
                                  return 'Please select a date';
                                }
                                return null;
                              },
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.red),
                            child: Text(
                              'Leave',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                            onPressed: () {
                              logger.i("Statement exited without being sent");
                              Navigator.pushNamed(
                                context,
                                "/viewlead",
                                arguments: lead["lead"],
                              );
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: UniversalStyles.actionColor,
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () {
                              if (UserService.isAdmin ||
                                  UserService.isSalesManager) {
                                Navigator.pop(context);
                                uploadComplete();
                              } else {
                                if (taskDateController.text != "" &&
                                    taskDateController.text != null) {
                                  Navigator.pop(context);
                                  uploadComplete();
                                } else {
                                  logger.i(
                                      "No task date specified for rate review presentation");
                                  Fluttertoast.showToast(
                                    msg: "Please select a date/time!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey[600],
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  return null;
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      Navigator.pushNamed(context, "/viewlead", arguments: lead["lead"]);
      return;
    }
  }

  Future<void> adminUploadCheck(result) async {
    if (imageDLList.length == 0 && !inactiveSelected) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Assign Statement'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          'Would you like to give a different employee credit for this statement?',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                        child: EmployeeDropDown(
                          caption: "Statement Owner",
                          displayClear: false,
                          value: statementEmployee,
                          callback: (value) {
                            statementEmployee = value;
                            logger.i("Employee selected: " + value.toString());
                          },
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () {
                              logger.i("Statement re-assignment cancelled");
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Assign',
                              style: TextStyle(
                                fontSize: 17,
                                color: UniversalStyles.actionColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              logger.i("Statement assigned to new employee: " +
                                  statementEmployee.toString());
                              addImage(result);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      Navigator.pushNamed(
        context,
        "/viewlead",
        arguments: lead["lead"],
      );
      return;
    }
  }

  var currentImage;
  Future<void> viewImage(asset, imgIndex) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text("Viewing Image"),
            action: <Widget>[
              emailSent
                  ? Container()
                  : MaterialButton(
                      padding: EdgeInsets.all(5),
                      color: Colors.red,
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
            child: Column(
              children: <Widget>[
                Expanded(
                  child: buildPhotoGallery(context, imgIndex),
                )
              ],
            ),
          ),
        );
      },
    );
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

    return file.writeAsBytes(stream);
  }

  Future<bool> existsFile() async {
    final file = await _localFile;
    return file.exists();
  }

  Future<Uint8List> fetchPost(getUrl) async {
    final response = await http.get(Uri.parse(getUrl));
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
    if (!mounted) {
      logger.e("PDF not displaying correctly because it is not mounted");
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text("Viewing PDF"),
            action: <Widget>[
              emailSent
                  ? Container()
                  : MaterialButton(
                      padding: EdgeInsets.all(5),
                      color: Colors.red,
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
            child: Column(
              children: <Widget>[
                Expanded(
                  child: PDFView(filePath: path),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List galleryImages = [];

  Widget buildPhotoGallery(BuildContext context, page) {
    PageController pageController = PageController(initialPage: page);

    return Container(
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
              galleryImages[index]["url"],
            ),
            initialScale: PhotoViewComputedScale.contained * 0.8,
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
        pageController: pageController,
        onPageChanged: (newVal) {
          setState(
            () {
              currentImage = galleryImages[newVal];
            },
          );
        },
      ),
    );
  }

  Widget buildDLGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(
        imageDLList.length,
        (index) {
          logger.i("Image gallery built with " +
              imageDLList.length.toString() +
              " images");
          Map imgFile = imageDLList[index];
          var stringLen = imgFile["url"].length;
          var extendo = imgFile["url"].substring(stringLen - 3, stringLen);
          return GestureDetector(
            onTap: () {
              logger.i("Gallery image selected \ntype: " +
                  extendo.toString() +
                  ", \nfile: " +
                  imgFile.toString());
              if (extendo == "pdf") {
                viewPdf(
                  imgFile,
                );
              } else {
                setState(
                  () {
                    galleryImages = [];
                    currentImage = imgFile;
                  },
                );
                for (var item in imageDLList) {
                  var stringLen = item["url"].length;
                  var extendo = item["url"].substring(stringLen - 3, stringLen);
                  if (extendo != "pdf") {
                    galleryImages.add(item);
                  }
                }
                setState(() {
                  isLoading = false;
                });
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
                      ),
                    ),
                  )
                : Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        alignment: FractionalOffset.topCenter,
                        image: NetworkImage(
                          imgFile["url"],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> deleteImage(asset) async {
    var name = asset["name"];

    try {
      var resp = await this.widget.apiService.authDelete(context,
          "/api/upload/statement?lead=${lead["lead"]}&statement=$name", null);

      if (resp.statusCode == 200) {
        logger.i("File deleted " + asset.toString());
        if (imageDLList.length == 1) {
          setState(() {
            dirtyFlag = false;
            uploadsComplete = false;
            statementActive = false;
          });
          logger.i("Gallery list now has 0 images in it, resetting flags");
        }

        Navigator.pop(context);
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "File Deleted!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          imageDLList = [];
          statementActive = false;

          loadStatements();
        });
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Failed to delete image!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (err) {
      debugPrint("Failed to delete image: " + err.toString());
      logger.e("Failed to delete image: " + err.toString());
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
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 17,
                ),
              ),
              onPressed: () {
                logger.i("Delete check canceled for " + asset.toString());
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
              onPressed: () {
                deleteImage(asset);
              },
            ),
          ],
        );
      },
    );
  }

  var loadedImage;

  Future<void> loadImages() async {
    setState(() {
      isLoading = true;
    });
    try {
      QueryOptions options = QueryOptions(
        document: gql("""
      query LEAD_PHOTOS(\$lead: uuid!) {
        lead_photos(lead: \$lead){
          photos
        }
      } 
      """),
        variables: {
          "lead": lead["lead"],
        },
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result.hasException == false) {
        if (result.data != null) {
          logger.i("Statement image data loaded");
          for (var imgUrl in result.data["lead_photos"]["photos"]) {
            var url =
                "${ConfigSettings.HOOK_API_URL}/uploads/statement/$imgUrl";
            if (dropdownValue != null) {
              if (imgUrl.contains(dropdownValue)) {
                setState(
                  () {
                    imageDLList.add(
                      {"name": imgUrl, "url": url},
                    );
                  },
                );
              }
            }
          }
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (err) {
      debugPrint("Failed to download images: " + err.toString());
      logger.e("Failed to download images: " + err.toString());
      Fluttertoast.showToast(
        msg: "Failed to download images!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );

      setState(
        () {
          isLoading = false;
        },
      );
    }
  }

  Future<void> uploadComplete() async {
    try {
      setState(
        () {
          isLoading = true;
        },
      );

      if (statementId != null && statementId != "") {
        MutationOptions mutateOptions = MutationOptions(
          document: gql("""
        mutation SEND_EMAIL(
          \$statement:String!
        ){
          email_statement(
            statement:\$statement
          ){
            email_status
          }
        }
        """),
          variables: {
            "statement": statementId,
          },
          fetchPolicy: FetchPolicy.noCache,
        );

        final QueryResult result =
            await GqlClientFactory().authGqlmutate(mutateOptions);

        if (result.hasException == false) {
          if (result.data != null) {
            if (!UserService.isAdmin || !UserService.isSalesManager) {
              createTask();
            }
            setState(
              () {
                uploadsComplete = true;
                isLoading = false;
              },
            );
            Navigator.pushNamed(context, "/viewlead", arguments: lead["lead"]);

            logger.i("Statement submitted successfully");
            Fluttertoast.showToast(
              msg: "Statement Submitted!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          debugPrint(
              "Failed to submit statment: " + result.exception.toString());
          logger.e("Failed to submit statment: " + result.exception.toString());
          Fluttertoast.showToast(
            msg: "Failed to submit statement! Error: " +
                result.exception.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint(
            "Failed to submit statement because there is no Statement ID");
        logger.e("Failed to submit statement because there is no Statement ID");

        Fluttertoast.showToast(
          msg: "Failed to submit statement! No Statement ID",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (err) {
      debugPrint("Error submitting statement: " + err.toString());
      logger.e("Error submitting statement: " + err.toString());

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Failed to submit statement!" + err.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> addImage(path) async {
    try {
      var resp;
      setState(() {
        isLoading = true;
      });
      if (UserService.isAdmin || UserService.isSalesManager) {
        if (imageDLList.length == 0) {
          resp = await this.widget.apiService.authFilePost(
              context,
              "/api/upload/statement?lead=${lead["lead"]}&employee=$statementEmployee",
              path);
        } else {
          resp = await this.widget.apiService.authFilePost(
              context,
              "/api/upload/statement?lead=${lead["lead"]}&employee=${UserService.employee.employee}",
              path);
        }
      } else {
        if (path != null) {
          resp = await this.widget.apiService.authFilePost(
              context,
              "/api/upload/statement?lead=${lead["lead"]}&employee=${UserService.employee.employee}",
              path);
        }
      }

      if (resp != null) {
        if (resp.statusCode == 200) {
          logger.i("File uploaded successfully");
          Fluttertoast.showToast(
            msg: "File Uploaded!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );

          var imgUrl = resp.data["name"];
          var url = "${ConfigSettings.HOOK_API_URL}/uploads/statement/$imgUrl";

          if (statementActive == false) {
            imageDLList = [];
            loadStatements();
          } else {
            imageDLList.add({"name": imgUrl, "url": url});
            logger.i("Uploaded file added to list: " + imgUrl.toString());
          }
          setState(() {
            statementId = resp.data["statement"];
            dirtyFlag = false;
            isLoading = false;
            inactiveSelected = false;
            statementActive = true;
            emailSent = false;
          });
        } else {
          logger.e("Failed to upload file" + resp.err);
          Fluttertoast.showToast(
            msg: "Failed to upload file!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });

      debugPrint("Error adding image: " + err.toString());
      logger.e("Error adding image: " + err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if ((!uploadsComplete && imageDLList.length > 0 && statementActive) ||
            (inactiveSelected && !emailSent)) {
          setState(() {
            prompt = true;
          });
          logger.i("User will be prompted on leave");
        } else {
          setState(() {
            prompt = false;
          });
          logger.i("User will not be prompted on leave");
        }

        leaveCheck();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          key: Key("viewTasksAppBar"),
          title: Text(
            isLoading
                ? "Loading..."
                : "Statements for: " + lead["document"]["businessName"],
          ),
          action: <Widget>[],
        ),
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
                            fillColor: uploadsComplete || isBoarded
                                ? Colors.grey
                                : UniversalStyles.actionColor,
                            onPressed: uploadsComplete || isBoarded
                                ? () {}
                                : () async {
                                    var result = await platform
                                        .invokeMethod("openMedia");
                                    logger.i("Media library channel invoked");
                                    if (UserService.isAdmin ||
                                        UserService.isSalesManager) {
                                      if (imageDLList.length == 0) {
                                        adminUploadCheck(result);
                                      } else {
                                        addImage(result);
                                      }
                                    } else {
                                      addImage(result);
                                    }
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
                          fillColor: uploadsComplete || isBoarded
                              ? Colors.grey
                              : UniversalStyles.actionColor,
                          onPressed: uploadsComplete || isBoarded
                              ? () {}
                              : () async {
                                  var result =
                                      await platform.invokeMethod("openCamera");
                                  logger.i("Camera channel invoked");
                                  if (UserService.isAdmin ||
                                      UserService.isSalesManager) {
                                    if (imageDLList.length == 0) {
                                      adminUploadCheck(result);
                                    } else {
                                      addImage(result);
                                    }
                                  } else {
                                    addImage(result);
                                  }
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
                            fillColor: uploadsComplete || isBoarded
                                ? Colors.grey
                                : UniversalStyles.actionColor,
                            onPressed: uploadsComplete || isBoarded
                                ? () {}
                                : () async {
                                    var result = await FilePicker.platform
                                        .pickFiles(
                                            type: FileType.custom,
                                            allowMultiple: false,
                                            allowedExtensions: ['pdf']);
                                    logger.i("File picker invoked");
                                    if (UserService.isAdmin ||
                                        UserService.isSalesManager) {
                                      if (imageDLList.length == 0) {
                                        adminUploadCheck(result.files[0].path);
                                      } else {
                                        if (result != null) {
                                          addImage(result.files[0].path);
                                        }
                                      }
                                    } else {
                                      if (result != null) {
                                        addImage(result.files[0].path);
                                      }
                                    }
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
                    child: Text(
                      "Upload Statements",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (UserService.isAdmin || UserService.isSalesManager) &&
                              statements.length > 0
                          ? DropdownButton(
                              icon: Icon(Icons.arrow_drop_down),
                              value: dropdownValue,
                              hint: Text("View Past Statements"),
                              items: statements.map<DropdownMenuItem<String>>(
                                (dynamic value) {
                                  logger.i("Statements dropdown populated");
                                  var dateSubmitted =
                                      DateTime.parse(value["created_at"])
                                          .toUtc();
                                  var dateSubmittedFormat =
                                      DateFormat("MM/dd/yy")
                                          .format(dateSubmitted);
                                  var name = value["employeeByEmployee"]
                                      ["document"]["displayName"];

                                  var valueString =
                                      name + " - " + dateSubmittedFormat;

                                  if (value["is_active"] == true) {
                                    activeValueString = valueString;
                                  }

                                  return DropdownMenuItem<String>(
                                    value: value["statement"],
                                    child: Text(
                                      valueString,
                                      style: value["is_active"] == false
                                          ? TextStyle(
                                              color: Colors.grey[400],
                                              fontStyle: FontStyle.italic,
                                            )
                                          : null,
                                    ),
                                    onTap: () {
                                      if (value["is_active"] == false) {
                                        inactiveSelected = true;
                                        uploadsComplete = true;
                                        statementActive = false;
                                        emailSent = true;
                                        dirtyFlag = false;
                                        logger.i(
                                            "Inactive statement selected: " +
                                                valueString);
                                      } else {
                                        logger.i("Active statement selected: " +
                                            valueString);
                                        if (value["document"] != null) {
                                          if (value["document"]["emailSent"] ==
                                              true) {
                                            emailSent = true;
                                            uploadsComplete = true;
                                            statementActive = false;
                                            logger.i(
                                                "Active statement email has previously been sent");
                                          }
                                        } else {
                                          emailSent = false;
                                          uploadsComplete = false;
                                          statementActive = true;
                                          logger.i(
                                              "Active statement email has not been sent yet");
                                        }
                                        statementId = value["statement"];
                                        inactiveSelected = false;
                                      }
                                    },
                                  );
                                },
                              ).toList(),
                              onChanged: (newValue) {
                                logger.i("Dropdown value changed: " +
                                    newValue.toString());
                                setState(
                                  () {
                                    dropdownValue = newValue;
                                    imageDLList = [];
                                    loadImages();
                                  },
                                );
                              },
                            )
                          : Container(),
                    ],
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: buildDLGridView(),
                  ),
                ],
              ),
      ),
    );
  }
}
