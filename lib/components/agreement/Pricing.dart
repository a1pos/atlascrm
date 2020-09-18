import 'dart:async';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:flutter/material.dart';

class Pricing extends StatefulWidget {
  final bool finalValidation;
  final Map rateReview;
  final bool pricingDone;
  final Function callback;

  Pricing(
      {this.finalValidation, this.rateReview, this.pricingDone, this.callback});

  @override
  PricingState createState() => PricingState();
}

class PricingState extends State<Pricing> {
  void initState() {
    super.initState();
    // roundSavings(this.widget.rateReview["document"]["summaryPayload"]);
  }

  var monthlySavings;
  var annualSavings;
  var fiveYearSavings;

  Future<void> roundSavings(summary) async {
    setState(() {
      var x = num.parse(summary["monthlySavings"]);
      monthlySavings = x.toStringAsFixed(2);
      var y = num.parse(summary["annualSavings"]);
      annualSavings = y.toStringAsFixed(2);
      var z = summary["fiveYearSavings"];
      fiveYearSavings = z.toStringAsFixed(2);
    });
  }

  Widget build(BuildContext context) {
    var rateReviewType;
    var rateReviewSummary;
    if (this.widget.rateReview != null) {
      rateReviewType = this.widget.rateReview["document"]["type"];
      rateReviewSummary = this.widget.rateReview["document"]["summaryPayload"];
      var x = num.parse(rateReviewSummary["monthlySavings"]);
      monthlySavings = x.toStringAsFixed(2);
      var y = num.parse(rateReviewSummary["annualSavings"]);
      annualSavings = y.toStringAsFixed(2);
      var z = rateReviewSummary["fiveYearSavings"];
      fiveYearSavings = z.toStringAsFixed(2);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            rateReviewSummary != null
                ? CustomCard(
                    key: Key("rates1"),
                    icon: Icons.attach_money,
                    title: "Savings",
                    child: Column(
                      children: <Widget>[
                        Column(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(children: <Widget>[
                              Text("Five Years"),
                              Text("\$$fiveYearSavings",
                                  style: TextStyle(fontSize: 30))
                            ]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(children: <Widget>[
                                Text("Monthly"),
                                // Text(
                                //     "\$${rateReviewSummary[monthlySavings].toStringAsFixed(2)}")
                                Text("\$$monthlySavings",
                                    style: TextStyle(fontSize: 20))
                              ]),
                              Column(children: <Widget>[
                                Text("Yearly"),
                                Text(
                                  "\$$annualSavings",
                                  style: TextStyle(fontSize: 20),
                                )
                              ])
                            ],
                          ),
                        ])
                      ],
                    ),
                  )
                : Container(),
            CustomCard(
              key: Key("rates2"),
              icon: Icons.attach_money,
              title: "Pricing Summary",
              child: Column(
                children: <Widget>[
                  rateReviewSummary != null
                      ? Column(children: <Widget>[
                          rateReviewType == "tier"
                              ? Table(
                                  border: TableBorder(
                                      horizontalInside: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                          style: BorderStyle.solid)),
                                  children: [
                                    TableRow(children: [
                                      TableCell(child: Text('')),
                                      TableCell(child: Text('')),
                                      TableCell(
                                          child: Text('Current Rate',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(
                                        child: Text('New Rate',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      TableCell(
                                          child: Text('Current Fee',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(
                                          child: Text('New Fee',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(
                                          child: Text('Savings',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text(
                                        'Trans. Rate',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      TableCell(child: Text('')),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["currentRate"]}%")),
                                      TableCell(
                                        child: Text(
                                            "${rateReviewSummary["newRate"]}%"),
                                      ),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["currentFee"]}%")),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["newFee"]}%")),
                                      TableCell(child: Text('')),
                                    ]),
                                    rateReviewType == "tier"
                                        ? TableRow(children: [
                                            TableCell(
                                                child: Text('vs/mc/ds',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            TableCell(child: Text('Qual')),
                                            TableCell(
                                                child: Text(
                                                    "${rateReviewSummary["currentQualCreditRate"]}%")),
                                            TableCell(
                                              child: Text(
                                                  "${rateReviewSummary["newQualCreditRate"]}%"),
                                            ),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["currentQualCreditFee"]}")),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["newQualCreditFee"]}")),
                                            TableCell(child: Text('')),
                                          ])
                                        : TableRow(children: [
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                          ]),
                                    rateReviewType == "tier"
                                        ? TableRow(children: [
                                            TableCell(child: Text('')),
                                            TableCell(child: Text('Mid Qual')),
                                            TableCell(
                                                child: Text(
                                                    "${rateReviewSummary["currentMidCreditRate"]}%")),
                                            TableCell(
                                              child: Text(
                                                  "${rateReviewSummary["newMidCreditRate"]}%"),
                                            ),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["currentMidCreditFee"]}")),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["newMidCreditFee"]}")),
                                            TableCell(child: Text('')),
                                          ])
                                        : TableRow(children: [
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                          ]),
                                    rateReviewType == "tier"
                                        ? TableRow(children: [
                                            TableCell(child: Text('')),
                                            TableCell(child: Text('Non Qual')),
                                            TableCell(
                                                child: Text(
                                                    "${rateReviewSummary["currentNonCreditRate"]}%")),
                                            TableCell(
                                              child: Text(
                                                  "${rateReviewSummary["newNonCreditRate"]}%"),
                                            ),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["currentNonCreditFee"]}")),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["newNonCreditFee"]}")),
                                            TableCell(child: Text('')),
                                          ])
                                        : TableRow(children: [
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                          ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('Pin Debit',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["currentPinDebitRate"]}%")),
                                      TableCell(
                                        child: Text(
                                            "${rateReviewSummary["newPinDebitRate"]}%"),
                                      ),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["currentPinDebitFee"]}")),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["newPinDebitFee"]}")),
                                      TableCell(child: Text('')),
                                    ]),
                                    rateReviewType == "tier"
                                        ? TableRow(children: [
                                            TableCell(
                                                child: Text('',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            TableCell(child: Text('Qual')),
                                            TableCell(
                                                child: Text(
                                                    "${rateReviewSummary["currentQualPinDebitRate"]}%")),
                                            TableCell(
                                              child: Text(
                                                  "${rateReviewSummary["newQualPinDebitRate"]}%"),
                                            ),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["currentQualPinDebitFee"]}")),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["newQualPinDebitFee"]}")),
                                            TableCell(child: Text('')),
                                          ])
                                        : TableRow(children: [
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                          ]),
                                    rateReviewType == "tier"
                                        ? TableRow(children: [
                                            TableCell(child: Text('')),
                                            TableCell(child: Text('Mid Qual')),
                                            TableCell(
                                                child: Text(
                                                    "${rateReviewSummary["currentMidPinDebitRate"]}%")),
                                            TableCell(
                                              child: Text(
                                                  "${rateReviewSummary["newMidPinDebitRate"]}%"),
                                            ),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["currentMidPinDebitFee"]}")),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["newMidPinDebitFee"]}")),
                                            TableCell(child: Text('')),
                                          ])
                                        : TableRow(children: [
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                          ]),
                                    rateReviewType == "tier"
                                        ? TableRow(children: [
                                            TableCell(child: Text('')),
                                            TableCell(child: Text('Non Qual')),
                                            TableCell(
                                                child: Text(
                                                    "${rateReviewSummary["currentNonPinDebitRate"]}%")),
                                            TableCell(
                                              child: Text(
                                                  "${rateReviewSummary["newNonPinDebitRate"]}%"),
                                            ),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["currentNonPinDebitFee"]}")),
                                            TableCell(
                                                child: Text(
                                                    "\$${rateReviewSummary["newNonPinDebitFee"]}")),
                                            TableCell(child: Text('')),
                                          ])
                                        : TableRow(children: [
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                            TableCell(child: Text("")),
                                          ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('Cost',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["currentCost"]}")),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["newCost"]}")),
                                      TableCell(child: Text('')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('Savings',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text("Monthly",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text("")),
                                      TableCell(
                                          child: Text(
                                              '\$${rateReviewSummary["monthlySavings"]}')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text("Yearly",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text("")),
                                      TableCell(
                                          child: Text(
                                              '\$${rateReviewSummary["annualSavings"]}')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text("Five Years",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text("")),
                                      TableCell(
                                          child: Text(
                                              '\$${rateReviewSummary["fiveYearSavings"]}')),
                                    ]),
                                  ],
                                )
                              :
                              //------------------------------------------------------------------------
                              Table(
                                  border: TableBorder(
                                      horizontalInside: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                          style: BorderStyle.solid)),
                                  children: [
                                    TableRow(children: [
                                      TableCell(child: Text('')),
                                      TableCell(child: Text('')),
                                      TableCell(
                                          child: Text('Current Rate',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(
                                        child: Text('New Rate',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      TableCell(
                                          child: Text('Current Fee',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(
                                          child: Text('New Fee',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(
                                          child: Text('Savings',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text(
                                        'Trans. Rate',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      TableCell(child: Text('')),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["currentRate"]}%")),
                                      TableCell(
                                        child: Text(
                                            "${rateReviewSummary["newRate"]}%"),
                                      ),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["currentFee"]}%")),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["newFee"]}%")),
                                      TableCell(child: Text('')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('Pin Debit',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(
                                          child: Text(
                                              "${rateReviewSummary["currentPinDebitRate"]}%")),
                                      TableCell(
                                        child: Text(
                                            "${rateReviewSummary["newPinDebitRate"]}%"),
                                      ),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["currentPinDebitFee"]}")),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["newPinDebitFee"]}")),
                                      TableCell(child: Text('')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('Cost',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["currentCost"]}")),
                                      TableCell(
                                          child: Text(
                                              "\$${rateReviewSummary["newCost"]}")),
                                      TableCell(child: Text('')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('Savings',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text("Monthly",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text("")),
                                      TableCell(
                                          child: Text(
                                              '\$${rateReviewSummary["monthlySavings"]}')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text("Yearly",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text("")),
                                      TableCell(
                                          child: Text(
                                              '\$${rateReviewSummary["annualSavings"]}')),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                          child: Text('',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text('')),
                                      TableCell(child: Text("")),
                                      TableCell(
                                        child: Text(""),
                                      ),
                                      TableCell(
                                          child: Text("Five Years",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      TableCell(child: Text("")),
                                      TableCell(
                                          child: Text(
                                              '\$${rateReviewSummary["fiveYearSavings"]}')),
                                    ]),
                                  ],
                                ),
                        ])
                      : Text("No Rate Review")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: FlatButton(
                color: this.widget.finalValidation == true &&
                        this.widget.pricingDone == true
                    ? Color.fromARGB(500, 1, 224, 143)
                    : Colors.grey,
                onPressed: this.widget.finalValidation == true &&
                        this.widget.pricingDone == true
                    ? this.widget.callback
                    : () {
                        return null;
                      },
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showInfoRow(label, value) {
    if (value == null) {
      value = "";
    }
    return Container(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(flex: 8, child: Text(value)),
          ],
        ),
      ),
    );
  }
}
