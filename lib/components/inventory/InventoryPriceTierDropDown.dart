import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult locationsResp =
        await GqlClientFactory().authGqlquery(options);

    if (locationsResp != null) {
      if (locationsResp.hasException == false) {
        var locationsArrDecoded = locationsResp.data["inventory_price_tier"];
        if (locationsArrDecoded != null) {
          if (this.mounted) {
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
                  setState(() {
                    var setVal;
                    for (var location in locations) {
                      if (newValue == location["model"]) {
                        setVal = location["inventory_price_tier"];
                      }
                    }
                    startVal = setVal;
                    this.widget.callback(setVal);
                  });
                },
        )
      ],
    );
  }
}
