import 'dart:async';
import 'dart:developer';

import 'package:atlascrm/components/agreement/SicDropdown.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class BusinessInfo extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map isDirtyStatus;
  final Map controllers;
  final agreementDoc;
  final GlobalKey formKey;
  final Map validationErrors;
  final Map isValid;

  BusinessInfo(
      {this.controllers,
      this.agreementDoc,
      this.isDirtyStatus,
      this.formKey,
      this.validationErrors,
      this.isValid});

  @override
  BusinessInfoState createState() => BusinessInfoState();
}

class Item {
  Item(
      {this.expandedValue,
      this.headerValue,
      this.isExpanded = false,
      this.contentCard = const Text("nocontent")});

  String expandedValue;
  String headerValue;
  bool isExpanded;
  Widget contentCard;
}

List<Item> ownerList = [
  Item(
      expandedValue: "Owner 1",
      headerValue: "Owner 1 text",
      contentCard: Card(
          child: Column(children: <Widget>[
        TextField(),
        TextField(),
        TextField(),
        TextField(),
      ]))),
  Item(expandedValue: "Owner 2", headerValue: "Owner 2 text")
];

class BusinessInfoState extends State<BusinessInfo>
    with TickerProviderStateMixin {
  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  var agreementBuilder;
  var agreementDocument;
  var lead;
  var leadDocument;
  var addressText;
  var isLoading = true;
  List owners;
  Map testOwner;
  Map emptyOwner;
  List<Widget> displayList;
  var stateInc = [
    {"value": "AL", "name": "Alabama"},
    {"value": "AK", "name": "Alaska"},
    {"value": "AZ", "name": "Arizona"},
    {"value": "AR", "name": "Arkansas"},
    {"value": "CA", "name": "California"},
    {"value": "CO", "name": "Colorado"},
    {"value": "CT", "name": "Connecticut"},
    {"value": "DE", "name": "Delaware"},
    {"value": "DC", "name": "District Of Columbia"},
    {"value": "FL", "name": "Florida"},
    {"value": "GA", "name": "Georgia"},
    {"value": "HI", "name": "Hawaii"},
    {"value": "ID", "name": "Idaho"},
    {"value": "IL", "name": "Illinois"},
    {"value": "IN", "name": "Indiana"},
    {"value": "IA", "name": "Iowa"},
    {"value": "KS", "name": "Kansas"},
    {"value": "KY", "name": "Kentucky"},
    {"value": "LA", "name": "Louisiana"},
    {"value": "ME", "name": "Maine"},
    {"value": "MD", "name": "Maryland"},
    {"value": "MA", "name": "Massachusetts"},
    {"value": "MI", "name": "Michigan"},
    {"value": "MN", "name": "Minnesota"},
    {"value": "MS", "name": "Mississippi"},
    {"value": "MO", "name": "Missouri"},
    {"value": "MT", "name": "Montana"},
    {"value": "NE", "name": "Nebraska"},
    {"value": "NV", "name": "Nevada"},
    {"value": "NH", "name": "New Hampshire"},
    {"value": "NJ", "name": "New Jersey"},
    {"value": "NM", "name": "New Mexico"},
    {"value": "NY", "name": "New York"},
    {"value": "NC", "name": "North Carolina"},
    {"value": "ND", "name": "North Dakota"},
    {"value": "OH", "name": "Ohio"},
    {"value": "OK", "name": "Oklahoma"},
    {"value": "OR", "name": "Oregon"},
    {"value": "PA", "name": "Pennsylvania"},
    {"value": "RI", "name": "Rhode Island"},
    {"value": "SC", "name": "South Carolina"},
    {"value": "SD", "name": "South Dakota"},
    {"value": "TN", "name": "Tennessee"},
    {"value": "TX", "name": "Texas"},
    {"value": "UT", "name": "Utah"},
    {"value": "VT", "name": "Vermont"},
    {"value": "VA", "name": "Virginia"},
    {"value": "WA", "name": "Washington"},
    {"value": "WV", "name": "West Virginia"},
    {"value": "WI", "name": "Wisconsin"},
    {"value": "WY", "name": "Wyoming"},
  ];
  var yesNoOptions = [
    {"value": "0", "name": "No"},
    {"value": "1", "name": "Yes"}
  ];
  var retrievalFaxRpt = [
    {"value": "4", "name": "3 - Mail Merchant"},
    {"value": "6", "name": "5 - Dispute Manager"},
    {"value": "8", "name": "7 - Dispute Manager and Fax"},
    {"value": "7", "name": "6 - Dispute Manager and Mail"}
  ];
  var businessTypes = [
    {"value": "1", "name": "Sole Proprietorship"},
    {"value": "2", "name": "Private Partnership"},
    {"value": "3", "name": "Private Corp"},
    {"value": "4", "name": "Public Corp"},
    {"value": "5", "name": "Association/Estate/Trust"},
    {"value": "6", "name": "Tax Exempt Organization"},
    {"value": "7", "name": "Private Limited Liability Company"},
    {"value": "8", "name": "International Organization"},
    {"value": "9", "name": "Government"},
    {"value": "10", "name": "Publicly Traded Partnership"},
    {"value": "11", "name": "Publicly Traded Limited Liability Company"},
  ];
  var statementHoldRefValue = [
    {"value": "1", "name": "N - Hard copy statement to merchant"},
    {"value": "2", "name": "S - Do not print hard copy"},
    {"value": "3", "name": "Y - Hard copy statement to acquire"}
  ];
  var sendLocations = [
    {"value": "1", "name": "Business Location"},
    {"value": "2", "name": "Corporate/Legal Address"},
  ];
  var businessCategory = [
    {"value": "1", "name": "Retail"},
    {"value": "2", "name": "Restaurant"},
    {"value": "3", "name": "Hotel"},
    {"value": "4", "name": "MOTO"},
    {"value": "5", "name": "B to B(Purchase Card)"},
    {"value": "6", "name": "Fuel(Automated Fuel Dispenser)"},
    {"value": "7", "name": "Gas Station"},
    {"value": "8", "name": "Car Rental"},
    {"value": "9", "name": "Supermarket"}
  ];
  var fedTaxIdType = [
    {"value": "1", "name": "SSN"},
    {"value": "2", "name": "EIN"},
  ];
  var zones = [
    {"value": "1", "name": "Business District"},
    {"value": "2", "name": "Industrial"},
    {"value": "3", "name": "Residential"},
  ];
  var locations = [
    {"value": "1", "name": "Mall"},
    {"value": "2", "name": "Shopping Area"},
    {"value": "3", "name": "Home"},
    {"value": "4", "name": "Office"},
    {"value": "5", "name": "Apt"},
    {"value": "6", "name": "Isolated"},
    {"value": "7", "name": "DoortoDoor"},
    {"value": "8", "name": "FleaMarket"},
    {"value": "9", "name": "Other"}
  ];
  var merchantNameDisplay = [
    {"value": "1", "name": "Door"},
    {"value": "2", "name": "Window"},
    {"value": "3", "name": "Store Front"},
  ];
  var storeLocatedOn = [
    {"value": "1", "name": "Ground Floor"},
    {"value": "2", "name": "Other"},
  ];
  var numOfLevels = [
    {"value": "1", "name": "1"},
    {"value": "2", "name": "2-4"},
    {"value": "3", "name": "5-10"},
    {"value": "4", "name": "11+"},
  ];
  var otherOccupiedBy = [
    {"value": "1", "name": "(None)"},
    {"value": "2", "name": "Residential"},
    {"value": "3", "name": "Commercial"},
    {"value": "4", "name": "Combo"},
  ];
  var squareFootage = [
    {"value": "1", "name": "250"},
    {"value": "2", "name": "250-500"},
    {"value": "3", "name": "501-2000"},
    {"value": "4", "name": "2000+"},
  ];
  var returnPolicy = [
    {"value": "1", "name": "Full Refund"},
    {"value": "2", "name": "Exchange Only"},
    {"value": "3", "name": "None"},
  ];
  var refundType = [
    {"value": "1", "name": "Exchange"},
    {"value": "2", "name": "Store Credit"},
    {"value": "3", "name": "Cash"},
  ];
  var refDays = [
    {"value": "1", "name": "0-3 Days"},
    {"value": "2", "name": "4-7 Days"},
    {"value": "3", "name": "8-14 Days"},
    {"value": "4", "name": "14+ Days"},
  ];
  var ccProcessedAt = [
    {"value": "1", "name": "Date of Order"},
    {"value": "2", "name": "Date of Delivery"},
    {"value": "3", "name": "Other"},
  ];

  final businessKey = GlobalKey<FormState>();
  void initState() {
    super.initState();
    checkAddresses();
  }

  bool corpAddressError = false;
  bool businessAddressError = false;

  Future<void> checkAddresses() async {
    if (this.widget.controllers["general"]["corpSame"].text == "true" &&
        this.widget.controllers["corporateInfo"]["Address1"].text != "") {
      setSameAddress();
    }

    if (this.widget.controllers["businessInfo"]["LocationAddress1"].text ==
        "") {
      setState(() {
        businessAddressError = true;
      });
    } else {
      setState(() {
        businessAddressError = false;
      });
    }

    if (this.widget.controllers["corporateInfo"]["Address1"].text == "") {
      setState(() {
        corpAddressError = true;
      });
    } else {
      setState(() {
        corpAddressError = false;
      });
    }
  }

  Future<void> setCorpAddress(address) async {
    setState(() {
      this.widget.controllers["corporateInfo"]["Address1"].text =
          address["address"];

      this.widget.controllers["corporateInfo"]["City"].text = address["city"];

      this.widget.controllers["corporateInfo"]["State"].text = address["state"];

      this.widget.controllers["corporateInfo"]["First5Zip"].text =
          address["zipcode"];
      this.widget.isDirtyStatus["businessInfoIsDirty"] = true;
    });
    if (this.widget.controllers["general"]["corpSame"].text == "true") {
      setBusinessAddress(address);
    }
  }

  Future<void> setSameAddress() async {
    setState(() {
      this.widget.controllers["businessInfo"]["LocationAddress1"].text =
          this.widget.controllers["corporateInfo"]["Address1"].text;
      this.widget.controllers["businessInfo"]["City"].text =
          this.widget.controllers["corporateInfo"]["City"].text;

      this.widget.controllers["businessInfo"]["State"].text =
          this.widget.controllers["corporateInfo"]["State"].text;

      this.widget.controllers["businessInfo"]["First5Zip"].text =
          this.widget.controllers["corporateInfo"]["First5Zip"].text;
      this.widget.isDirtyStatus["businessInfoIsDirty"] = true;
    });
    setState(() {});
  }

  Future<void> setBusinessAddress(address) async {
    setState(() {
      this.widget.controllers["businessInfo"]["LocationAddress1"].text =
          address["address"];

      this.widget.controllers["businessInfo"]["City"].text = address["city"];

      this.widget.controllers["businessInfo"]["State"].text = address["state"];

      this.widget.controllers["businessInfo"]["First5Zip"].text =
          address["zipcode"];
      this.widget.isDirtyStatus["businessInfoIsDirty"] = true;
    });
  }

  String validateRow(newVal, errorLocation, errorName, {message}) {
    if (this.widget.validationErrors != null) {
      if (this.widget.validationErrors["$errorLocation"] != null) {
        if (this.widget.validationErrors["$errorLocation"]["$errorName"] !=
            null) {
          return this
              .widget
              .validationErrors["$errorLocation"]["$errorName"]
              .toString();
        }
      }
    }
    if (newVal.isEmpty) {
      return message != null ? message : "Required";
    } else {
      return null;
    }
  }

  String validateAddedRows(newVal, errorLocation, errorName, {message}) {
    if (this.widget.validationErrors != null) {
      if (this.widget.validationErrors["$errorLocation"] != null) {
        if (this.widget.validationErrors["$errorLocation"]["$errorName"] !=
            null) {
          return this
              .widget
              .validationErrors["$errorLocation"]["$errorName"]
              .toString();
        }
      }
    }
    var valPos = int.parse(
        this.widget.controllers["motoBBInet"]["TransDeliveredIn07"].text != ""
            ? this.widget.controllers["motoBBInet"]["TransDeliveredIn07"].text
            : "0");
    var valInet = int.parse(
        this.widget.controllers["motoBBInet"]["TransDeliveredIn814"].text != ""
            ? this.widget.controllers["motoBBInet"]["TransDeliveredIn814"].text
            : "0");
    var valMo = int.parse(
        this.widget.controllers["motoBBInet"]["TransDeliveredIn1530"].text != ""
            ? this.widget.controllers["motoBBInet"]["TransDeliveredIn1530"].text
            : "0");
    var valTo = int.parse(
        this.widget.controllers["motoBBInet"]["TransDeliveredOver30"].text != ""
            ? this.widget.controllers["motoBBInet"]["TransDeliveredOver30"].text
            : "0");
    var currentTotal = valPos + valInet + valMo + valTo;
    if (currentTotal != 100) {
      return "Values must add up to 100";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    agreementDocument = this.widget.agreementDoc;
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        child: Form(
          autovalidate: true,
          onChanged: () {
            // this.widget.isValid["BusinessInfo"] =
            //     businessKey.currentState.validate();
            checkAddresses();
            setState(() {
              this.widget.isDirtyStatus["businessInfoIsDirty"] = true;
            });
          },
          key: businessKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomCard(
                key: Key("businessInfo1"),
                icon: Icons.business,
                title: "MPA/ Corporate Info",
                child: Column(
                  children: <Widget>[
                    getInfoRow(
                        "Merchant DBA Name",
                        this
                            .widget
                            .controllers["mpaInfo"]["ClientDbaName"]
                            .text,
                        this.widget.controllers["mpaInfo"]["ClientDbaName"],
                        validator: (newVal) =>
                            validateRow(newVal, "MpaInfo", "ClientDbaName")),
                    getInfoRow(
                        "Merchant's Corporate/Legal Name",
                        this
                            .widget
                            .controllers["corporateInfo"]["LegalName"]
                            .text,
                        this.widget.controllers["corporateInfo"]["LegalName"],
                        validator: (newVal) =>
                            validateRow(newVal, "CorporateInfo", "LegalName")),
                    getInfoRow(
                        "Number of Locations",
                        this
                            .widget
                            .controllers["mpaInfo"]["NumberOfLocation"]
                            .text,
                        this.widget.controllers["mpaInfo"]["NumberOfLocation"],
                        mask: "000",
                        validator: (newVal) =>
                            validateRow(newVal, "MpaInfo", "NumberOfLocation")),
                    getInfoSearchableDropdown(
                        "State Incorporated",
                        this
                            .widget
                            .controllers["corporateInfo"]["StateIncorporated"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["StateIncorporated"],
                        stateInc, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    // getInfoDropdown(
                    //     "Statement Provided",
                    //     this.widget.controllers["CurrentStmntProvided"].text,
                    //     this.widget.controllers["CurrentStmntProvided"],
                    //     yesNoOptions),
                    getInfoDropdown(
                        "Retrieval Fax Rpt Code",
                        this
                            .widget
                            .controllers["corporateInfo"]
                                ["RetrievalFaxRptCodeRefValue"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["RetrievalFaxRptCodeRefValue"],
                        retrievalFaxRpt, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoRow(
                        "Corporate Contact",
                        this
                            .widget
                            .controllers["corporateInfo"]["CorporateContact"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["CorporateContact"],
                        validator: (newVal) => validateRow(
                            newVal, "CorporateInfo", "CorporateContact")),
                    getInfoRow(
                        "Business Start Date",
                        this
                            .widget
                            .controllers["corporateInfo"]["BusinessStartDate"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["BusinessStartDate"],
                        mask: "00/00/0000",
                        validator: (newVal) => validateRow(
                            newVal, "CorporateInfo", "BusinessStartDate",
                            message: "Required Format MM/DD/YYYY")),
                    getInfoDropdown(
                        "Business Type",
                        this
                            .widget
                            .controllers["corporateInfo"]["BusinessType"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["BusinessType"],
                        businessTypes, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Statement Hold",
                        this
                            .widget
                            .controllers["corporateInfo"]
                                ["StatementHoldRefValue"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["StatementHoldRefValue"],
                        statementHoldRefValue, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Corporate Address:',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: AddressSearch(
                                  locationValue: (this
                                                  .widget
                                                  .controllers["corporateInfo"]
                                                      ["Address1"]
                                                  .text !=
                                              null &&
                                          this
                                                  .widget
                                                  .controllers["corporateInfo"]
                                                      ["Address1"]
                                                  .text !=
                                              "")
                                      ? this
                                              .widget
                                              .controllers["corporateInfo"]
                                                  ["Address1"]
                                              .text +
                                          ", " +
                                          this
                                              .widget
                                              .controllers["corporateInfo"]
                                                  ["City"]
                                              .text +
                                          ", " +
                                          this
                                              .widget
                                              .controllers["corporateInfo"]
                                                  ["State"]
                                              .text +
                                          ", " +
                                          this
                                              .widget
                                              .controllers["corporateInfo"]
                                                  ["First5Zip"]
                                              .text
                                      : null,
                                  onAddressChange: (val) {
                                    setCorpAddress(val);
                                    checkAddresses();
                                  },
                                  lineColor:
                                      corpAddressError ? Colors.red : null),
                            ),
                            corpAddressError
                                ? Icon(Icons.error, color: Colors.red)
                                : Container()
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                            child: Text(
                                "Business Address is the same as Corporate Address")),
                        Checkbox(
                            value: this
                                        .widget
                                        .controllers["general"]["corpSame"]
                                        .text ==
                                    "true"
                                ? true
                                : false,
                            onChanged: (val) {
                              setSameAddress();
                              setState(() {
                                this
                                    .widget
                                    .controllers["corporateInfo"]
                                        ["SendMonthlyStmntTo"]
                                    .text = "1";
                                this
                                    .widget
                                    .controllers["corporateInfo"]
                                        ["SendRetRequestTo"]
                                    .text = "1";
                                this
                                    .widget
                                    .controllers["corporateInfo"]["SendCBTo"]
                                    .text = "1";
                                this
                                    .widget
                                    .controllers["general"]["corpSame"]
                                    .text = val.toString();
                                print(this
                                    .widget
                                    .controllers["general"]["corpSame"]
                                    .text);
                                this
                                        .widget
                                        .isDirtyStatus["businessInfoIsDirty"] =
                                    true;
                              });
                            }),
                      ],
                    ),
                    this.widget.controllers["general"]["corpSame"].text ==
                            "true"
                        ? Container()
                        : Container(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
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
                                        locationValue: (this
                                                        .widget
                                                        .controllers["businessInfo"]
                                                            ["LocationAddress1"]
                                                        .text !=
                                                    null &&
                                                this
                                                        .widget
                                                        .controllers[
                                                            "businessInfo"]
                                                            ["LocationAddress1"]
                                                        .text !=
                                                    "")
                                            ? this
                                                    .widget
                                                    .controllers["businessInfo"]
                                                        ["LocationAddress1"]
                                                    .text +
                                                ", " +
                                                this
                                                    .widget
                                                    .controllers["businessInfo"]
                                                        ["City"]
                                                    .text +
                                                ", " +
                                                this
                                                    .widget
                                                    .controllers["businessInfo"]
                                                        ["State"]
                                                    .text +
                                                ", " +
                                                this
                                                    .widget
                                                    .controllers["businessInfo"]
                                                        ["First5Zip"]
                                                    .text
                                            : null,
                                        onAddressChange: (val) {
                                          setBusinessAddress(val);
                                          checkAddresses();
                                        },
                                        lineColor: businessAddressError
                                            ? Colors.red
                                            : null),
                                  ),
                                  businessAddressError == true
                                      ? Icon(Icons.error, color: Colors.red)
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                    getInfoDropdown(
                        "Send Monthly Statements To",
                        this
                            .widget
                            .controllers["corporateInfo"]["SendMonthlyStmntTo"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["SendMonthlyStmntTo"],
                        sendLocations,
                        disabled: this
                                    .widget
                                    .controllers["general"]["corpSame"]
                                    .text ==
                                "true"
                            ? true
                            : false, validator: (newVal) {
                      if (this.widget.controllers["general"]["corpSame"].text ==
                          "true") {
                        return null;
                      }
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }, disabledValue: "1"),
                    getInfoDropdown(
                        "Send Retrieval Requests To",
                        this
                            .widget
                            .controllers["corporateInfo"]["SendRetRequestTo"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["SendRetRequestTo"],
                        sendLocations,
                        disabled: this
                                    .widget
                                    .controllers["general"]["corpSame"]
                                    .text ==
                                "true"
                            ? true
                            : false, validator: (newVal) {
                      if (this.widget.controllers["general"]["corpSame"].text ==
                          "true") {
                        return null;
                      }
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }, disabledValue: "1"),
                    getInfoDropdown(
                        "Send Chargebacks To",
                        this
                            .widget
                            .controllers["corporateInfo"]["SendCBTo"]
                            .text,
                        this.widget.controllers["corporateInfo"]["SendCBTo"],
                        sendLocations,
                        disabled: this
                                    .widget
                                    .controllers["general"]["corpSame"]
                                    .text ==
                                "true"
                            ? true
                            : false, validator: (newVal) {
                      if (this.widget.controllers["general"]["corpSame"].text ==
                          "true") {
                        return null;
                      }
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }, disabledValue: "1"),
                  ],
                ),
              ),
              CustomCard(
                key: Key("businessInfo2"),
                icon: Icons.business,
                title: "Business Info",
                child: Column(
                  children: <Widget>[
                    getInfoRow(
                        "Name as it appears on income tax",
                        this.widget.controllers["businessInfo"]["IrsName"].text,
                        this.widget.controllers["businessInfo"]["IrsName"],
                        validator: (newVal) {
                      if (newVal.isEmpty) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoRow(
                        "Business Email Address",
                        this
                            .widget
                            .controllers["businessInfo"]["BusinessEmailAddress"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["BusinessEmailAddress"],
                        validator: (newVal) => validateRow(
                              newVal,
                              "BusinessInfo",
                              "BusinessEmailAddress",
                              message: "Please enter a Valid Email",
                            )),
                    getInfoRow(
                        "Location Phone",
                        this
                            .widget
                            .controllers["businessInfo"]["LocationPhone"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["LocationPhone"],
                        mask: "000-000-0000",
                        validator: (newVal) => validateRow(
                            newVal, "BusinessInfo", "LocationPhone",
                            message: "10 Digit Phone # with area code")),
                    getInfoRow(
                        "Products Sold",
                        this
                            .widget
                            .controllers["businessInfo"]["ProductsSold"]
                            .text,
                        this.widget.controllers["businessInfo"]["ProductsSold"],
                        validator: (newVal) => validateRow(
                            newVal, "BusinessInfo", "ProductsSold")),
                    getInfoDropdown(
                        "Business Category",
                        this
                            .widget
                            .controllers["businessInfo"]["BusinessCategory"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["BusinessCategory"],
                        businessCategory, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    SicDropDown(
                      value:
                          this.widget.controllers["businessInfo"]["Sic"].text,
                      callback: (newVal) {
                        if (newVal != null && newVal != "") {
                          setState(() {
                            this
                                .widget
                                .controllers["businessInfo"]["Sic"]
                                .text = newVal["value"];
                          });
                        }
                      },
                      validator: (newVal) {
                        if (newVal == null) {
                          return "Required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    getInfoDropdown(
                        "Federal Tax ID Type",
                        this
                            .widget
                            .controllers["businessInfo"]["FederalTaxIdType"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["FederalTaxIdType"],
                        fedTaxIdType, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoRow(
                        "Federal Tax Id",
                        this
                            .widget
                            .controllers["businessInfo"]["FederalTaxId"]
                            .text,
                        this.widget.controllers["businessInfo"]["FederalTaxId"],
                        mask: "000000000",
                        validator: (newVal) => validateRow(
                            newVal, "BusinessInfo", "FederalTaxId")),
                    getInfoDropdown(
                        "I certify that I am a foreign entity/nonresident alien",
                        this
                            .widget
                            .controllers["businessInfo"]
                                ["ForeignEntityOrNonResidentAlien"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["ForeignEntityOrNonResidentAlien"],
                        yesNoOptions, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                  ],
                ),
              ),
              CustomCard(
                key: Key("businessInfo3"),
                icon: Icons.business,
                title: "Site Info",
                child: Column(
                  children: <Widget>[
                    getInfoDropdown(
                        "Site Visitation",
                        this
                            .widget
                            .controllers["siteInfo"]["SiteVisitation"]
                            .text,
                        this.widget.controllers["siteInfo"]["SiteVisitation"],
                        yesNoOptions, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Zone",
                        this.widget.controllers["siteInfo"]["Zone"].text,
                        this.widget.controllers["siteInfo"]["Zone"],
                        zones, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Location",
                        this.widget.controllers["siteInfo"]["Location"].text,
                        this.widget.controllers["siteInfo"]["Location"],
                        locations, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoRow(
                        "Number of Employees",
                        this
                            .widget
                            .controllers["siteInfo"]["NoOfEmployees"]
                            .text,
                        this.widget.controllers["siteInfo"]["NoOfEmployees"],
                        validator: (newVal) =>
                            validateRow(newVal, "SiteInfo", "NoOfEmployees")),
                    getInfoRow(
                        "Number of Terminals",
                        this
                            .widget
                            .controllers["siteInfo"]["NoOfRegister"]
                            .text,
                        this.widget.controllers["siteInfo"]["NoOfRegister"],
                        validator: (newVal) =>
                            validateRow(newVal, "SiteInfo", "NoOfRegister")),
                    getInfoDropdown(
                        "Merchant Name Site Display",
                        this
                            .widget
                            .controllers["siteInfo"]["MerchantNameSiteDisplay"]
                            .text,
                        this.widget.controllers["siteInfo"]
                            ["MerchantNameSiteDisplay"],
                        merchantNameDisplay, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Merchant Occupies",
                        this
                            .widget
                            .controllers["siteInfo"]["StoreLocatedOn"]
                            .text,
                        this.widget.controllers["siteInfo"]["StoreLocatedOn"],
                        storeLocatedOn, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Number of Floors",
                        this
                            .widget
                            .controllers["siteInfo"]["NumberOfLevels"]
                            .text,
                        this.widget.controllers["siteInfo"]["NumberOfLevels"],
                        numOfLevels, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Remaining Floor(s) Occupied By",
                        this
                            .widget
                            .controllers["siteInfo"]["OtherOccupiedBy"]
                            .text,
                        this.widget.controllers["siteInfo"]["OtherOccupiedBy"],
                        otherOccupiedBy, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Approximate Square Footage",
                        this
                            .widget
                            .controllers["siteInfo"]["SquareFootage"]
                            .text,
                        this.widget.controllers["siteInfo"]["SquareFootage"],
                        squareFootage, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Customer Deposit Required",
                        this
                            .widget
                            .controllers["siteInfo"]["DepositRequired"]
                            .text,
                        this.widget.controllers["siteInfo"]["DepositRequired"],
                        yesNoOptions, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Return Policy",
                        this
                            .widget
                            .controllers["siteInfo"]["ReturnPolicy"]
                            .text,
                        this.widget.controllers["siteInfo"]["ReturnPolicy"],
                        returnPolicy, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Refund Policy",
                        this
                            .widget
                            .controllers["siteInfo"]["RefundPolicy"]
                            .text,
                        this.widget.controllers["siteInfo"]["RefundPolicy"],
                        yesNoOptions, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Refund Type",
                        this.widget.controllers["siteInfo"]["RefundType"].text,
                        this.widget.controllers["siteInfo"]["RefundType"],
                        refundType, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                    getInfoDropdown(
                        "Days to Submit Credit Transactions",
                        this
                            .widget
                            .controllers["siteInfo"]["RefPolicyRefDays"]
                            .text,
                        this.widget.controllers["siteInfo"]["RefPolicyRefDays"],
                        refDays, validator: (newVal) {
                      if (newVal == null) {
                        return "Required";
                      } else {
                        return null;
                      }
                    }),
                  ],
                ),
              ),
              CustomCard(
                key: Key("businessInfo4"),
                icon: Icons.business,
                title: "Mail Order/Telephone Order",
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Mail Order/Telephone Order (MOTO)"),
                        Checkbox(
                            value: this
                                        .widget
                                        .controllers["general"]["motoCheck"]
                                        .text ==
                                    "true"
                                ? true
                                : false,
                            onChanged: (val) {
                              var motoValue;
                              if (val == true) {
                                motoValue = "1";
                              } else if (val == false) {
                                motoValue = "0";
                              }
                              setState(() {
                                this
                                    .widget
                                    .controllers["motoBBInet"]["MOTO"]
                                    .text = motoValue;
                                this
                                    .widget
                                    .controllers["general"]["motoCheck"]
                                    .text = val.toString();
                                print(this
                                    .widget
                                    .controllers["general"]["motoCheck"]
                                    .text);
                                this
                                        .widget
                                        .isDirtyStatus["businessInfoIsDirty"] =
                                    true;
                              });
                            }),
                      ],
                    ),
                    this.widget.controllers["general"]["motoCheck"].text ==
                            "true"
                        ? Column(children: <Widget>[
                            getInfoRow(
                                "% Transaction to Delivery 0-7 Days",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["TransDeliveredIn07"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["TransDeliveredIn07"],
                                mask: "000",
                                validator: (newVal) => validateAddedRows(newVal,
                                    "MotoBBInet", "TransDeliveredIn07")),
                            getInfoRow(
                                "% Transaction to Delivery 8-14 Days",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["TransDeliveredIn814"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["TransDeliveredIn814"],
                                mask: "000",
                                validator: (newVal) => validateAddedRows(newVal,
                                    "MotoBBInet", "TransDeliveredIn814")),
                            getInfoRow(
                                "% Transaction to Delivery 15-30 Days",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["TransDeliveredIn1530"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["TransDeliveredIn1530"],
                                mask: "000",
                                validator: (newVal) => validateAddedRows(newVal,
                                    "MotoBBInet", "TransDeliveredIn1530")),
                            getInfoRow(
                                "% Transaction to Delivery +30 Days",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["TransDeliveredOver30"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["TransDeliveredOver30"],
                                mask: "000",
                                validator: (newVal) => validateAddedRows(newVal,
                                    "MotoBBInet", "TransDeliveredOver30")),
                            getInfoDropdown(
                                "MC/Visa/Discover Network/Amex Sales Deposits",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["CCSalesProcessedAt"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["CCSalesProcessedAt"],
                                ccProcessedAt, validator: (newVal) {
                              if (newVal == null &&
                                  this
                                          .widget
                                          .controllers["general"]["motoCheck"]
                                          .text ==
                                      "true") {
                                return "Required";
                              } else {
                                return null;
                              }
                            }),
                            getInfoDropdown(
                                "Does any cardholder billing involve automatic renewals or recurring transactions?",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["CardholderBilling"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["CardholderBilling"],
                                yesNoOptions, validator: (newVal) {
                              if (newVal == null &&
                                  this
                                          .widget
                                          .controllers["general"]["motoCheck"]
                                          .text ==
                                      "true") {
                                return "Required";
                              } else {
                                return null;
                              }
                            }),
                          ])
                        : Container()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInfoRow(label, value, controller, {mask, validator}) {
    if (mask != null) {
      controller.updateMask(mask);
    }
    bool isValidating = false;
    if (validator != null) {
      setState(() {
        isValidating = true;
      });
    }

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
                  validator: isValidating ? validator : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfoDropdown(label, value, controller, dropList,
      {validator, bool disabled, disabledValue}) {
    var _currentVal;
    _currentVal = null;
    bool dropDisabled = false;

    if (value != null && value != "") {
      controller.text = value;
      _currentVal = controller.text;
    }
    var disVal;
    var disText = "";

    if (disabled == true) {
      if (disabledValue != null) {
        disVal = null;
        disText = null;
        _currentVal = disabledValue;
      }
      dropDisabled = disabled;
      controller.text = disText;
      value = disVal;
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
              child: DropdownButtonFormField<String>(
                value: _currentVal != null ? _currentVal : null,
                validator: validator != null ? validator : null,
                isExpanded: true,
                hint: Text("Please choose one"),
                items: dropList.map<DropdownMenuItem<String>>((dynamic item) {
                  var itemName = item["name"];
                  var itemValue = item["value"];
                  return DropdownMenuItem<String>(
                    value: itemValue,
                    child: Text(
                      itemName,
                    ),
                  );
                }).toList(),
                onChanged: dropDisabled
                    ? null
                    : (newValue) {
                        setState(() {
                          controller.text = newValue;
                        });
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfoSearchableDropdown(label, value, controller, dropList,
      {validator}) {
    var currentVal;
    currentVal = null;

    if (value != null && value != "") {
      controller.text = value;
      currentVal = controller.text;
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
              child: SearchableDropdown.single(
                value: currentVal,
                validator: validator != null ? validator : null,
                onClear: () {
                  setState(() {
                    controller.text = "";
                    currentVal = null;
                    value = null;
                  });
                },
                hint: "Please choose one",
                searchHint: null,
                isExpanded: true,
                items: dropList.map<DropdownMenuItem<String>>((dynamic item) {
                  var itemName = item["name"];
                  var itemValue = item["value"];
                  return DropdownMenuItem<String>(
                    value: itemValue,
                    child: Text(
                      itemName,
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    controller.text = newValue;
                    this.widget.isDirtyStatus["businessInfoIsDirty"] = true;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
