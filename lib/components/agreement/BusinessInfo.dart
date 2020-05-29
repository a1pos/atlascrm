import 'dart:async';
import 'dart:developer';

import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class BusinessInfo extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map controllers;
  final agreementDoc;

  BusinessInfo({this.controllers, this.agreementDoc});

  @override
  BusinessInfoState createState() => BusinessInfoState();
}

// class Owner {
//   Owner({
//     String business_owner,
//     String lead,
//     List document,
//   });
// }

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
  // final firstNameController = TextEditingController();
  // final lastNameController = TextEditingController();
  // final emailAddrController = TextEditingController();
  // final phoneNumberController = TextEditingController();
  // final businessNameController = TextEditingController();
  // final dbaController = TextEditingController();
  // final businessAddressController = TextEditingController();
  // final leadSourceController = TextEditingController();

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
    {"value": "7", "name": "7 - Dispute Manager and Fax"},
    {"value": "8", "name": "8 - Dispute Manager and Mail"}
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

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    agreementDocument = this.widget.agreementDoc;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomCard(
              key: Key("businessInfo1"),
              icon: Icons.business,
              title: "MPA/ Corporate Info",
              child: Column(
                children: <Widget>[
                  getInfoRow("Merchant DBA Name", agreementDocument["dbaName"],
                      this.widget.controllers["ClientDbaName"]),
                  getInfoRow(
                      "Merchant's Corporate/Legal Name",
                      agreementDocument["businessName"],
                      this.widget.controllers["LegalName"]),
                  getInfoRow("Number of Locations", "",
                      this.widget.controllers["NumberOfLocation"]),
                  getInfoSearchableDropdown(
                      "State Incorporated",
                      this.widget.controllers["StateIncorporated"].text,
                      this.widget.controllers["StateIncorporated"],
                      stateInc),
                  getInfoDropdown(
                      "Statement Provided",
                      this.widget.controllers["CurrentStmntProvided"].text,
                      this.widget.controllers["CurrentStmntProvided"],
                      yesNoOptions),
                  getInfoDropdown(
                      "Retrieval Fax Rpt Code",
                      this
                          .widget
                          .controllers["RetrievalFaxRptCodeRefValue"]
                          .text,
                      this.widget.controllers["RetrievalFaxRptCodeRefValue"],
                      retrievalFaxRpt),
                  getInfoRow(
                      "Corporate Contact",
                      this.widget.controllers["CorporateContact"].text,
                      this.widget.controllers["CorporateContact"]),
                  getInfoRow(
                      "Business Start Date",
                      this.widget.controllers["BusinessStartDate"].text,
                      this.widget.controllers["BusinessStartDate"]),
                  getInfoDropdown(
                      "Business Type",
                      this.widget.controllers["BusinessType"].text,
                      this.widget.controllers["BusinessType"],
                      businessTypes),
                  getInfoDropdown(
                      "Statement Hold",
                      this.widget.controllers["StatementHoldRefValue"].text,
                      this.widget.controllers["StatementHoldRefValue"],
                      statementHoldRefValue),
                  Container(
                      child: Padding(
                          padding: EdgeInsets.all(15),
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
                                      locationValue: (agreementDocument[
                                                      "address"] !=
                                                  null &&
                                              agreementDocument["address"] !=
                                                  "")
                                          ? agreementDocument["address"] +
                                              ", " +
                                              agreementDocument["city"] +
                                              ", " +
                                              agreementDocument["state"] +
                                              ", " +
                                              agreementDocument["zipCode"]
                                          : null,
                                      onAddressChange: (val) =>
                                          businessAddress = val)),
                            ],
                          ))),
                  getInfoDropdown(
                      "Send Monthly Statements To",
                      this.widget.controllers["SendMonthlyStmntTo"].text,
                      this.widget.controllers["SendMonthlyStmntTo"],
                      sendLocations),
                  getInfoDropdown(
                      "Send Retrieval Requests To",
                      this.widget.controllers["SendRetRequestTo"].text,
                      this.widget.controllers["SendRetRequestTo"],
                      sendLocations),
                  getInfoDropdown(
                      "Send Chargebacks To",
                      this.widget.controllers["SendCBTo"].text,
                      this.widget.controllers["SendCBTo"],
                      sendLocations),
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
                      agreementDocument["dbaName"],
                      this.widget.controllers["IrsName"]),
                  getInfoRow(
                      "Business Email Address",
                      this.widget.controllers["BusinessEmailAddress"].text,
                      this.widget.controllers["BusinessEmailAddress"]),
                  getInfoRow(
                      "Location Phone",
                      this.widget.controllers["LocationPhone"].text,
                      this.widget.controllers["LocationPhone"]),
                  getInfoRow(
                      "Products Sold",
                      this.widget.controllers["ProductsSold"].text,
                      this.widget.controllers["ProductsSold"]),
                  getInfoDropdown(
                      "Business Category",
                      this.widget.controllers["BusinessCategory"].text,
                      this.widget.controllers["BusinessCategory"],
                      businessCategory),
                  // getInfoRow(
                  //     "SIC Code",
                  //     this.widget.controllers["CorporateContact"].text,
                  //     this.widget.controllers["CorporateContact"]),
                  getInfoDropdown(
                      "Federal Tax ID Type",
                      this.widget.controllers["FederalTaxIdType"].text,
                      this.widget.controllers["FederalTaxIdType"],
                      fedTaxIdType),
                  getInfoRow(
                      "Federal Tax Id",
                      this.widget.controllers["FederalTaxId"].text,
                      this.widget.controllers["FederalTaxId"]),
                  getInfoDropdown(
                      "I certify that I am a foreign entity/nonresident alien",
                      this
                          .widget
                          .controllers["ForeignEntityOrNonResidentAlien"]
                          .text,
                      this
                          .widget
                          .controllers["ForeignEntityOrNonResidentAlien"],
                      yesNoOptions),
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
                      this.widget.controllers["SiteVisitation"].text,
                      this.widget.controllers["SiteVisitation"],
                      yesNoOptions),
                  getInfoDropdown("Zone", this.widget.controllers["Zone"].text,
                      this.widget.controllers["Zone"], zones),
                  getInfoDropdown(
                      "Location",
                      this.widget.controllers["Location"].text,
                      this.widget.controllers["Location"],
                      locations),
                  getInfoRow(
                      "Number of Employees",
                      agreementDocument["dbaName"],
                      this.widget.controllers["IrsName"]),
                ],
              ),
            ),
          ],
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

  Widget getInfoDropdown(label, value, controller, dropList) {
    var _currentVal;
    _currentVal = null;

    if (value != null && value != "") {
      controller.text = value;
      _currentVal = controller.text;
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
              child: DropdownButton<String>(
                value: _currentVal,
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
                onChanged: (newValue) {
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

  Widget getInfoSearchableDropdown(label, value, controller, dropList) {
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
                onClear: () {
                  setState(() {
                    currentVal = null;
                    value = null;
                  });
                },
                hint: "Select one",
                searchHint: null,
                isExpanded: true,
                // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
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
}
