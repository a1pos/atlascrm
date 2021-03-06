import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:dan_barcode_scan/dan_barcode_scan.dart';
import 'package:round2crm/components/inventory/InventoryLocationDropDown.dart';
import 'package:round2crm/components/inventory/InventoryPriceTierDropDown.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class InventoryAdd extends StatefulWidget {
  InventoryAdd();

  @override
  InventoryAddState createState() => InventoryAddState();
}

class InventoryAddState extends State<InventoryAdd> {
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  final UserService userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  List serialList = [];

  bool isSaveDisabled;
  bool isAddress = false;
  bool isLoading = true;
  bool added = false;

  var leads;

  var phoneNumberController = MaskedTextController(mask: '000-000-0000');

  var serialNumberController = TextEditingController();
  var priceTierController = TextEditingController();
  var locationController = TextEditingController();
  var locationNameController = TextEditingController();

  var _currentStep = 0;
  var stepsLength = 2;
  var locationValue;

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
      setState(
        () {
          serialList.add(
            {
              "inventory_price_tier": priceTierController.text,
              "inventory_location": locationController.text,
              "serial": input,
            },
          );
        },
      );
    } else {
      if (isListed) {
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Scanned duplicate serial number");
        });

        Fluttertoast.showToast(
          msg: "This serial has already been scanned!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else if (isMac) {
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Inventory add MAC address scanned");
        });

        Fluttertoast.showToast(
          msg: "That's the MAC address!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<void> scanBarcode() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    try {
      var options = ScanOptions(
        strings: {
          "cancel": "done (${serialList.length})",
          "flash_on": "flash on",
          "flash_off": "flash off",
        },
      );
      var result = await BarcodeScanner.scan(options: options);
      Future.delayed(Duration(seconds: 1), () {
        logger.i("BarcodeScanner opened");
      });

      if (result.type != ResultType.Cancelled) {
        addToList(result.rawContent.toString());
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Device S/N added to list: " + result.rawContent.toString());
        });

        await scanBarcode();
      } else {
        Future.delayed(Duration(seconds: 1), () {
          logger.i("BarcodeScanner closed");
        });
      }
    } catch (err) {
      Future.delayed(Duration(seconds: 1), () {
        logger.e("ERROR: Error scanning barcode: " + err.toString());
      });
    }
  }

  Future<void> addDevice() async {
    try {
      if (serialList.length < 1) {
        Future.delayed(Duration(seconds: 1), () {
          logger.i("No devices scanned");
        });

        Fluttertoast.showToast(
          msg: "No devices scanned!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null;
      }
      bool cleanPost = true;
      for (var device in serialList) {
        var data = device;

        MutationOptions options = MutationOptions(
          document: gql("""
        mutation INSERT_DEVICES (\$objects: [inventory_insert_input!]!) {
          insert_inventory(objects: \$objects){
            affected_rows
          }
        }
      """),
          fetchPolicy: FetchPolicy.noCache,
          variables: {"objects": data},
        );

        final QueryResult result =
            await GqlClientFactory().authGqlmutate(options);

        if (result != null) {
          if (result.hasException == false) {
            setState(
              () {
                device["added"] = "true";
              },
            );
            setState(
              () {
                added = true;
              },
            );
          } else {
            setState(
              () {
                device["added"] = "false";
                cleanPost = false;
              },
            );
            Future.delayed(Duration(seconds: 1), () {
              logger.e(
                "Error adding inventory device: " + result.exception.toString(),
              );
            });

            Fluttertoast.showToast(
              msg: result.exception.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          setState(
            () {
              device["added"] = "false";
              cleanPost = false;
              added = true;
            },
          );
          return null;
        }
      }

      if (cleanPost) {
        Future.delayed(Duration(seconds: 1), () {
          logger.i(serialList.length.toString() + " Devices added");
        });

        Fluttertoast.showToast(
          msg: "Devices Added!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Some of the scanned devices already exist");
        });
        Fluttertoast.showToast(
          msg: "Some of these devices already exist!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (err) {
      Future.delayed(Duration(seconds: 1), () {
        logger.e("ERROR: Error adding device: " + err.toString());
      });
    }
  }

  Widget buildDLGridView() {
    return ListView(
      shrinkWrap: true,
      children: List.generate(
        serialList.length,
        (index) {
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
          return Container(
            child: isAdded != null
                ? Card(
                    shape: isAdded
                        ? new RoundedRectangleBorder(
                            side: new BorderSide(
                              color: Colors.green[200],
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          )
                        : new RoundedRectangleBorder(
                            side: new BorderSide(
                              color: Colors.red[200],
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                    child: ListTile(
                      title: Text(device["serial"]),
                      trailing: IconButton(
                        icon: isAdded
                            ? Icon(Icons.check, color: Colors.green)
                            : Icon(Icons.clear, color: Colors.red),
                        onPressed: null,
                      ),
                    ),
                  )
                : Card(
                    child: ListTile(
                      title: Text(device["serial"]),
                      trailing: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(
                            () {
                              Future.delayed(Duration(seconds: 1), () {
                                logger.i(
                                    "Scanned Device S/N removed from list: " +
                                        device["serial"]);
                              });

                              serialList.removeWhere(
                                (item) => item["serial"] == device["serial"],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
          );
        },
      ),
    );
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
                    if (priceTierController.text == "" ||
                        locationController.text == "") {
                      setState(() {
                        _currentStep = step;
                      });
                    }
                  },
                  onStepContinue: () {
                    if (priceTierController.text != "" &&
                        locationController.text != "") {
                      setState(() {
                        _currentStep < stepsLength - 1
                            ? _currentStep += 1
                            : null;
                      });
                      Future.delayed(Duration(seconds: 1), () {
                        logger.i("Next step on stepper hit: " +
                            _currentStep.toString());
                      });
                    } else {
                      Future.delayed(Duration(seconds: 1), () {
                        logger.i("Tier and Location not selected");
                      });

                      Fluttertoast.showToast(
                        msg: "Please Select a Tier and Location!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.grey[600],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  onStepCancel: () {
                    setState(
                      () {
                        _currentStep > 0 ? _currentStep -= 1 : null;
                      },
                    );
                    Future.delayed(Duration(seconds: 1), () {
                      logger.i("Previous step on stepper hit: " +
                          _currentStep.toString());
                    });
                  },
                  steps: [
                    Step(
                      title: Text('Set Specs'),
                      content: Form(
                        key: _formKeys[0],
                        child: Column(
                          children: [
                            InventoryPriceTierDropDown(
                              callback: (newValue) {
                                setState(
                                  () {
                                    priceTierController.text = newValue;
                                  },
                                );
                              },
                            ),
                            InventoryLocationDropDown(
                              callback: (newValue) {
                                if (newValue != null) {
                                  setState(
                                    () {
                                      locationController.text =
                                          newValue["location"];
                                      locationNameController.text =
                                          newValue["name"];
                                    },
                                  );
                                } else {
                                  setState(
                                    () {
                                      locationController.clear();
                                      locationNameController.clear();
                                    },
                                  );
                                }
                              },
                              value: locationController.text,
                            ),
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: getInfoRow(
                                    "S/N",
                                    serialNumberController.text,
                                    serialNumberController,
                                    (serial) {
                                      addToList(serialNumberController.text);
                                      serialNumberController.clear();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 13, 0, 0),
                                  child: IconButton(
                                    icon: Icon(Icons.center_focus_weak),
                                    color: UniversalStyles.actionColor,
                                    onPressed: scanBarcode,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        'Devices to Add: ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        serialList.length.toString(),
                                      ),
                                    ),
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
                              child: Scrollbar(
                                child: buildDLGridView(),
                              ),
                            ),
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
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _currentStep > 0
                        ? ElevatedButton.icon(
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
                        ? ElevatedButton.icon(
                            onPressed: () {
                              if (_currentStep == stepsLength - 1) {
                                added
                                    ? Navigator.pushNamed(context, '/inventory')
                                    : addDevice();
                              } else {
                                Stepper stepper = _stepperKey.currentWidget;
                                stepper.onStepContinue();
                              }
                            },
                            label: Padding(
                              padding: EdgeInsets.all(20),
                              child: _currentStep == stepsLength - 1
                                  ? added
                                      ? Text('Done')
                                      : Text('Save')
                                  : Text('Next'),
                            ),
                            icon: _currentStep == stepsLength - 1
                                ? added
                                    ? Icon(Icons.done)
                                    : Icon(Icons.save)
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
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Inventory add stepper validated");
      });

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
