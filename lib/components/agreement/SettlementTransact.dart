import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class SettlementTransact extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map controllers;
  final agreementDoc;

  SettlementTransact({this.controllers, this.agreementDoc});

  @override
  SettlementTransactState createState() => SettlementTransactState();
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

class SettlementTransactState extends State<SettlementTransact>
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
  var yesNoOptions = [
    {"value": "0", "name": "No"},
    {"value": "1", "name": "Yes"}
  ];
  var seasonalMonths = [
    {"value": "1", "name": "January"},
    {"value": "2", "name": "February"},
    {"value": "3", "name": "March"},
    {"value": "4", "name": "April"},
    {"value": "5", "name": "May"},
    {"value": "6", "name": "June"},
    {"value": "7", "name": "July"},
    {"value": "8", "name": "August"},
    {"value": "9", "name": "September"},
    {"value": "10", "name": "October"},
    {"value": "11", "name": "November"},
    {"value": "12", "name": "December"},
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                  Widget>[
            CustomCard(
              key: Key("settlementTransact1"),
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
                  getInfoRow(
                      "Deposit Account Number",
                      this.widget.controllers["DepositAccountNumber"].text,
                      this.widget.controllers["DepositAccountNumber"],
                      mask: '0[0000000000000000]'),
                ],
              ),
            ),
            CustomCard(
              key: Key("settlementTransact2"),
              icon: Icons.attach_money,
              title: "Transaction",
              child: Column(
                children: <Widget>[
                  getInfoRow(
                      "Average MC/VISA/Discover Ticket",
                      this.widget.controllers["AvgMcViDiTicket"].text,
                      this.widget.controllers["AvgMcViDiTicket"],
                      mask: '00000'),
                  getInfoRow(
                      "Total Annual Sales Volume(cash+credit+check+debit)",
                      this.widget.controllers["TotalAnnualSalesVolume"].text,
                      this.widget.controllers["TotalAnnualSalesVolume"],
                      mask: '000000000'),
                  getInfoRow(
                      "Annual MC/VISA Credit Sales Volume",
                      this.widget.controllers["AnnualMcViSalesVolume"].text,
                      this.widget.controllers["AnnualMcViSalesVolume"],
                      mask: '000000000'),
                  getInfoRow(
                      "Annual Discover Credit Sales Volume",
                      this.widget.controllers["AnnualDiSalesVolume"].text,
                      this
                          .widget
                          .controllers["AnnualDiSalesVolume"]), //NEEDS MIN SET
                  getInfoRow(
                      "Annual American Express Credit Sales Volume",
                      this
                          .widget
                          .controllers["AnnualAmexOnePointSalesVolume"]
                          .text,
                      this.widget.controllers[
                          "AnnualAmexOnePointSalesVolume"]), //NEEDS MIN SET
                  getInfoRow(
                      "Highest Ticket Amount",
                      this.widget.controllers["HighestTicket"].text,
                      this.widget.controllers["HighestTicket"],
                      mask: '00000000'),
                  getInfoDropdown(
                      "Seasonal Merchant",
                      this.widget.controllers["SeasonalMerchant"].text,
                      this.widget.controllers["SeasonalMerchant"],
                      yesNoOptions),
                  getInfoDropdown(
                      "Season Periopd From",
                      this.widget.controllers["SeasonalFrom"].text,
                      this.widget.controllers["SeasonalFrom"],
                      seasonalMonths), //MAKE DEPENDANT ON SEASONAL MERCHANT Y/N
                  getInfoDropdown(
                      "Season Periopd To",
                      this.widget.controllers["SeasonalTo"].text,
                      this.widget.controllers["SeasonalTo"],
                      seasonalMonths), //MAKE DEPENDANT ON SEASONAL MERCHANT Y/N
                  getInfoRow(
                      "% Store front/Swiped",
                      this.widget.controllers["CcPercentPos"].text,
                      this.widget.controllers[
                          "CcPercentPos"]), //MAKE ADD UP TO 100 1/4
                  getInfoRow(
                      "% Internet",
                      this.widget.controllers["CcPercentInet"].text,
                      this.widget.controllers[
                          "CcPercentInet"]), //MAKE ADD UP TO 100 2/4
                  getInfoRow(
                      "% Mail Order",
                      this.widget.controllers["CcPercentMo"].text,
                      this
                          .widget
                          .controllers["CcPercentMo"]), //MAKE ADD UP TO 100 3/4
                  getInfoRow(
                      "% Telephone Order",
                      this.widget.controllers["CcPercentTo"].text,
                      this
                          .widget
                          .controllers["CcPercentTo"]), //MAKE ADD UP TO 100 4/4
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
