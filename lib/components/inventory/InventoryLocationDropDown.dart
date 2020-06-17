import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
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
  final ApiService apiService = ApiService();
  var locations = [];
  var disabled;

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

  var startVal;

  Future<void> initLocations() async {
    var locationsResp =
        await apiService.authGet(context, "/inventory/location");
    if (locationsResp != null) {
      if (locationsResp.statusCode == 200) {
        var locationsArrDecoded = locationsResp.data;
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
          // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
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
                        setVal = location["inventory_location"];
                      }
                    }
                    startVal = newValue;
                    this.widget.callback(setVal);
                  });
                },
        )

        // DropdownButtonFormField<String>(
        //   isExpanded: true,
        //   value: this.widget.value,
        //   hint: Text("Please choose one"),
        //   items: leads.map((dynamic item) {
        //     var businessName;
        //     if (item["document"]?.isEmpty ?? true) {
        //       businessName = "";
        //     } else {
        //       businessName = item["document"]["businessName"];
        //     }
        //     return DropdownMenuItem<String>(
        //       value: item["lead"],
        //       child: Text(
        //         businessName,
        //       ),
        //     );
        //   }).toList(),
        //   onChanged: (newValue) {
        //     this.widget.callback(newValue);
        //   },
        // ),
      ],
    );
  }
}
