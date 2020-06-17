import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/components/shared/ImageUploader.dart';

class LeadInfoEntry {
  final TextEditingController controller;
  final Key key;
  LeadInfoEntry(this.controller, this.key);
}

class ViewInventoryScreen extends StatefulWidget {
  final ApiService apiService = ApiService();

  final String deviceId;

  ViewInventoryScreen(this.deviceId);

  @override
  ViewInventoryScreenState createState() => ViewInventoryScreenState();
}

class ViewInventoryScreenState extends State<ViewInventoryScreen> {
  final _leadFormKey = GlobalKey<FormState>();

  var serialNumberController = TextEditingController();
  var priceTierController = TextEditingController();

  var leadInfoEntries = List<LeadInfoEntry>();

  String addressText;
  bool isChanged = false;
  var inventory;
  var inventoryDocument;
  var isLoading = true;
  var displayPhone;
  void initState() {
    super.initState();
    loadInventoryData();
  }

  Future<void> loadInventoryData() async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/inventory/${this.widget.deviceId}");

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          inventory = bodyDecoded;
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateLead(leadId) async {
    var deviceToUpdate = {};
    var resp = await this
        .widget
        .apiService
        .authPut(context, "/device/" + this.widget.deviceId, deviceToUpdate);

    if (resp.statusCode == 200) {
      await loadInventoryData();

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

  Future<void> deleteCheck(leadId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete from inventory?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this device?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel', style: TextStyle(fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Delete',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                deleteDevice(leadId);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteDevice(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authDelete(context, "/inventory/" + this.widget.deviceId, null);

    if (resp.statusCode == 200) {
      Navigator.popAndPushNamed(context, "/inventory");

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
        Navigator.pop(context);

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          key: Key("viewTasksAppBar"),
          title: Text(isLoading ? "Loading..." : inventory["serial"]),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
              child: IconButton(
                onPressed: () {
                  deleteCheck(this.widget.deviceId);
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
                          key: Key("inventory1"),
                          icon: Icons.devices,
                          title: "Device Info.",
                          child: Column(
                            children: <Widget>[
                              showInfoRow("Model", inventory["model"]),
                              showInfoRow("Serial Number", inventory["serial"]),
                              showInfoRow(
                                  "Location", inventory["locationname"]),
                              showInfoRow("Current Merchant",
                                  inventory["merchantname"]),
                              showInfoRow(
                                  "Current Employee", inventory["owner"]),

                              // getInfoRow("Device Model",
                              //     deviceDocument["model"], priceTierController),
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
              updateLead(this.widget.deviceId);
            }
          },
          backgroundColor: Color.fromARGB(500, 1, 224, 143),
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  Widget showInfoRow(label, value) {
    if (value == null) {
      value = "";
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
            Expanded(flex: 8, child: Text(value)),
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
