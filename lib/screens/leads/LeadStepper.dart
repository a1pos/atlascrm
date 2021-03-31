import 'dart:developer';
import 'dart:async';
import 'package:atlascrm/components/shared/ProcessorDropDown.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:flutter/foundation.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:atlascrm/components/shared/PlacesSuggestions.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LeadStepper extends StatefulWidget {
  final Function successCallback;
  LeadStepper({this.successCallback});

  @override
  LeadStepperState createState() => LeadStepperState();
}

class LeadStepperState extends State<LeadStepper> {
  final _formKey = GlobalKey<FormState>();
  final UserService userService = UserService();
  final _stepperKey = GlobalKey<FormState>();

  bool isSaveDisabled;
  bool isAddress = false;
  bool isLoading = false;

  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  Map businessAddress = {
    "address": "",
    "address2": "",
    "city": "",
    "state": "",
    "zipcode": ""
  };

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailAddrController = TextEditingController();
  var phoneNumberController = MaskedTextController(mask: '000-000-0000');

  var businessNameController = TextEditingController();
  var dbaNameController = TextEditingController();
  var businessAddrController = TextEditingController();
  var businessPhoneNumber = TextEditingController();
  var address2Controller = TextEditingController();
  var processorDropdownValue;

  var _selectedBusinessType;
  var _currentStep = 0;
  var stepsLength = 3;
  var businessTypes = [];
  var locationValue;
  var businessName = "";
  var address = "";
  var address2 = "";
  var phoneNumb = "";
  var leadID;

  @override
  void initState() {
    super.initState();
    isSaveDisabled = false;
    _currentStep = 0;
    _selectedBusinessType = null;
  }

  Future<void> addressCheck(addressObj) async {
    address = addressObj["address"]["address"];
    address2 = addressObj["address2"];

    if (address == null) {
      address = "";
    }

    if (address2Controller.text != null && address2Controller.text != "") {
      address2 = address2Controller.text;
    }

    if (address2 == null) {
      address2 = "";
    }

    if (addressObj["place"] != null) {
      businessName = addressObj["place"].name;
      if (addressObj["place"].formattedPhoneNumber != null &&
          addressObj["place"].formattedPhoneNumber != "") {
        phoneNumb = addressObj["place"]
            .formattedPhoneNumber
            .replaceAll(RegExp("[^0-9]"), "");
      }
    }

    if (phoneNumberController.text != null &&
        phoneNumberController.text != "") {
      phoneNumb = phoneNumberController.text;
    }

    if (phoneNumb == null) {
      phoneNumb = "";
    }

    if (businessNameController.text != null &&
        businessNameController.text != "") {
      businessName = businessNameController.text;
    }

    if (businessName == null) {
      businessName = "";
    }

    try {
      QueryOptions options = QueryOptions(
        documentNode: gql("""
            query GET_EXISTING_LEADS(
              \$address1: String!
              \$address2: String!
              \$phoneNumber: String!
              \$businessName: String!
            ) {
              lead_exist(
                address1: \$address1
                address2: \$address2
                phoneNumber: \$phoneNumber
                businessName: \$businessName
              ){
                isMerchant
                isLead
                isStale
                message
              }
            }
        """),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: {
          "address1": address,
          "address2": address2,
          "phoneNumber": phoneNumb,
          "businessName": businessName
        },
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          var resp = result.data["lead_exist"];

          bool isLead = resp["isLead"];
          bool isMerchant = resp["isMerchant"];
          String message = resp["message"];

          if (isMerchant == true || isLead == true) {
            setState(() {
              isAddress = false;
              businessNameController.clear();
            });

            dupeLead(message);
          } else {
            if (addressObj["place"] != null) {
              if (addressObj["place"].formattedPhoneNumber != null &&
                  addressObj["place"].formattedPhoneNumber != "") {
                phoneNumb = addressObj["place"]
                    .formattedPhoneNumber
                    .replaceAll(RegExp("[^0-9]"), "");

                setState(
                  () {
                    phoneNumberController.updateText(phoneNumb);
                  },
                );
              }
              setState(
                () {
                  businessNameController.text = addressObj["place"].name;
                  locationValue = addressObj["place"].formattedAddress;
                  businessAddress = addressObj["address"];
                  isAddress = true;
                },
              );
            } else {
              setState(
                () {
                  locationValue = addressObj["formattedAddress"];
                  businessNameController.clear();
                  phoneNumberController.clear();
                  businessAddress = addressObj["address"];
                  isAddress = true;
                },
              );
            }
          }
        }
      }
    } catch (err) {
      log(err);
    }
  }

  Future<void> checkBusinessName(name) async {
    var originalBusinessame = name;

    var capitalizedName = capitalizeBusinessName(originalBusinessame);

    try {
      QueryOptions options = QueryOptions(
        documentNode: gql("""
        query GET_LEAD_ADDRESS(\$businessName: String) {
          v_lead(where: {leadbusinessname: {_eq: \$businessName} }) {
            lead
            leadbusinessname
          }
        }
      """),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: {"businessName": capitalizedName},
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          if (result.data["v_lead"].length > 0) {
            var leadUuid = result.data["v_lead"][0]["lead"];

            try {
              QueryOptions options = QueryOptions(
                documentNode: gql("""
                 query GET_BUSINESS_DOC(\$lead: uuid) {
                   lead(where: {lead: {_eq: \$lead } }) {
                     document
                   }
                 }
                """),
                fetchPolicy: FetchPolicy.networkOnly,
                variables: {"lead": leadUuid},
              );

              final QueryResult checkBusinessLead =
                  await GqlClientFactory().authGqlquery(options);

              if (checkBusinessLead.data["lead"].length > 0) {
                if (checkBusinessLead.data["lead"][0]["document"]["address"] ==
                    businessAddress["address"]) {
                  dupeLead("Lead already exists!");
                } else if (checkBusinessLead.data["lead"][0]["document"]
                            ["city"] ==
                        businessAddress["city"] &&
                    checkBusinessLead.data["lead"][0]["document"]["state"] ==
                        businessAddress["state"]) {
                  dupeLead("Lead already exists!");
                } else {
                  nextStep();
                }
              }
            } catch (err) {
              log(err);
            }
          } else {
            nextStep();
          }
        }
      }
    } catch (err) {
      log(err);
    }
  }

  String capitalizeBusinessName(String name) {
    if (name == null) {
      return null;
    }

    if (name.length <= 1) {
      return name.toUpperCase();
    }

    final List<String> names = name.split(' ');

    final capitalizedNames = names.map((bizName) {
      final String firstLetterinName = bizName.substring(0, 1).toUpperCase();
      final String remainingLettersinName = bizName.substring(1);

      return '$firstLetterinName$remainingLettersinName';
    });

    return capitalizedNames.join(' ');
  }

  Future<void> nearbySelect(addressObj) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return PlacesSuggestions(
          addressSearchObj: addressObj,
          onPlaceSelect: (val) {
            if (val != null) {
              if (val["place"] == null) {
                setState(() {
                  locationValue = addressObj["formattedaddr"];
                  businessNameController.clear();
                  phoneNumberController.clear();
                  businessAddress = addressObj["address"];
                  isAddress = true;
                });
              } else {
                addressCheck(val);
              }
            }
          },
        );
      },
    );
  }

  Future<void> dupeLead(message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Lead'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
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

  Future<void> addLead() async {
    try {
      String rawNumber = phoneNumberController.text;
      var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");

      var leadInfo = {
        "employee": UserService.employee.employee,
        "is_active": true,
        "processor": processorDropdownValue,
        "document": {
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "emailAddr": emailAddrController.text,
          "phoneNumber": filteredNumber,
          "businessName": businessNameController.text,
          "dbaName": dbaNameController.text,
          "address": businessAddress["address"],
          "address2": businessAddress["address2"],
          "city": businessAddress["city"],
          "state": businessAddress["state"],
          "zipCode": businessAddress["zipcode"]
        },
      };

      MutationOptions mutateOptions = MutationOptions(
        documentNode: gql("""
        mutation INSERT_LEADS(\$objects: [lead_insert_input!]!) {
          insert_lead(objects: \$objects) {
            returning {
            document
            }
          }
        }
      """),
        variables: {"objects": leadInfo},
      );

      final QueryResult result =
          await GqlClientFactory().authGqlmutate(mutateOptions);

      if (result.hasException == false) {
        Navigator.popAndPushNamed(context, "/leads");

        Fluttertoast.showToast(
            msg: "Successfully added lead!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);

        await this.widget.successCallback();
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

  void nextStep() {
    setState(
      () {
        _currentStep < stepsLength - 1 ? _currentStep += 1 : null;
      },
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
                    if (validationPassed()) {
                      setState(
                        () {
                          _currentStep = step;
                        },
                      );
                    }
                  },
                  onStepContinue: () async {
                    if (_formKeys[_currentStep].currentState.validate()) {
                      if (_currentStep == 0) {
                        checkBusinessName(businessName);
                      } else {
                        nextStep();
                      }
                    }
                  },
                  onStepCancel: () {
                    if (_formKeys[_currentStep].currentState.validate()) {
                      setState(
                        () {
                          _currentStep > 0 ? _currentStep -= 1 : null;
                        },
                      );
                    }
                  },
                  steps: [
                    Step(
                      title: Text('Business Info'),
                      content: Form(
                        key: _formKeys[0],
                        child: !isAddress
                            ? Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 32, 0, 0),
                                    child: AddressSearch(
                                      onAddressChange: (val) {
                                        nearbySelect(val);
                                      },
                                      returnNearby: true,
                                      locationValue: locationValue,
                                    ),
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: "Address 2 (optional)",
                                    ),
                                    controller: address2Controller,
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 32, 0, 0),
                                    child: AddressSearch(
                                      onAddressChange: (val) {
                                        nearbySelect(val);
                                      },
                                      returnNearby: true,
                                      locationValue: locationValue,
                                    ),
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: "Address 2 (optional)"),
                                    controller: address2Controller,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: "Business Name"),
                                    controller: businessNameController,
                                    validator: (value) {
                                      businessName = value;
                                      if (value.isEmpty) {
                                        return 'Please enter a business name';
                                      }
                                      return null;
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ProcessorDropDown(
                                      value: processorDropdownValue,
                                      callback: ((val) {
                                        setState(() {
                                          processorDropdownValue = val;
                                        });
                                      }),
                                    ),
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: "Doing Business As"),
                                    controller: dbaNameController,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: "Phone Number"),
                                    controller: phoneNumberController,
                                  ),
                                  // DropdownButton<String>(
                                  //   items: businessTypes.map((value) {
                                  //     var dpValue = value["document"]["code"];
                                  //     var text = value["document"]["typeName"];
                                  //     return new DropdownMenuItem<String>(
                                  //       value: dpValue,
                                  //       child: new Text(text),
                                  //     );
                                  //   }).toList(),
                                  //   hint: Text('Business Type'),
                                  //   onChanged: (val) {
                                  //     setState(() {
                                  //       _selectedBusinessType = val;
                                  //     });
                                  //   },
                                  //   isExpanded: true,
                                  //   value: _selectedBusinessType,
                                  // ),
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
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: "Email Address"),
                              controller: emailAddrController,
                              validator: (value) {
                                if (value.isNotEmpty && !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
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
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please Enter an Address!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.grey[600],
                                      textColor: Colors.white,
                                      fontSize: 16.0);
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
