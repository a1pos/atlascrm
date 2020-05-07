import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:atlascrm/components/shared/Empty.dart';

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
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddrController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final dbaController = TextEditingController();
  final businessAddressController = TextEditingController();
  final businessPhoneNumberController = TextEditingController();
  final notesController = TextEditingController();
  final leadSourceController = TextEditingController();

  var leadInfoEntries = List<LeadInfoEntry>();

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  String addressText;

  var lead;
  var leadDocument;
  List notes;
  List notesDisplay;
  var isLoading = true;
  var notesEmpty = true;

  void initState() {
    super.initState();

    loadLeadData(this.widget.leadId);
    loadNotes(this.widget.leadId);

    initializeTools();
  }

  Future<void> initializeTools() async {}

  Future<void> loadNotes(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/lead/" + this.widget.leadId + "/note");

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

  Future<void> saveNote(newNote) async {
    var sendNote = {"text": newNote};
    var resp = await this
        .widget
        .apiService
        .authPost(context, "/lead/" + lead["lead"] + "/note", sendNote);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          loadNotes(lead["lead"]);
        });
      }
    }
  }

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
        });
      }
    }

    setState(() {
      isLoading = false;
    });
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
  }

  Future<void> updateLead(leadId) async {
    var leadToUpdate = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "emailAddr": emailAddrController.text,
      "phoneNumber": phoneNumberController.text,
      "businessName": businessNameController.text,
      "dbaName": dbaController.text,
      "phoneNumber": businessPhoneNumberController.text,
      "notes": notesController.text,
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
          title: Text(isLoading ? "Loading..." : leadDocument["businessName"]),
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
                            getInfoRow("First Name", leadDocument["firstName"],
                                firstNameController),
                            getInfoRow("Last Name", leadDocument["lastName"],
                                lastNameController),
                            getInfoRow("Email Address",
                                leadDocument["emailAddr"], emailAddrController),
                            getInfoRow(
                                "Phone Number",
                                leadDocument["phoneNumber"],
                                phoneNumberController),
                          ],
                        ),
                      ),
                      CustomCard(
                        key: Key("leads2"),
                        icon: Icons.business,
                        title: "Business Information",
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            getInfoRow(
                                "Business Name",
                                leadDocument["businessName"],
                                businessNameController),
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
                            getInfoRow(
                                "Phone Number",
                                leadDocument["businessPhoneNumber"],
                                businessPhoneNumberController),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    controller: notesController,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.greenAccent,
                                            width: 3.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 0.5),
                                      ),
                                      hintText: 'Additional Notes.',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () {
                                    saveNote(notesController.text);
                                    notesController.text = "";
                                  },
                                )
                              ]),
                              !notesEmpty
                                  ? Column(
                                      children: notesDisplay =
                                          notes.map((note) {
                                        var viewDate =
                                            DateFormat("yyyy-MM-dd HH:mm")
                                                .add_jm()
                                                .format(DateTime.parse(
                                                    note["created_at"]));
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Card(
                                              child: Container(
                                                  child: ListTile(
                                                      title: Text(
                                                          note["note_text"]),
                                                      subtitle: Text(viewDate,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 10))))),
                                        );
                                      }).toList(),
                                    )
                                  : Empty("no notes"),
                            ],
                          )),
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
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, "/agreementbuilder",
                                    arguments: lead["lead"]);
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
