import 'dart:async';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:atlascrm/components/shared/MerchantDropdown.dart';

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
  var merchantController = TextEditingController();

  var leadInfoEntries = List<LeadInfoEntry>();
  var deviceIcon;

  String addressText;
  bool isChanged = false;
  var inventory;
  var inventoryDocument;
  var isLoading = true;
  var displayPhone;
  var deviceStatus;
  void initState() {
    super.initState();
    loadInventoryData();
  }

  var childButtons = List<UnicornButton>();
  Future<void> initStatus() async {
    if (inventory["is_installed"] == true) {
      deviceStatus = "Installed";
      deviceIcon = Icons.done;
      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Return",
          currentButton: FloatingActionButton(
              heroTag: "return",
              backgroundColor: Colors.redAccent,
              mini: true,
              child: Icon(Icons.replay),
              onPressed: () {
                updateDevice("return");
              })));
    }
    if (inventory["merchant"] != null && inventory["is_installed"] != true) {
      deviceStatus = "Awaiting Install";
      deviceIcon = Icons.directions_car;
      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Install",
          currentButton: FloatingActionButton(
              heroTag: "install",
              backgroundColor: Colors.greenAccent,
              mini: true,
              child: Icon(Icons.build),
              onPressed: () {
                updateDevice("install");
              })));

      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Return",
          currentButton: FloatingActionButton(
              heroTag: "return2",
              backgroundColor: Colors.redAccent,
              mini: true,
              child: Icon(Icons.replay),
              onPressed: () {
                updateDevice("return");
              })));
    }
    if (inventory["merchant"] == null && inventory["employee"] == null) {
      deviceStatus = "In Warehouse";
      deviceIcon = Icons.business;
      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Checkout",
          currentButton: FloatingActionButton(
            heroTag: "checkout",
            backgroundColor: Colors.blueAccent,
            mini: true,
            child: Icon(Icons.devices),
            onPressed: () {
              checkout();
            },
          )));
    }
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
          merchantController.text = inventory["merchantname"];
          isLoading = false;
        });
      }
    }
    initStatus();
  }

  Future<void> updateDevice(type) async {
    var data;
    var alert;
    if (type == "checkout") {
      data = {
        "employee": UserService.employee.employee,
        "merchant": merchantController.text
      };
      alert = "Device checked out!";
    }
    if (type == "return") {
      data = {"merchant": null, "employee": null};
      alert = "Device returned!";
    }
    if (type == "install") {
      data = {"is_installed": true};
      alert = "Device installed!";
    }
    var resp = await this
        .widget
        .apiService
        .authPut(context, "/inventory/" + this.widget.deviceId, data);

    if (resp.statusCode == 200) {
      await loadInventoryData();

      Fluttertoast.showToast(
          msg: alert,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pushNamed(context, '/inventory');
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

  Future<void> checkout() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Text('Checkout this Device'),
                ),
                MerchantDropDown(callback: (newValue) {
                  setState(() {
                    merchantController.text = newValue;
                  });
                })
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Checkout',
                  style: TextStyle(fontSize: 17, color: Colors.green)),
              onPressed: () {
                if (merchantController.text != null &&
                    merchantController.text != "") {
                  updateDevice("checkout");
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                      msg: "Please select a merchant",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ),
          ],
        );
      },
    );
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
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
            //   child: IconButton(
            //     onPressed: () {
            //       deleteCheck(this.widget.deviceId);
            //     },
            //     icon: Icon(Icons.delete, color: Colors.white),
            //   ),
            // )
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
                              showInfoRow(
                                  "Current Merchant", merchantController.text),
                              showInfoRow(
                                  "Current Employee", inventory["owner"]),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(17, 0, 0, 0),
                                    child: Text("Status:",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 0, 8),
                                    child: Text(deviceStatus,
                                        style: TextStyle(fontSize: 15)),
                                  )),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(70, 0, 0, 0),
                                    child: Icon(deviceIcon),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: UnicornDialer(
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.0),
            parentButtonBackground: Color.fromARGB(500, 1, 224, 143),
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.menu),
            childButtons: childButtons),
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
