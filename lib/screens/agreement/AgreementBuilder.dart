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

class AgreementBuilder extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String leadId;

  AgreementBuilder(this.leadId);

  @override
  AgreementBuilderState createState() => AgreementBuilderState();
}

class AgreementBuilderState extends State<AgreementBuilder> {
  static const platform = const MethodChannel('com.ces.atlascrm.channel');

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddrController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final dbaController = TextEditingController();
  final businessAddressController = TextEditingController();
  final businessPhoneNumberController = TextEditingController();
  final notesController = TextEditingController();

  var lead;
  var leadDocument;

  var isLoading = true;

  void initState() {
    super.initState();

    loadLeadData(this.widget.leadId);
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
  }

  Future<void> updateLead(leadId) async {
    var leadToUpdate = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "emailAddr": emailAddrController.text,
      "phoneNumber": phoneNumberController.text,
      "businessName": businessNameController.text,
      "dbaName": dbaController.text,
      "businessAddress": businessAddressController.text,
      "businessPhoneNumber": businessPhoneNumberController.text,
      "notes": notesController.text
    };

    var resp = await this
        .widget
        .apiService
        .authPut(context, "/lead/" + this.widget.leadId, leadToUpdate);

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.popAndPushNamed(context, '/leads');

        return Future.value(false);
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              // key: Key("contactInfoPageAppBar"),
              title: Text(isLoading ? "Loading..." : "Agreement Builder"),
              bottom: TabBar(isScrollable: false, tabs: [
                Tab(text: "Business Info"),
                Tab(text: "Owner Info"),
                Tab(text: "Rate Review")
              ])),
          body: isLoading
              ? CenteredClearLoadingScreen()
              : TabBarView(children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCard(
                            key: Key("leads1"),
                            icon: Icons.business,
                            title: "Business Info",
                            child: Column(
                              children: <Widget>[
                                getInfoRow(
                                    "First Name",
                                    leadDocument["firstName"],
                                    firstNameController),
                                getInfoRow(
                                    "Last Name",
                                    leadDocument["lastName"],
                                    lastNameController),
                                getInfoRow(
                                    "Email Address",
                                    leadDocument["emailAddr"],
                                    emailAddrController),
                                getInfoRow(
                                    "Phone Number",
                                    leadDocument["phoneNumber"],
                                    phoneNumberController),
                                getInfoRow(
                                    "Business Name",
                                    leadDocument["businessName"],
                                    businessNameController),
                                getInfoRow("Doing Business As",
                                    leadDocument["dbaName"], dbaController),
                                getInfoRow(
                                    "Business Address",
                                    leadDocument["businessAddress"],
                                    businessAddressController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCard(
                            key: Key("leads1"),
                            icon: Icons.people,
                            title: "Owner Info",
                            child: Column(
                              children: <Widget>[
                                getInfoRow(
                                    "First Name",
                                    leadDocument["firstName"],
                                    firstNameController),
                                getInfoRow(
                                    "Last Name",
                                    leadDocument["lastName"],
                                    lastNameController),
                                getInfoRow(
                                    "Email Address",
                                    leadDocument["emailAddr"],
                                    emailAddrController),
                                getInfoRow(
                                    "Phone Number",
                                    leadDocument["phoneNumber"],
                                    phoneNumberController),
                                getInfoRow(
                                    "Business Name",
                                    leadDocument["businessName"],
                                    businessNameController),
                                getInfoRow("Doing Business As",
                                    leadDocument["dbaName"], dbaController),
                                getInfoRow(
                                    "Business Address",
                                    leadDocument["businessAddress"],
                                    businessAddressController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCard(
                            key: Key("leads1"),
                            icon: Icons.attach_money,
                            title: "Rate Review",
                            child: Column(
                              children: <Widget>[
                                getInfoRow(
                                    "First Name",
                                    leadDocument["firstName"],
                                    firstNameController),
                                getInfoRow(
                                    "Last Name",
                                    leadDocument["lastName"],
                                    lastNameController),
                                getInfoRow(
                                    "Email Address",
                                    leadDocument["emailAddr"],
                                    emailAddrController),
                                getInfoRow(
                                    "Phone Number",
                                    leadDocument["phoneNumber"],
                                    phoneNumberController),
                                getInfoRow(
                                    "Business Name",
                                    leadDocument["businessName"],
                                    businessNameController),
                                getInfoRow("Doing Business As",
                                    leadDocument["dbaName"], dbaController),
                                getInfoRow(
                                    "Business Address",
                                    leadDocument["businessAddress"],
                                    businessAddressController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Fluttertoast.showToast(
                  msg: "Save placeholder",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            backgroundColor: Color.fromARGB(500, 1, 224, 143),
            child: Icon(Icons.save),
          ),
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
