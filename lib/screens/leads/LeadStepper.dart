import 'dart:developer';

import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';

class LeadStepper extends StatefulWidget {
  final Function successCallback;

  LeadStepper({this.successCallback});

  @override
  LeadStepperState createState() => LeadStepperState();
}

class LeadStepperState extends State<LeadStepper> {
  final _formKey = GlobalKey<FormState>();
  final _stepperKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _currentStep = 0;
    _selectedBusinessType = null;
  }

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

  var _selectedBusinessType;

  var _currentStep = 0;

  var stepsLength = 3;

  var businessTypes = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stepper(
              controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
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
                if (validationPassed()) {
                  setState(() {
                    _currentStep < stepsLength - 1 ? _currentStep += 1 : null;
                  });
                }
              },
              onStepCancel: () {
                if (validationPassed()) {
                  setState(() {
                    _currentStep > 0 ? _currentStep -= 1 : null;
                  });
                }
              },
              steps: [
                Step(
                  title: Text('Contact Info'),
                  content: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: "First Name"),
                        controller: firstNameController,
                        // validator: validate,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Last Name"),
                        controller: lastNameController,
                        // validator: validate,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Email Address"),
                        controller: emailAddrController,
                        // validator: validate,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Phone Number"),
                        controller: phoneNumberController,
                        // validator: validate,
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 0
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: Text('Business Info'),
                  content: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: "Business Name"),
                        controller: businessNameController,
                        // validator: validate,
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: "Doing Business As"),
                        controller: dbaNameController,
                        // validator: validate,
                      ),
                      // TextFormField(
                      //   decoration:
                      //       InputDecoration(labelText: "Business Phone"),
                      //   controller: businessPhoneNumber,
                      //   // validator: validate,
                      // ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: AddressSearch(
                            onAddressChange: (val) => businessAddress = val),
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
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 1
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: Text('Misc Info'),
                  content: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: "Lead Source"),
                        // validator: validate,
                      ),
                    ],
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
                RaisedButton.icon(
                  onPressed: () {
                    if (_currentStep == stepsLength - 1) {
                      addLead();
                    } else {
                      Stepper stepper = _stepperKey.currentWidget;
                      stepper.onStepContinue();
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
                ),
              ],
            ),
          ),
        ],
      ),
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

  void addLead() async {
    try {
      String rawNumber = phoneNumberController.text;
      var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");
      print(filteredNumber);
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
  }
}
