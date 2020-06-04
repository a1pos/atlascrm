import 'dart:async';
import 'dart:developer';

import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class SalesPricing extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map controllers;
  final agreementDoc;

  SalesPricing({this.controllers, this.agreementDoc});

  @override
  SalsPricingState createState() => SalsPricingState();
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

class SalsPricingState extends State<SalesPricing>
    with TickerProviderStateMixin {
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
  var accTypes = [
    {"value": "1", "name": "DDA"},
    {"value": "2", "name": "GL"},
    {"value": "3", "name": "Savings"},
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
                  icon: Icons.attach_money,
                  title: "Settlement",
                  child: Column(
                    children: <Widget>[
                      getInfoRow(
                          "Deposit Bank Name",
                          this.widget.controllers["DepositBankName"].text,
                          this.widget.controllers["DepositBankName"]),
                      getInfoDropdown(
                          "Account Type",
                          this.widget.controllers["AccountType"].text,
                          this.widget.controllers["AccountType"],
                          accTypes),
                      getInfoRow(
                          "Transit ABA Number",
                          this.widget.controllers["TransitABANumber"].text,
                          this.widget.controllers["TransitABANumber"],
                          mask: '000000000'),
                    ],
                  ),
                ),
              ]),
        ));
  }

  Widget getInfoRow(label, value, controller, {mask}) {
    if (mask != null) {
      controller.updateMask(mask);
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
                hint: "Please choose one",
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
