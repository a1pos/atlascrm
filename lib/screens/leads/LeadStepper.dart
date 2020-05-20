import 'dart:developer';
import 'dart:convert';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:flutter/foundation.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LeadStepper extends StatefulWidget {
  final Function successCallback;
  final ApiService apiService = new ApiService();
  LeadStepper({this.successCallback});

  @override
  LeadStepperState createState() => LeadStepperState();
}

class LeadStepperState extends State<LeadStepper> {
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

  final UserService userService = new UserService();
  final ApiService apiService = new ApiService();

  var firstNameController = new TextEditingController();
  var lastNameController = new TextEditingController();
  var emailAddrController = new TextEditingController();
  var phoneNumberController = new TextEditingController();

  var businessNameController = new TextEditingController();
  var dbaNameController = new TextEditingController();
  var businessAddrController = new TextEditingController();
  var businessPhoneNumber = new TextEditingController();

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  var maskFormatter = new MaskTextInputFormatter(
      mask: '###-###-####', filter: {"#": RegExp(r'[0-9]')});
  var _selectedBusinessType;
  var _currentStep = 0;
  var stepsLength = 3;
  var businessTypes = [];

  @override
  void initState() {
    initLeadsData();
    super.initState();
    isSaveDisabled = false;
    _currentStep = 0;
    _selectedBusinessType = null;
  }

  Future<void> initLeadsData() async {
    try {
      var endpoint = "/lead";
      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var leadsArrDecoded = resp.data["data"];
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(() {
                isLoading = false;
                leads = leadsArr;
              });
            } else {
              setState(() {
                isLoading = false;
                leadsArr = [];
              });
            }
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      log(err);
    }
  }

  Future<void> addressCheck(addressObj) async {
    var address = Uri.encodeComponent(addressObj["address"]["address"]);
    var zip = Uri.encodeComponent(addressObj["address"]["zipcode"]);
    var shortAddress =
        Uri.encodeComponent(addressObj["shortaddress"]["address"]);
    try {
      var endpoint = "/lead/address?address=$address&zipCode=$zip";
      var resp = await this.widget.apiService.authGet(context, endpoint);

      var endpoint2 = "/lead/address?address=$shortAddress&zipCode=$zip";
      var resp2 = await this.widget.apiService.authGet(context, endpoint2);

      if (resp != null || resp2 != null) {
        if (resp.statusCode == 200 || resp2.statusCode == 200) {
          if (resp.data["data"].length > 0 || resp2.data["data"].length > 0) {
            setState(() {
              isAddress = false;
              businessNameController.clear();
            });
            dupeLead();
          } else {
            nearbySelect(addressObj);
          }
        }
      }
    } catch (err) {
      log(err);
    }
  }

  Future<void> nearbySelect(addressObj) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                        child: Text("Select a Business",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Divider(),
                      Column(
                        children:
                            addressObj["nearbyResults"].map<Widget>((place) {
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  businessNameController.text = place.name;
                                  businessAddress = addressObj["address"];
                                  isAddress = true;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Card(
                                child: ListTile(
                                  title: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 10, 0),
                                        child: Icon(Icons.business),
                                      ),
                                      Expanded(
                                        child: Text(
                                          place.name,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        }).toList(),
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              businessAddress = addressObj["address"];
                              isAddress = true;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Card(
                            child: ListTile(
                              title: Text("Not Listed",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> dupeLead() async {
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

  Future<void> initBusinessTypes() async {
    try {
      _selectedBusinessType = null;

      var resp = await apiService.authGet(context, "/business/types");
      if (resp != null) {
        if (resp.statusCode == 200) {
          var bizTypesArrDecoded = resp.data;
          if (bizTypesArrDecoded != null) {
            var bizTypesArr = List.from(bizTypesArrDecoded);
            if (bizTypesArr.length > 0) {
              setState(() {
                businessTypes = bizTypesArr;
              });
            }
          }
        }
      }
    } catch (err) {
      log(err);
    }
  }

  Future<void> addLead() async {
    try {
      String rawNumber = phoneNumberController.text;
      var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");
      var lead = {
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "emailAddr": emailAddrController.text,
        "phoneNumber": filteredNumber,
        "businessName": businessNameController.text,
        "dbaName": dbaNameController.text,
        "address": businessAddress["address"],
        "city": businessAddress["city"],
        "state": businessAddress["state"],
        "zipCode": businessAddress["zipcode"]
      };

      var resp = await apiService.authPost(
          context, "/lead/${UserService.employee.employee}", lead);
      if (resp != null) {
        if (resp.statusCode == 200) {
          Navigator.pop(context);

          Fluttertoast.showToast(
              msg: "Successfully added lead!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);

          await this.widget.successCallback();
        }
      } else {
        Fluttertoast.showToast(
            msg: "Failed to add lead!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (err) {
      log(err);
    }
    isSaveDisabled = false;
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
                    if (validationPassed()) {
                      setState(() {
                        _currentStep = step;
                      });
                    }
                  },
                  onStepContinue: () {
                    if (_formKeys[_currentStep].currentState.validate()) {
                      setState(() {
                        _currentStep < stepsLength - 1
                            ? _currentStep += 1
                            : null;
                      });
                    }
                  },
                  onStepCancel: () {
                    if (_formKeys[_currentStep].currentState.validate()) {
                      setState(() {
                        _currentStep > 0 ? _currentStep -= 1 : null;
                      });
                    }
                  },
                  steps: [
                    Step(
                      title: Text('Business Info'),
                      content: Form(
                        key: _formKeys[0],
                        child: !isAddress
                            ? Column(children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 32, 0, 0),
                                  child: AddressSearch(
                                      onAddressChange: (val) {
                                        addressCheck(val);
                                      },
                                      returnNearby: true),
                                ),
                              ])
                            : Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 32, 0, 0),
                                    child: AddressSearch(
                                      onAddressChange: (val) {
                                        addressCheck(val);
                                      },
                                      returnNearby: true,
                                    ),
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: "Business Name"),
                                    controller: businessNameController,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter a business name';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: "Doing Business As"),
                                    controller: dbaNameController,
                                    // validator: validate,
                                  ),
                                  Text(""),
                                  DropdownButton<String>(
                                    items: businessTypes.map((value) {
                                      var dpValue = value["document"]["code"];
                                      var text = value["document"]["typeName"];
                                      return new DropdownMenuItem<String>(
                                        value: dpValue,
                                        child: new Text(text),
                                      );
                                    }).toList(),
                                    hint: Text('Business Type'),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedBusinessType = val;
                                      });
                                    },
                                    isExpanded: true,
                                    value: _selectedBusinessType,
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
                      title: Text('Contact Info'),
                      content: Form(
                        key: _formKeys[1],
                        child: Column(
                          children: [
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: "First Name"),
                              controller: firstNameController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a contact first name';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: "Last Name"),
                              controller: lastNameController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a contact last name';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: "Email Address"),
                              controller: emailAddrController,
                              // validator: validate,
                            ),
                            TextFormField(
                              inputFormatters: [maskFormatter],
                              decoration:
                                  InputDecoration(labelText: "Phone Number"),
                              controller: phoneNumberController,
                              // validator: validate,
                            ),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: Text('Misc Info'),
                      content: Form(
                        key: _formKeys[2],
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: "Lead Source"),
                              // validator: validate,
                            ),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 2
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
                              if (_currentStep == stepsLength - 1 &&
                                  _formKeys[_currentStep]
                                      .currentState
                                      .validate()) {
                                setState(() {
                                  isSaveDisabled = true;
                                });
                                addLead();
                              } else {
                                if (isAddress) {
                                  Stepper stepper = _stepperKey.currentWidget;
                                  stepper.onStepContinue();
                                }
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

  String validate(value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }
}
