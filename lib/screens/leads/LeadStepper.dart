import 'dart:async';
import 'package:round2crm/components/shared/ProcessorDropDown.dart';
import 'package:round2crm/components/shared/CompanyDropDown.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:round2crm/components/shared/AddressSearch.dart';
import 'package:flutter/foundation.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:round2crm/components/shared/PlacesSuggestions.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

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
  bool nextButtonDisabled = true;
  bool placeSelect = false;
  bool visible = false;
  bool validStreetAddress = true;

  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  List<Step> steps;

  Map businessAddress = {
    "address": "",
    "address2": "",
    "city": "",
    "state": "",
    "zipcode": ""
  };

  Map addressInfoCheck = {
    "address": "",
    "address2": "",
    "city": "",
    "state": "",
    "zipcode": ""
  };

  Map mixedReplyCheck = {
    "address": "",
    "place": "",
    "shortAddress": "",
  };

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  String formattedAddressCheck;
  var shortAddressCheck;

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailAddrController = TextEditingController();
  var phoneNumberController = MaskedTextController(mask: '000-000-0000');

  var companyController = TextEditingController();
  var companyNameController = TextEditingController();

  var businessNameController = TextEditingController();
  var dbaNameController = TextEditingController();
  var businessAddrController = TextEditingController();
  var businessPhoneNumber = TextEditingController();
  var address1Controller = TextEditingController();
  var address2Controller = TextEditingController();
  var manualAddress2Controller = TextEditingController();
  var cityController = TextEditingController();
  var stateController = TextEditingController();
  var zipController = TextEditingController();

  var processorDropdownValue;

  var _currentStep = 0;
  var stepsLength = 2;
  var businessTypes = [];
  var locationValue;
  var businessName = "";
  var address = "";
  var address2 = "";
  var shortAddress = "";
  var phoneNumb = "";
  var leadID;

  @override
  void initState() {
    super.initState();
    isSaveDisabled = false;
    _currentStep = 0;
  }

  Future<void> addressCheck(addressObj) async {
    address = addressObj["address"]["address"];
    address2 = addressObj["address"]["address2"];
    shortAddress = addressObj["address"]["shortAddress"];

    if (address == null && shortAddress == null) {
      address = "";
    } else if (address == null && shortAddress != null) {
      address = shortAddress;
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
    } else {
      businessName = businessNameController.text.trim();
      phoneNumb = phoneNumberController.text;
    }

    if (phoneNumb == null) {
      phoneNumb = "";
    }

    try {
      QueryOptions options = QueryOptions(
        document: gql("""
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
              nextButtonDisabled = true;
              businessNameController.clear();
              phoneNumberController.clear();
              address2Controller.clear();
              processorDropdownValue = null;
              locationValue = "";
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
                  address2Controller.text = addressObj["address"]["address2"];
                  isAddress = true;
                  nextButtonDisabled = false;
                },
              );
              logger.i(
                  "Location value field set to: " + locationValue.toString());
            } else {
              setState(
                () {
                  locationValue = addressInfoCheck["formattedaddr"];
                  businessNameController.text = businessName;
                  businessAddress = addressObj["address"];

                  if (phoneNumb != "" && phoneNumb != null) {
                    phoneNumb = phoneNumb.replaceAll(RegExp("[^0-9]"), "");
                    phoneNumberController.updateText(phoneNumb);
                  }

                  isAddress = true;
                  nextButtonDisabled = false;

                  nextStep();
                },
              );

              logger.i(
                  "Location value field set to: " + locationValue.toString());
            }
          }
        } else {
          debugPrint(
              "Error checking existing lead: " + result.exception.toString());
          logger.e("Error existing lead: " + result.exception.toString());
        }
      }
    } catch (err) {
      debugPrint("Error checking existing lead: " + err.exception.toString());
      logger.e("Error existing lead: " + err.exception.toString());
    }
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
                  formattedAddressCheck = val["formattedaddr"];
                  addressInfoCheck = {
                    "address": val["address"]["address"],
                    "city": val["address"]["city"],
                    "state": val["address"]["state"],
                    "zipcode": val["address"]["zipcode"],
                    "address2": val["address"]["address2"]
                  };
                  shortAddressCheck = val["shortaddress"];

                  mixedReplyCheck = {
                    "address": addressInfoCheck,
                    "place": null,
                    "shortAddress": shortAddressCheck
                  };

                  locationValue = addressObj["formattedaddr"];
                  businessNameController.clear();
                  phoneNumberController.clear();
                  businessAddress = addressObj["address"];
                  placeSelect = false;
                  isAddress = true;
                  nextButtonDisabled = false;
                  visible = false;
                  validStreetAddress = true;
                });
                logger.i(
                    "Location value field set to: " + locationValue.toString());
                logger.i(
                    "Place suggestions did not return a place, address check manually built: " +
                        mixedReplyCheck.toString());
              } else {
                if (val["address"]["address"] == "") {
                  setState(
                    () {
                      locationValue = "";
                      cityController.text = val["address"]["city"];
                      stateController.text = val["address"]["state"];
                      zipController.text = val["address"]["zipcode"];
                      manualAddress2Controller.text =
                          val["address"]["address2"];
                      businessNameController.text = val["place"].name;
                      phoneNumberController
                          .updateText(val["place"].formattedPhoneNumber);
                      isAddress = true;
                      visible = true;
                      validStreetAddress = false;
                      placeSelect = true;
                      nextButtonDisabled = false;
                    },
                  );
                  logger.i("Location value field set to: " +
                      locationValue.toString());
                  logger.i(
                    "No verified address returned, requesting business address to be input manually",
                  );
                  Fluttertoast.showToast(
                    msg:
                        "No verified address found, please input business address",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.grey[600],
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  visible = false;
                  validStreetAddress = true;

                  placeSelect = true;
                  addressCheck(val);
                }
              }
            } else {
              debugPrint("Place suggestion from Google did not return a value");
              logger.e("Place suggestion from Google did not return a value");
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
        logger.i("Duplicate lead caught: " + message.toString());
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
            TextButton(
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
      String businessNameTrim = businessNameController.text.trim();
      String firstName = firstNameController.text.trim();
      String lastName = lastNameController.text.trim();
      var company = companyController.text;

      String rawNumber = phoneNumberController.text.trim();
      var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");

      if (lastName != "" && lastName == null) {
        lastName = "";
      }

      var leadInfo = {
        "employee": UserService.employee.employee,
        "is_active": true,
        "processor": processorDropdownValue,
        "document": {
          "firstName": firstName,
          "lastName": lastName,
          "emailAddr": emailAddrController.text.trim(),
          "phoneNumber": filteredNumber,
          "businessName": businessNameTrim,
          "dbaName": dbaNameController.text.trim(),
          "address": businessAddress["address"],
          "address2": businessAddress["address2"],
          "city": businessAddress["city"],
          "state": businessAddress["state"],
          "zipCode": businessAddress["zipcode"],
        },
      };

      if (UserService.isAdmin) {
        leadInfo["company"] = company;
      }

      MutationOptions mutateOptions = MutationOptions(
        document: gql("""
                mutation INSERT_LEADS(\$objects: [lead_insert_input!]!) {
                  insert_lead(objects: \$objects) {
                    returning {
                    document
                    }
                  }
                }
              """),
        fetchPolicy: FetchPolicy.noCache,
        variables: {
          "objects": leadInfo,
        },
      );

      final QueryResult result =
          await GqlClientFactory().authGqlmutate(mutateOptions);

      if (result.hasException == false) {
        Navigator.popAndPushNamed(context, "/leads");

        logger.i("Successfully added lead: " + businessNameTrim.toString());
        Fluttertoast.showToast(
            msg: "Successfully added lead!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);

        await this.widget.successCallback();
      } else {
        debugPrint("Failed to add lead: " + result.exception.toString());
        logger.e("Failed to add lead: " + result.exception.toString());

        Fluttertoast.showToast(
            msg: "Failed to add lead: " + result.exception.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          isSaveDisabled = false;
        });
      }
    } catch (err) {
      debugPrint("Failed to add lead: " + err.toString());
      logger.e("Failed to add lead: " + err.toString());
    }
    isSaveDisabled = false;
  }

  void nextStep() {
    if (nextButtonDisabled == false) {
      setState(
        () {
          _currentStep < stepsLength - 1 ? _currentStep += 1 : null;
        },
      );
      logger.i("Next step tapped: " + _currentStep.toString());
    }
  }

  List<Step> _buildSteps() {
    steps = [
      Step(
        title: Text('Business Info'),
        content: Form(
          key: _formKeys[0],
          child: !isAddress
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: AddressSearch(
                        onAddressChange: (val) {
                          logger.i(
                              "Address returned from Google address search: " +
                                  val.toString());
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
                    ),
                  ],
                )
              : Column(
                  children: [
                    Visibility(
                      visible: validStreetAddress,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: visible,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Address 1",
                            ),
                            controller: address1Controller,
                            validator: (value) {
                              if (value.isEmpty) {
                                logger.i("No address 1 entered");
                                return 'Please enter an address 1';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.words,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Address 2 (optional)",
                            ),
                            controller: manualAddress2Controller,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "City",
                            ),
                            controller: cityController,
                            validator: (value) {
                              if (value.isEmpty) {
                                logger.i("No city entered");
                                return 'Please enter a city';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.words,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "State",
                            ),
                            controller: stateController,
                            validator: (value) {
                              if (value.isEmpty) {
                                logger.i("No state entered");
                                return 'Please enter a state';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.characters,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "ZIP Code",
                            ),
                            controller: zipController,
                            validator: (value) {
                              if (value.isEmpty) {
                                logger.i("No zip code entered");
                                return 'Please enter a zip';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Business Name"),
                      controller: businessNameController,
                      validator: (value) {
                        businessName = value;
                        if (value.isEmpty) {
                          logger.i("No business name entered");
                          return 'Please enter a business name';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ProcessorDropDown(
                        value: processorDropdownValue,
                        callback: ((val) {
                          logger.i("Processor changed: " + val.toString());
                          setState(() {
                            processorDropdownValue = val;
                          });
                        }),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Doing Business As",
                      ),
                      controller: dbaNameController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                      ),
                      controller: phoneNumberController,
                    ),
                  ],
                ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
      ),
      Step(
        title: Text('Contact Info'),
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "First Name"),
                controller: firstNameController,
                validator: (value) {
                  if (value.isEmpty || value.trim() == "") {
                    firstNameController.clear();
                    logger.i("No contact first name entered");
                    return 'Please enter a contact first name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Last Name"),
                controller: lastNameController,
                textCapitalization: TextCapitalization.words,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Email Address"),
                controller: emailAddrController,
                validator: (value) {
                  if (value.isNotEmpty && !value.contains('@')) {
                    logger.i("No valid email entered");
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              UserService.isAdmin
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: CompanyDropDown(
                        callback: (newValue) {
                          if (newValue != null) {
                            logger.i("Company value changed: " +
                                newValue["name"].toString());
                            setState(
                              () {
                                companyController.text = newValue["id"];
                                companyNameController.text = newValue["name"];
                              },
                            );
                          }
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
      ),
      Step(
        title: Text('Misc Info'),
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: "Lead Source"),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
      ),
    ];

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CenteredLoadingSpinner()
        : Column(
            children: <Widget>[
              Expanded(
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Stepper(
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
                            if (placeSelect == false) {
                              addressCheck(mixedReplyCheck);
                            } else if (visible == true) {
                              addressInfoCheck = {
                                "address": address1Controller.text,
                                "address2": manualAddress2Controller.text,
                                "city": cityController.text,
                                "state": stateController.text,
                                "zipcode": zipController.text,
                              };
                              mixedReplyCheck = {
                                "address": addressInfoCheck,
                                "place": null,
                                "shortaddress": null
                              };
                              addressCheck(mixedReplyCheck);
                            } else {
                              nextStep();
                            }
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

                          logger.i("Previous step tapped: " +
                              _currentStep.toString());
                        }
                      },
                      steps: _buildSteps(),
                    );
                  },
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _currentStep >= 1
                        ? ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                Stepper stepper = _stepperKey.currentWidget;
                                stepper.onStepCancel();
                              });
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
                                  debugPrint("No address entered");
                                  logger.i("No address entered");
                                  Fluttertoast.showToast(
                                    msg: "Please Enter an Address!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey[600],
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              }
                            },
                            label: Padding(
                              padding: EdgeInsets.all(20),
                              child: _currentStep == stepsLength
                                  ? Text('Save')
                                  : Text('Next'),
                            ),
                            icon: _currentStep == stepsLength
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
