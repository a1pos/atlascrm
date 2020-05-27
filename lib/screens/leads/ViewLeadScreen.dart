import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:atlascrm/components/shared/Notes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class LeadInfoEntry {
  final TextEditingController controller;
  final Key key;
  LeadInfoEntry(this.controller, this.key);
}

class ViewLeadScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String leadId;

  ViewLeadScreen(this.leadId);

  @override
  ViewLeadScreenState createState() => ViewLeadScreenState();
}

class ViewLeadScreenState extends State<ViewLeadScreen> {
  final _leadFormKey = GlobalKey<FormState>();

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailAddrController = TextEditingController();
  var phoneNumberController = MaskedTextController(mask: '000-000-0000');
  var businessNameController = TextEditingController();
  var dbaController = TextEditingController();
  var businessAddressController = TextEditingController();
  var notesController = TextEditingController();
  var leadSourceController = TextEditingController();

  var leadInfoEntries = List<LeadInfoEntry>();

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  String addressText;
  bool isChanged = false;
  var lead;
  var leadDocument;
  var isLoading = true;
  var displayPhone;
  void initState() {
    super.initState();
    loadLeadData(this.widget.leadId);
    initializeTools();
  }

  Future<void> initializeTools() async {}

  Future<void> loadLeadData(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/lead/" + this.widget.leadId);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          lead = bodyDecoded;
          leadDocument = bodyDecoded["document"];
          firstNameController.text = leadDocument["firstName"];
        });
      }
    }

    setState(() {
      isLoading = false;
    });
    if (leadDocument?.isEmpty ?? true) {
      leadDocument = {
        "businessName": "",
        "businessType": "",
        "firstName": "",
        "lastName": "",
        "emailAddr": "",
        "phoneNumber": "",
        "dbaName": "",
        "address": "",
        "city": "",
        "state": "",
        "zipCode": "",
      };
    }
    if (leadDocument["address"] != null && leadDocument["address"] != "") {
      addressText = leadDocument["address"] +
          ", " +
          leadDocument["city"] +
          ", " +
          leadDocument["state"] +
          ", " +
          leadDocument["zipCode"];
      businessAddress["address"] = leadDocument["address"];
      businessAddress["city"] = leadDocument["city"];
      businessAddress["state"] = leadDocument["state"];
      businessAddress["zipcode"] = leadDocument["zipCode"];
    }
    if (leadDocument["phoneNumber"] != null ||
        leadDocument["phoneNumber"] != "") {
      setState(() {
        phoneNumberController.updateText(leadDocument["phoneNumber"]);
      });
    }
  }

  Future<void> updateLead(leadId) async {
    String rawNumber = phoneNumberController.text;
    var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");
    var leadToUpdate = {
      "businessName": businessNameController.text,
      "businessType": "",
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "emailAddr": emailAddrController.text,
      "phoneNumber": filteredNumber,
      "dbaName": dbaController.text,
      "address": businessAddress["address"],
      "city": businessAddress["city"],
      "state": businessAddress["state"],
      "zipCode": businessAddress["zipcode"],
    };
    var resp = await this
        .widget
        .apiService
        .authPut(context, "/lead/" + this.widget.leadId, leadToUpdate);

    if (resp.statusCode == 200) {
      await loadLeadData(this.widget.leadId);

      Fluttertoast.showToast(
          msg: "Lead Updated!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pushNamed(context, '/leads');
    } else {
      Fluttertoast.showToast(
          msg: "Failed to udpate lead!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> imageResult(Image image) async {
    try {
      FileImage fileImage = image.image;
      var bytes = fileImage.file.readAsBytesSync();
      var resp = await this.widget.apiService.authFilePost(
          context, "/lead/${this.widget.leadId}/statement", fileImage.file);
    } catch (err) {
      print(err);
    }

    Navigator.pop(context);
  }

  Future<void> deleteCheck(leadId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete this Lead?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this lead?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                deleteLead(leadId);

                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteLead(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authDelete(context, "/lead/" + this.widget.leadId, null);

    if (resp.statusCode == 200) {
      Navigator.popAndPushNamed(context, "/leads");

      Fluttertoast.showToast(
          msg: "Successful delete!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to delete lead!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.popAndPushNamed(context, '/leads');

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          key: Key("viewTasksAppBar"),
          title: Text(isLoading ? "Loading..." : leadDocument["businessName"]),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
              child: IconButton(
                onPressed: () {
                  deleteCheck(this.widget.leadId);
                },
                icon: Icon(Icons.delete, color: Colors.white),
              ),
            )
          ],
          backgroundColor: Color.fromARGB(500, 1, 56, 112),
        ),
        body: isLoading
            ? CenteredClearLoadingScreen()
            : Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _leadFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomCard(
                          key: Key("leads2"),
                          icon: Icons.business,
                          title: "Business Information",
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              validatorRow(
                                  "Business Name",
                                  leadDocument["businessName"],
                                  businessNameController, (val) {
                                if (val.isEmpty) {
                                  return 'Please enter a business name';
                                }
                                return null;
                              }),
                              getInfoRow("Doing Business As",
                                  leadDocument["dbaName"], dbaController),
                              Container(
                                  child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              'Business Address:',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 8,
                                              child: AddressSearch(
                                                  locationValue: addressText,
                                                  onAddressChange: (val) =>
                                                      businessAddress = val)),
                                        ],
                                      ))),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("leads1"),
                          icon: Icons.person,
                          title: "Contact Information",
                          child: Column(
                            children: <Widget>[
                              validatorRow(
                                  "First Name",
                                  leadDocument["firstName"],
                                  firstNameController, (val) {
                                if (val.isEmpty) {
                                  return 'Please enter a contact first name';
                                }
                                return null;
                              }),
                              validatorRow(
                                  "Last Name",
                                  leadDocument["lastName"],
                                  lastNameController, (val) {
                                if (val.isEmpty) {
                                  return 'Please enter a contact last name';
                                }
                                return null;
                              }),
                              validatorRow(
                                  "Email Address",
                                  leadDocument["emailAddr"],
                                  emailAddrController, (value) {
                                if (value.isNotEmpty && !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              }),
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Phone Number',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: TextField(
                                          controller: phoneNumberController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      color: Color.fromARGB(500, 1, 224, 143),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.mail, color: Colors.white),
                                          Text("Email",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                      onPressed: () {
                                        if (emailAddrController.text != null &&
                                            emailAddrController.text != "") {
                                          var launchURL1 =
                                              'mailto:${emailAddrController.text}?subject=Followup about ${businessNameController.text}';
                                          launch(launchURL1);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "No email specified!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.grey[600],
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      color: Color.fromARGB(500, 1, 224, 143),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.call, color: Colors.white),
                                          Text("Call",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                      onPressed: () {
                                        if (phoneNumberController.text !=
                                                null &&
                                            phoneNumberController.text != "") {
                                          var launchURL2 =
                                              'tel:${phoneNumberController.text}';
                                          launch(launchURL2);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "No phone number specified!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.grey[600],
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("leads3"),
                          icon: Icons.question_answer,
                          title: "Misc Information",
                          child: Column(
                            children: <Widget>[
                              getInfoRow(
                                  "Lead Source",
                                  leadDocument["leadSource"],
                                  leadSourceController),
                            ],
                          ),
                        ),
                        CustomCard(
                            key: Key("leads4"),
                            title: "Notes",
                            icon: Icons.note,
                            child: Notes(type: "lead", object: lead["lead"])),
                        CustomCard(
                          key: Key("leads5"),
                          title: "Tools",
                          icon: Icons.build,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 200),
                                child: MaterialButton(
                                  padding: EdgeInsets.all(5),
                                  // color: Color.fromARGB(500, 1, 224, 143),
                                  color: Colors.grey[300],
                                  onPressed: () {
                                    return null;
                                    // Navigator.pushNamed(
                                    //     context, "/agreementbuilder",
                                    //     arguments: lead["lead"]);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.file_upload,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Agreement Builder',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_leadFormKey.currentState.validate()) {
              updateLead(this.widget.leadId);
            }
          },
          backgroundColor: Color.fromARGB(500, 1, 224, 143),
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  Widget getInfoRow(label, value, controller) {
    if (value != null) {
      controller.text = value;
    }

    var valueFmt = value ?? "N/A";

    if (valueFmt == "") {
      valueFmt = "N/A";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextField(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget validatorRow(label, value, controller, validator) {
    if (value != null) {
      controller.text = value;
    }

    var valueFmt = value ?? "N/A";

    if (valueFmt == "") {
      valueFmt = "N/A";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextFormField(
                controller: controller,
                validator: validator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
