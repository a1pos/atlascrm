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

  final Map controllers;
  final agreementDoc;

  BusinessInfo({this.controllers, this.agreementDoc});

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
  void initState() {
    super.initState();
  }

  Future<void> setCorpAddress(address) async {
    setState(() {
      this.widget.controllers["corporateInfo"]["Address1"].text =
          address["address"];

      this.widget.controllers["corporateInfo"]["City"].text = address["city"];

      this.widget.controllers["corporateInfo"]["State"].text = address["state"];

      this.widget.controllers["corporateInfo"]["First5Zip"].text =
          address["zipcode"];
    });
  }

  @override
  Widget build(BuildContext context) {
    agreementDocument = this.widget.agreementDoc;
    var testItem = this.widget.controllers["mpaInfo"]["ClientDbaName"].text;
    print(testItem);
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        child: Form(
          // key: _formKeys[1],
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
                        this.widget.controllers["mpaInfo"]["ClientDbaName"]),
                    getInfoRow(
                        "Merchant's Corporate/Legal Name",
                        this
                            .widget
                            .controllers["corporateInfo"]["LegalName"]
                            .text,
                        this.widget.controllers["corporateInfo"]["LegalName"]),
                    getInfoRow(
                        "Number of Locations",
                        this
                            .widget
                            .controllers["mpaInfo"]["NumberOfLocation"]
                            .text,
                        this.widget.controllers["mpaInfo"]["NumberOfLocation"]),
                    getInfoSearchableDropdown(
                        "State Incorporated",
                        this
                            .widget
                            .controllers["corporateInfo"]["StateIncorporated"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["StateIncorporated"],
                        stateInc),
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
                        retrievalFaxRpt),
                    getInfoRow(
                        "Corporate Contact",
                        this
                            .widget
                            .controllers["corporateInfo"]["CorporateContact"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["CorporateContact"]),
                    getInfoRow(
                        "Business Start Date",
                        this
                            .widget
                            .controllers["corporateInfo"]["BusinessStartDate"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["BusinessStartDate"],
                        mask: "00/00/0000"),
                    getInfoDropdown(
                        "Business Type",
                        this
                            .widget
                            .controllers["corporateInfo"]["BusinessType"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["BusinessType"],
                        businessTypes),
                    getInfoDropdown(
                        "Statement Hold",
                        this
                            .widget
                            .controllers["corporateInfo"]
                                ["StatementHoldRefValue"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["StatementHoldRefValue"],
                        statementHoldRefValue),
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
                                  }),
                            ),
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
                              setState(() {
                                this
                                    .widget
                                    .controllers["general"]["corpSame"]
                                    .text = val.toString();
                                print(this
                                    .widget
                                    .controllers["general"]["corpSame"]
                                    .text);
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
                                                        .controllers[
                                                            "businessInfo"]
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
                                          setCorpAddress(val);
                                        }),
                                  ),
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
                        sendLocations),
                    getInfoDropdown(
                        "Send Retrieval Requests To",
                        this
                            .widget
                            .controllers["corporateInfo"]["SendRetRequestTo"]
                            .text,
                        this.widget.controllers["corporateInfo"]
                            ["SendRetRequestTo"],
                        sendLocations),
                    getInfoDropdown(
                        "Send Chargebacks To",
                        this
                            .widget
                            .controllers["corporateInfo"]["SendCBTo"]
                            .text,
                        this.widget.controllers["corporateInfo"]["SendCBTo"],
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
                        this.widget.controllers["businessInfo"]["IrsName"].text,
                        this.widget.controllers["businessInfo"]["IrsName"]),
                    getInfoRow(
                        "Business Email Address",
                        this
                            .widget
                            .controllers["businessInfo"]["BusinessEmailAddress"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["BusinessEmailAddress"]), // TODO EMAIL CHECK VALID
                    getInfoRow(
                        "Location Phone",
                        this
                            .widget
                            .controllers["businessInfo"]["LocationPhone"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["LocationPhone"],
                        mask: "000-000-0000"),
                    getInfoRow(
                        "Products Sold",
                        this
                            .widget
                            .controllers["businessInfo"]["ProductsSold"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["ProductsSold"]),
                    getInfoDropdown(
                        "Business Category",
                        this
                            .widget
                            .controllers["businessInfo"]["BusinessCategory"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["BusinessCategory"],
                        businessCategory),
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
                    ),
                    getInfoDropdown(
                        "Federal Tax ID Type",
                        this
                            .widget
                            .controllers["businessInfo"]["FederalTaxIdType"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["FederalTaxIdType"],
                        fedTaxIdType),
                    getInfoRow(
                        "Federal Tax Id",
                        this
                            .widget
                            .controllers["businessInfo"]["FederalTaxId"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["FederalTaxId"]),
                    getInfoDropdown(
                        "I certify that I am a foreign entity/nonresident alien",
                        this
                            .widget
                            .controllers["businessInfo"]
                                ["ForeignEntityOrNonResidentAlien"]
                            .text,
                        this.widget.controllers["businessInfo"]
                            ["ForeignEntityOrNonResidentAlien"],
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
                        this
                            .widget
                            .controllers["siteInfo"]["SiteVisitation"]
                            .text,
                        this.widget.controllers["siteInfo"]["SiteVisitation"],
                        yesNoOptions),
                    getInfoDropdown(
                        "Zone",
                        this.widget.controllers["siteInfo"]["Zone"].text,
                        this.widget.controllers["siteInfo"]["Zone"],
                        zones),
                    getInfoDropdown(
                        "Location",
                        this.widget.controllers["siteInfo"]["Location"].text,
                        this.widget.controllers["siteInfo"]["Location"],
                        locations),
                    getInfoRow(
                        "Number of Employees",
                        this
                            .widget
                            .controllers["siteInfo"]["NoOfEmployees"]
                            .text,
                        this.widget.controllers["siteInfo"]["NoOfEmployees"]),
                    getInfoRow(
                        "Number of Terminals",
                        this
                            .widget
                            .controllers["siteInfo"]["NoOfRegister"]
                            .text,
                        this.widget.controllers["siteInfo"]["NoOfRegister"]),
                    getInfoDropdown(
                        "Merchant Name Site Display",
                        this
                            .widget
                            .controllers["siteInfo"]["MerchantNameSiteDisplay"]
                            .text,
                        this.widget.controllers["siteInfo"]
                            ["MerchantNameSiteDisplay"],
                        merchantNameDisplay),
                    getInfoDropdown(
                        "Merchant Occupies",
                        this
                            .widget
                            .controllers["siteInfo"]["StoreLocatedOn"]
                            .text,
                        this.widget.controllers["siteInfo"]["StoreLocatedOn"],
                        storeLocatedOn),
                    getInfoDropdown(
                        "Number of Floors",
                        this
                            .widget
                            .controllers["siteInfo"]["NumberOfLevels"]
                            .text,
                        this.widget.controllers["siteInfo"]["NumberOfLevels"],
                        numOfLevels),
                    getInfoDropdown(
                        "Remaining Floor(s) Occupied By",
                        this
                            .widget
                            .controllers["siteInfo"]["OtherOccupiedBy"]
                            .text,
                        this.widget.controllers["siteInfo"]["OtherOccupiedBy"],
                        otherOccupiedBy),
                    getInfoDropdown(
                        "Approximate Square Footage",
                        this
                            .widget
                            .controllers["siteInfo"]["SquareFootage"]
                            .text,
                        this.widget.controllers["siteInfo"]["SquareFootage"],
                        squareFootage),
                    getInfoDropdown(
                        "Customer Deposit Required",
                        this
                            .widget
                            .controllers["siteInfo"]["DepositRequired"]
                            .text,
                        this.widget.controllers["siteInfo"]["DepositRequired"],
                        yesNoOptions),
                    getInfoDropdown(
                        "Return Policy",
                        this
                            .widget
                            .controllers["siteInfo"]["ReturnPolicy"]
                            .text,
                        this.widget.controllers["siteInfo"]["ReturnPolicy"],
                        returnPolicy),
                    getInfoDropdown(
                        "Refund Policy",
                        this
                            .widget
                            .controllers["siteInfo"]["RefundPolicy"]
                            .text,
                        this.widget.controllers["siteInfo"]["RefundPolicy"],
                        yesNoOptions),
                    getInfoDropdown(
                        "Refund Type",
                        this.widget.controllers["siteInfo"]["RefundType"].text,
                        this.widget.controllers["siteInfo"]["RefundType"],
                        refundType),
                    getInfoDropdown(
                        "Days to Submit Credit Transactions",
                        this
                            .widget
                            .controllers["siteInfo"]["RefPolicyRefDays"]
                            .text,
                        this.widget.controllers["siteInfo"]["RefPolicyRefDays"],
                        refDays),
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
                              setState(() {
                                this
                                    .widget
                                    .controllers["general"]["motoCheck"]
                                    .text = val.toString();
                                print(this
                                    .widget
                                    .controllers["general"]["motoCheck"]
                                    .text);
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
                                    ["TransDeliveredIn07"]),
                            getInfoRow(
                                "% Transaction to Delivery 8-14 Days",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["TransDeliveredIn814"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["TransDeliveredIn814"]),
                            getInfoRow(
                                "% Transaction to Delivery 15-30 Days",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["TransDeliveredIn1530"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["TransDeliveredIn1530"]),
                            getInfoRow(
                                "% Transaction to Delivery +30 Days",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["TransDeliveredOver30"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["TransDeliveredOver30"]),
                            getInfoDropdown(
                                "MC/Visa/Discover Network/Amex Sales Deposits",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["CCSalesProcessedAt"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["CCSalesProcessedAt"],
                                ccProcessedAt),
                            getInfoDropdown(
                                "Does any cardholder billing involve automatic renewals or recurring transactions?",
                                this
                                    .widget
                                    .controllers["motoBBInet"]
                                        ["CardholderBilling"]
                                    .text,
                                this.widget.controllers["motoBBInet"]
                                    ["CardholderBilling"],
                                yesNoOptions),
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
