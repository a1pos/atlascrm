import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class InventoryPriceTierDropDown extends StatefulWidget {
  InventoryPriceTierDropDown(
      {this.employeeId, this.callback, this.value, this.disabled});

  final String employeeId;
  final String value;
  final Function callback;
  final bool disabled;

  @override
  _InventoryPriceTierDropDownState createState() =>
      _InventoryPriceTierDropDownState();
}

class _InventoryPriceTierDropDownState
    extends State<InventoryPriceTierDropDown> {
  var locations = [];
  var disabled;
  var startVal;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();

    initPriceTiers();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  Future<void> initPriceTiers() async {
    QueryOptions options = QueryOptions(
      document: gql("""
        query GET_PRICE_TIERS {
          inventory_price_tier{
            inventory_price_tier
            model    
          }
        }
      """),
    );

    final QueryResult locationsResp =
        await GqlClientFactory().authGqlquery(options);

    if (locationsResp != null) {
      if (locationsResp.hasException == false) {
        var locationsArrDecoded = locationsResp.data["inventory_price_tier"];
        if (locationsArrDecoded != null) {
          if (this.mounted) {
            Future.delayed(Duration(seconds: 1), () {
              logger.i("Inventory price tiers loaded");
            });

            setState(() {
              locations = locationsArrDecoded;
            });
          }
        }
        for (var location in locations) {
          if (this.widget.value == location["inventory_price_tier"]) {
            startVal = location["model"];
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1), () {
          logger.e("ERROR: Error loading inventory price tiers for dropdown: " +
              locationsResp.exception.toString());
        });

        Fluttertoast.showToast(
          msg: "Error loading inventory price tiers for dropdown: " +
              locationsResp.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Price Tier',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        SearchableDropdown.single(
          value: startVal,
          onClear: () {
            startVal = null;
            setState(() {
              this.widget.callback("");
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          items: locations.map<DropdownMenuItem<String>>((dynamic item) {
            var businessName;
            if (item["model"]?.isEmpty ?? true) {
              businessName = "";
            } else {
              businessName = item["model"];
            }
            return DropdownMenuItem<String>(
              value: businessName,
              child: Text(
                businessName,
              ),
            );
          }).toList(),
          disabledHint: startVal,
          onChanged: disabled
              ? null
              : (newValue) {
                  if (newValue != null) {
                    setState(() {
                      var setVal;
                      for (var location in locations) {
                        if (newValue == location["model"]) {
                          setVal = location["inventory_price_tier"];
                        }
                      }
                      startVal = setVal;
                      this.widget.callback(setVal);
                      Future.delayed(Duration(seconds: 1), () {
                        logger.i("Changed inventory price tier: " +
                            newValue +
                            " (" +
                            setVal +
                            ")");
                      });
                    });
                  } else {
                    setState(() {
                      startVal = null;
                      this.widget.callback(null);
                    });
                    Future.delayed(Duration(seconds: 1), () {
                      logger.i("Inventory price dropdown value cleared");
                    });
                  }
                },
        )
      ],
    );
  }
}
