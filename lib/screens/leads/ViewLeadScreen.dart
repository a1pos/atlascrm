import 'dart:async';

import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomWebView.dart';
import 'package:atlascrm/components/shared/SlideRightRoute.dart';
import 'package:atlascrm/models/Lead.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  static const platform = const MethodChannel('com.ces.atlascrm.channel');

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddrController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final dbaController = TextEditingController();
  final businessAddressController = TextEditingController();
  final businessPhoneNumberController = TextEditingController();
  final notesController = TextEditingController();

  var leadInfoEntries = List<LeadInfoEntry>();

  var isLoading = true;

  Lead lead;

  @override
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
        lead = Lead.fromJson(bodyDecoded);

        notesController.text = lead.notes;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateLead(leadId) async {
    lead.firstName = firstNameController.text;
    lead.lastName = lastNameController.text;
    lead.emailAddr = emailAddrController.text;
    lead.phoneNumber = phoneNumberController.text;

    lead.businessName = businessNameController.text;
    lead.dbaName = dbaController.text;
    lead.businessAddress = businessAddressController.text;
    lead.businessPhoneNumber = businessPhoneNumberController.text;

    lead.notes = notesController.text;

    var resp = await this
        .widget
        .apiService
        .authPut(context, "/leads/" + this.widget.leadId, lead);

    if (resp.statusCode == 200) {
      await loadLeadData(this.widget.leadId);

      Fluttertoast.showToast(
          msg: "Successful update!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
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
          context, "/leads/${this.widget.leadId}/statement", fileImage.file);
    } catch (err) {
      print(err);
    }

    Navigator.pop(context);
  }

  Future<void> deleteLead(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authDelete(context, "/leads/" + this.widget.leadId, null);

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
        appBar: CustomAppBar(
          key: Key("viewLeadsAppBar"),
          title: Text(isLoading ? "Loading..." : lead.businessName),
        ),
        body: isLoading
            ? CenteredClearLoadingScreen()
            : Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomCard(
                        key: Key("leads1"),
                        icon: Icons.person,
                        title: "Personal Information",
                        child: Column(
                          children: <Widget>[
                            getInfoRow("First Name", lead.firstName,
                                firstNameController),
                            getInfoRow(
                                "Last Name", lead.lastName, lastNameController),
                            getInfoRow("Email Address", lead.emailAddr,
                                emailAddrController),
                            getInfoRow("Phone Number", lead.phoneNumber,
                                phoneNumberController),
                          ],
                        ),
                      ),
                      CustomCard(
                        key: Key("leads2"),
                        icon: Icons.business,
                        title: "Business Information",
                        child: Column(
                          children: <Widget>[
                            getInfoRow("Business Name", lead.businessName,
                                businessNameController),
                            getInfoRow("Doing Business As", lead.dbaName,
                                dbaController),
                            getInfoRow("Business Address", lead.businessAddress,
                                businessAddressController),
                            getInfoRow("Phone Number", lead.businessPhoneNumber,
                                businessPhoneNumberController),
                          ],
                        ),
                      ),
                      CustomCard(
                        key: Key("leads3"),
                        icon: Icons.question_answer,
                        title: "Misc Information",
                        child: Column(
                          children: <Widget>[],
                        ),
                      ),
                      CustomCard(
                        key: Key("leads4"),
                        title: "Notes",
                        icon: Icons.note,
                        child: TextField(
                          maxLines: 12,
                          controller: notesController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.greenAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.5),
                            ),
                            hintText: 'Additional Notes.',
                          ),
                        ),
                      ),
                      CustomCard(
                        key: Key("leads5"),
                        title: "Tools",
                        icon: Icons.build,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            MaterialButton(
                              padding: EdgeInsets.all(5),
                              color: Color.fromARGB(500, 1, 224, 143),
                              onPressed: () async {
                                Navigator.of(context).push(
                                  SlideRightRoute(
                                    page: CustomWebView(
                                      title: "Docusigner",
                                      selectedUrl:
                                          "https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=c04d3d47-c7be-46d5-a10a-471e8c9e531b&env=demo&acct=d805e4d3-b594-4e79-9d49-243e076e75e6&v=2",
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.file_upload,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Docusigner',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: UnicornDialer(
          parentButtonBackground: Color.fromARGB(500, 1, 224, 143),
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(
            Icons.add,
            color: Colors.white,
          ),
          childButtons: <UnicornButton>[
            UnicornButton(
              hasLabel: true,
              labelText: "Save Lead",
              currentButton: FloatingActionButton(
                heroTag: "saveLead",
                backgroundColor: Colors.green[300],
                mini: true,
                foregroundColor: Colors.white,
                child: Icon(Icons.save),
                onPressed: () {
                  updateLead(this.widget.leadId);
                },
              ),
            ),
            UnicornButton(
              hasLabel: true,
              labelText: "Delete Lead",
              currentButton: FloatingActionButton(
                heroTag: "deleteLead",
                mini: true,
                backgroundColor: Colors.red[300],
                child: Icon(Icons.delete),
                foregroundColor: Colors.white,
                onPressed: () {
                  deleteLead(this.widget.leadId);
                },
              ),
            ),
          ],
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
              child: TextField(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
