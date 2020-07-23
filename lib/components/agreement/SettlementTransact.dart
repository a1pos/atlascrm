import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class SettlementTransact extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map isDirtyStatus;
  final Map controllers;
  final agreementDoc;
  final GlobalKey formKey;
  final Map validationErrors;
  final Map seasonalMerchant;

  SettlementTransact(
      {this.controllers,
      this.agreementDoc,
      this.isDirtyStatus,
      this.formKey,
      this.validationErrors,
      this.seasonalMerchant});

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
  // bool seasonalMerchant = false;
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
  final settlementKey = GlobalKey<FormState>();
  void initState() {
    super.initState();
    seasonalCheck();
  }

  Future<void> seasonalCheck() async {
    if (this.widget.controllers["transaction"]["SeasonalMerchant"].text ==
        "1") {
      setState(() {
        this.widget.seasonalMerchant["seasonalMerchant"] = true;
      });
    }
  }

  Future<void> seasonalSwap(val) async {
    if (val == "1") {
      setState(() {
        this.widget.seasonalMerchant["seasonalMerchant"] = true;
      });
    } else if (val == "0") {
      setState(() {
        this.widget.seasonalMerchant["seasonalMerchant"] = false;
        this.widget.controllers["transaction"]["SeasonalTo"].text = null;
        this.widget.controllers["transaction"]["SeasonalFrom"].text = null;
      });
    }
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
        this.widget.controllers["transaction"]["CcPercentPos"].text != ""
            ? this.widget.controllers["transaction"]["CcPercentPos"].text
            : "0");
    var valInet = int.parse(
        this.widget.controllers["transaction"]["CcPercentInet"].text != ""
            ? this.widget.controllers["transaction"]["CcPercentInet"].text
            : "0");
    var valMo = int.parse(
        this.widget.controllers["transaction"]["CcPercentMo"].text != ""
            ? this.widget.controllers["transaction"]["CcPercentMo"].text
            : "0");
    var valTo = int.parse(
        this.widget.controllers["transaction"]["CcPercentTo"].text != ""
            ? this.widget.controllers["transaction"]["CcPercentTo"].text
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
              setState(() {
                this.widget.isDirtyStatus["settlementTransactIsDirty"] = true;
              });
            },
            key: settlementKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomCard(
                    key: Key("settlementTransact1"),
                    icon: Icons.attach_money,
                    title: "Settlement",
                    child: Column(
                      children: <Widget>[
                        getInfoRow(
                            "Deposit Bank Name",
                            this
                                .widget
                                .controllers["settlement"]["DepositBankName"]
                                .text,
                            this.widget.controllers["settlement"]
                                ["DepositBankName"],
                            validator: (newVal) => validateRow(
                                newVal, "Settlement", "DepositBankName")),
                        getInfoDropdown(
                            "Account Type",
                            this
                                .widget
                                .controllers["settlement"]["AccountType"]
                                .text,
                            this.widget.controllers["settlement"]
                                ["AccountType"],
                            accTypes, validator: (newVal) {
                          if (newVal == null) {
                            return "Required";
                          } else {
                            return null;
                          }
                        }),
                        getInfoRow(
                            "Transit ABA Number",
                            this
                                .widget
                                .controllers["settlement"]["TransitABANumber"]
                                .text,
                            this.widget.controllers["settlement"]
                                ["TransitABANumber"],
                            mask: '000000000',
                            validator: (newVal) => validateRow(
                                newVal, "Settlement", "TransitABANumber")),
                        getInfoRow(
                            "Deposit Account Number",
                            this
                                .widget
                                .controllers["settlement"]
                                    ["DepositAccountNumber"]
                                .text,
                            this.widget.controllers["settlement"]
                                ["DepositAccountNumber"],
                            mask: '00000000000000000',
                            validator: (newVal) => validateRow(
                                newVal, "Settlement", "DepositAccountNumber")),
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
                            this
                                .widget
                                .controllers["transaction"]["AvgMcViDiTicket"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["AvgMcViDiTicket"],
                            mask: '00000', validator: (newVal) {
                          if (newVal.isEmpty) {
                            return "Required";
                          } else {
                            return null;
                          }
                        }),
                        getInfoRow(
                            "Total Annual Sales Volume(cash+credit+check+debit)",
                            this
                                .widget
                                .controllers["transaction"]
                                    ["TotalAnnualSalesVolume"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["TotalAnnualSalesVolume"],
                            mask: '000000000', validator: (newVal) {
                          if (newVal.isEmpty ||
                              int.parse(newVal) < 1000 ||
                              int.parse(newVal) > 999999999) {
                            return "Value from 1000 - 999999999";
                          } else {
                            return null;
                          }
                        }),
                        getInfoRow(
                            "Annual MC/VISA Credit Sales Volume",
                            this
                                .widget
                                .controllers["transaction"]
                                    ["AnnualMcViSalesVolume"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["AnnualMcViSalesVolume"],
                            mask: '000000000', validator: (newVal) {
                          if (newVal.isEmpty || int.parse(newVal) < 1000) {
                            return "Minimum Value = 1000";
                          } else {
                            return null;
                          }
                        }),
                        getInfoRow(
                            "Annual Discover Credit Sales Volume",
                            this
                                .widget
                                .controllers["transaction"]
                                    ["AnnualDiSalesVolume"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["AnnualDiSalesVolume"], validator: (newVal) {
                          if (newVal.isEmpty || int.parse(newVal) < 1000) {
                            return "Minimum Value = 1000";
                          } else {
                            return null;
                          }
                        }),
                        getInfoRow(
                            "Annual American Express Credit Sales Volume",
                            this
                                .widget
                                .controllers["transaction"]
                                    ["AnnualAmexOnePointSalesVolume"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["AnnualAmexOnePointSalesVolume"],
                            validator: (newVal) {
                          if (newVal.isEmpty || int.parse(newVal) < 1000) {
                            return "Minimum Value = 1000";
                          } else {
                            return null;
                          }
                        }),
                        getInfoRow(
                            "Highest Ticket Amount",
                            this
                                .widget
                                .controllers["transaction"]["HighestTicket"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["HighestTicket"],
                            mask: '00000000', validator: (newVal) {
                          if (newVal.isEmpty ||
                              int.parse(newVal) < 1000 ||
                              int.parse(newVal) > 999999999) {
                            return "Value from 1000 - 999999999";
                          } else {
                            return null;
                          }
                        }),
                        getInfoDropdown(
                            "Seasonal Merchant",
                            this
                                .widget
                                .controllers["transaction"]["SeasonalMerchant"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["SeasonalMerchant"],
                            yesNoOptions, validator: (newVal) {
                          if (newVal == null) {
                            return "Required";
                          } else {
                            return null;
                          }
                        }),
                        getInfoDropdown(
                            "Season Period From",
                            this
                                .widget
                                .controllers["transaction"]["SeasonalFrom"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["SeasonalFrom"],
                            seasonalMonths,
                            disabled: !this
                                .widget
                                .seasonalMerchant["seasonalMerchant"],
                            validator: (newVal) {
                          if (this
                                  .widget
                                  .controllers["transaction"]
                                      ["SeasonalMerchant"]
                                  .text ==
                              "1") {
                            if (newVal == null) {
                              return "Required";
                            } else {
                              return null;
                            }
                          } else {
                            return null;
                          }
                        }), //MAKE DEPENDANT ON SEASONAL MERCHANT Y/N
                        getInfoDropdown(
                            "Season Period To",
                            this
                                .widget
                                .controllers["transaction"]["SeasonalTo"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["SeasonalTo"],
                            seasonalMonths,
                            disabled: !this
                                .widget
                                .seasonalMerchant["seasonalMerchant"],
                            validator: (newVal) {
                          if (this
                                  .widget
                                  .controllers["transaction"]
                                      ["SeasonalMerchant"]
                                  .text ==
                              "1") {
                            if (newVal == null) {
                              return "Required";
                            } else {
                              return null;
                            }
                          } else {
                            return null;
                          }
                        }), //MAKE DEPENDANT ON SEASONAL MERCHANT Y/N
                        getInfoRow(
                            "% Store front/Swiped",
                            this
                                .widget
                                .controllers["transaction"]["CcPercentPos"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["CcPercentPos"],
                            mask: "000",
                            validator: (newVal) => validateAddedRows(
                                newVal,
                                "Transaction",
                                "CcPercentPos")), //MAKE ADD UP TO 100 1/4
                        getInfoRow(
                            "% Internet",
                            this
                                .widget
                                .controllers["transaction"]["CcPercentInet"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["CcPercentInet"],
                            mask: "000",
                            validator: (newVal) => validateAddedRows(
                                newVal,
                                "Transaction",
                                "CcPercentInet")), //MAKE ADD UP TO 100 2/4
                        getInfoRow(
                            "% Mail Order",
                            this
                                .widget
                                .controllers["transaction"]["CcPercentMo"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["CcPercentMo"],
                            mask: "000",
                            validator: (newVal) => validateAddedRows(
                                newVal,
                                "Transaction",
                                "CcPercentMo")), //MAKE ADD UP TO 100 3/4
                        getInfoRow(
                            "% Telephone Order",
                            this
                                .widget
                                .controllers["transaction"]["CcPercentTo"]
                                .text,
                            this.widget.controllers["transaction"]
                                ["CcPercentTo"],
                            mask: "000",
                            validator: (newVal) => validateAddedRows(
                                newVal,
                                "Transaction",
                                "CcPercentTo")), //MAKE ADD UP TO 100 4/4
                        // getInfoRow(
                        //     "Business Website Address",
                        //     this
                        //         .widget
                        //         .controllers["businessInfo"]
                        //             ["BusinessWebsiteAddress"]
                        //         .text,
                        //     this.widget.controllers["businessInfo"]
                        //         ["BusinessWebsiteAddress"],
                        //     validator: this
                        //                     .widget
                        //                     .controllers["transaction"]
                        //                         ["CcPercentInet"]
                        //                     .text ==
                        //                 "" ||
                        //             this
                        //                     .widget
                        //                     .controllers["transaction"]
                        //                         ["CcPercentInet"]
                        //                     .text ==
                        //                 "0"
                        //         ? null
                        //         : (newVal) => validateRow(newVal,
                        //             "BusinessInfo", "BusinessWebsiteAddress")),
                      ],
                    ),
                  ),
                ]),
          ),
        ));
  }

  Widget getInfoRow(label, value, controller, {mask, validator}) {
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
              child: TextFormField(
                  controller: controller,
                  validator: validator != null ? validator : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfoDropdown(label, value, controller, dropList,
      {validator, bool disabled, bool isSeasonal}) {
    var _currentVal;
    _currentVal = null;
    bool dropDisabled = false;
    bool seasonalMerch = false;
    if (isSeasonal ?? true) {
      seasonalMerch = true;
    }

    if (disabled != null) {
      if (disabled == true) {
        dropDisabled = disabled;
        controller.text = "";
        value = null;
      }
    }

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
                        if (seasonalMerch) {
                          seasonalSwap(newValue);
                        }
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
