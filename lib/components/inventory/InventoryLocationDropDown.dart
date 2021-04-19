import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class InventoryLocationDropDown extends StatefulWidget {
  InventoryLocationDropDown(
      {this.employeeId, this.callback, this.value, this.disabled});

  final String employeeId;
  final String value;
  final Function callback;
  final bool disabled;

  @override
  _InventoryLocationDropDownState createState() =>
      _InventoryLocationDropDownState();
}

class _InventoryLocationDropDownState extends State<InventoryLocationDropDown> {
  var locations = [];
  var disabled;
  var startVal;

  @override
  void initState() {
    super.initState();

    initLocations();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  Future<void> initLocations() async {
    QueryOptions options = QueryOptions(
      document: gql("""
        query GET_INVENTORY_LOCATIONS {
          inventory_location{
            inventory_location
            name
          }
        }
      """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var locationsArrDecoded = result.data["inventory_location"];
        if (locationsArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              locations = locationsArrDecoded;
            });
          }
        }
        for (var location in locations) {
          if (this.widget.value == location["inventory_location"]) {
            startVal = location["name"];
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
          'Location',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        SearchableDropdown.single(
          value: startVal,
          onClear: () {
            setState(() {
              this.widget.callback(null);
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          items: locations.map<DropdownMenuItem<String>>((dynamic item) {
            var businessName;
            if (item["name"]?.isEmpty ?? true) {
              businessName = "";
            } else {
              businessName = item["name"];
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
                      if (newValue == location["name"]) {
                        setVal = {
                          "name": location["name"],
                          "location": location["inventory_location"]
                        };
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
