import 'dart:developer';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:atlascrm/components/inventory/InventoryLocationDropDown.dart';
import 'package:atlascrm/components/inventory/InventoryPriceTierDropDown.dart';

class InventoryAdd extends StatefulWidget {
  final ApiService apiService = new ApiService();
  InventoryAdd();

  @override
  InventoryAddState createState() => InventoryAddState();
}

class InventoryAddState extends State<InventoryAdd> {
  final _formKey = GlobalKey<FormState>();
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  final _stepperKey = GlobalKey<FormState>();
  bool isSaveDisabled;
  bool isAddress = false;
  bool isLoading = true;
  var leads;

  final UserService userService = UserService();
  final ApiService apiService = ApiService();

  var phoneNumberController = MaskedTextController(mask: '000-000-0000');

  var serialNumberController = TextEditingController();
  var priceTierController = TextEditingController();
  var locationController = TextEditingController();

  var _currentStep = 0;
  var stepsLength = 2;
  List serialList = [];
  var locationValue;
  bool added = false;

  @override
  void initState() {
    super.initState();
    isSaveDisabled = false;
    _currentStep = 0;
    isLoading = false;
  }

  Future<void> addToList(input) async {
    RegExp searchPat = RegExp(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$");
    bool isMac = searchPat.hasMatch(input);
    bool isListed = false;
    for (var device in serialList) {
      if (device["serial"] == input) {
        isListed = true;
      }
    }
    if (isMac == false && isListed == false) {
      setState(() {
        serialList.add({
          "inventory_price_tier": priceTierController.text,
          "inventory_location": locationController.text,
          "serial": input
        });
      });
    } else {
      if (isListed) {
        Fluttertoast.showToast(
            msg: "This serial has already been scanned!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (isMac) {
        Fluttertoast.showToast(
            msg: "That's the MAC address!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> scanBarcode() async {
    try {
      var options = ScanOptions(strings: {
        "cancel": "done (${serialList.length})",
        "flash_on": "flash on",
        "flash_off": "flash off",
      });
      var result = await BarcodeScanner.scan(options: options);

      print(result.rawContent);

      if (result.type != ResultType.Cancelled) {
        addToList(result.rawContent.toString());
        await scanBarcode();
      }
    } catch (err) {
      log(err);
    }
  }

  Future<void> addDevice() async {
    try {
      var data = serialList;
      bool cleanPost = true;
      var resp1 = await this.widget.apiService.authPost(
          context, "/inventory/${UserService.employee.employee}", data);
      if (resp1 != null) {
        if (resp1.statusCode == 200) {
          if (resp1.data.length > 0) {
            print(resp1.data);

            for (var device in serialList) {
              bool contains = resp1.data.contains(device["serial"]);
              if (contains) {
                setState(() {
                  device["added"] = "false";
                  cleanPost = false;
                });
              } else {
                setState(() {
                  device["added"] = "true";
                });
              }
            }
            print(serialList);
          } else {
            for (var device in serialList) {
              setState(() {
                device["added"] = "true";
              });
              print(serialList);
            }
          }
          cleanPost
              ? Fluttertoast.showToast(
                  msg: "Devices Added!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0)
              : Fluttertoast.showToast(
                  msg: "Some of these devices already exist!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0);
          setState(() {
            added = true;
          });
          print(added);
        } else {
          Fluttertoast.showToast(
              msg: "Failed to add device!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        return null;
      }
    } catch (err) {
      log(err);
    }
  }

  Future<void> dupeDevice() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Lead'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('A lead already exists at this address!'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Try again', style: TextStyle(fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildDLGridView() {
    return ListView(
        shrinkWrap: true,
        children: List.generate(serialList.length, (index) {
          var device = serialList[index];
          bool isAdded;
          if (device["added"] != null) {
            if (device["added"] == "true") {
              setState(() {
                isAdded = true;
              });
            }
            if (device["added"] == "false") {
              setState(() {
                isAdded = false;
              });
            }
          }
          return GestureDetector(
              onTap: () {},
              child: isAdded != null
                  ? Card(
                      shape: isAdded
                          ? new RoundedRectangleBorder(
                              side: new BorderSide(
                                  color: Colors.green[200], width: 2.0),
                              borderRadius: BorderRadius.circular(4.0))
                          : new RoundedRectangleBorder(
                              side: new BorderSide(
                                  color: Colors.red[200], width: 2.0),
                              borderRadius: BorderRadius.circular(4.0)),
                      child: ListTile(
                          title: Text(device["serial"]),
                          trailing: IconButton(
                            icon: isAdded
                                ? Icon(Icons.check, color: Colors.green)
                                : Icon(Icons.clear, color: Colors.red),
                            onPressed: null,
                          )))
                  : Card(
                      child: ListTile(
                          title: Text(device["serial"]),
                          trailing: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                serialList.removeWhere((item) =>
                                    item["serial"] == device["serial"]);
                              });
                            },
                          ))));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CenteredLoadingSpinner()
        : Column(
            children: <Widget>[
              Expanded(
                child: Stepper(
                  controlsBuilder: (BuildContext context,
                      {VoidCallback onStepContinue,
                      VoidCallback onStepCancel}) {
                    return Row(
                      children: <Widget>[
                        Container(
                          child: null,
                        ),
                        Container(
                          child: null,
                        ),
                      ],
                    );
                  },
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  key: this._stepperKey,
                  onStepTapped: (int step) {
                    // if (validationPassed()) {
                    if (priceTierController.text == "" ||
                        locationController.text == "") {
                      print("FILL IN FIELDS");
                      setState(() {
                        _currentStep = step;
                      });
                    }
                    // }
                  },
                  onStepContinue: () {
                    // if (_formKeys[_currentStep].currentState.validate()) {
                    if (priceTierController.text != "" &&
                        locationController.text != "") {
                      setState(() {
                        _currentStep < stepsLength - 1
                            ? _currentStep += 1
                            : null;
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please Select Tier and Location!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[600],
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    // }
                  },
                  onStepCancel: () {
                    // if (_formKeys[_currentStep].currentState.validate()) {
                    setState(() {
                      _currentStep > 0 ? _currentStep -= 1 : null;
                    });
                    // }
                  },
                  steps: [
                    Step(
                      title: Text('Set Specs'),
                      content: Form(
                        key: _formKeys[0],
                        child: Column(
                          children: [
                            InventoryPriceTierDropDown(callback: (newValue) {
                              setState(() {
                                priceTierController.text = newValue;
                              });
                            }),
                            InventoryLocationDropDown(callback: (newValue) {
                              setState(() {
                                locationController.text = newValue;
                              });
                            }),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 0
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: Text('Add Serial Numbers'),
                      content: Form(
                        key: _formKeys[1],
                        child: Column(
                          children: [
                            Row(children: <Widget>[
                              Expanded(
                                child: getInfoRow(
                                    "S/N",
                                    serialNumberController.text,
                                    serialNumberController, (serial) {
                                  addToList(serialNumberController.text);
                                  serialNumberController.clear();
                                }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 13, 0, 0),
                                child: IconButton(
                                  icon: Icon(Icons.center_focus_weak),
                                  color: Color.fromARGB(500, 1, 224, 143),
                                  onPressed: scanBarcode,
                                ),
                              ),
                            ]),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        'Devices: ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 8,
                                        child:
                                            Text(serialList.length.toString())),
                                  ],
                                ),
                              ),
                            ),
                            Divider(),
                            ConstrainedBox(
                                constraints: new BoxConstraints(
                                  minHeight: 35.0,
                                  maxHeight: 340.0,
                                ),
                                child: Scrollbar(child: buildDLGridView())),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                  ],
                ),
              ),
              // custom stepper buttons
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _currentStep > 0
                        ? RaisedButton.icon(
                            onPressed: () {
                              Stepper stepper = _stepperKey.currentWidget;
                              stepper.onStepCancel();
                            },
                            label: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Back'),
                            ),
                            icon: Icon(Icons.arrow_back),
                          )
                        : Container(),
                    !isSaveDisabled
                        ? RaisedButton.icon(
                            onPressed: () {
                              if (_currentStep == stepsLength - 1
                                  // &&
                                  //     _formKeys[_currentStep]
                                  //         .currentState
                                  //         .validate()
                                  ) {
                                // setState(() {
                                //   isSaveDisabled = true;
                                // });
                                addDevice();
                              } else {
                                // if (isAddress) {
                                Stepper stepper = _stepperKey.currentWidget;
                                stepper.onStepContinue();
                                // }
                              }
                            },
                            label: Padding(
                              padding: EdgeInsets.all(20),
                              child: _currentStep == stepsLength - 1
                                  ? Text('Save')
                                  : Text('Next'),
                            ),
                            icon: _currentStep == stepsLength - 1
                                ? Icon(Icons.save)
                                : Icon(Icons.arrow_forward),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          );
  }

  bool validationPassed() {
    if (_formKey.currentState.validate()) {
      return true;
    }
    return false;
  }

  Widget getInfoRow(label, value, controller, onSubmit) {
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
                onSubmitted: onSubmit,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String validate(value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }
}
