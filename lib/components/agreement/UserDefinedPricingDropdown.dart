import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class UserDefinedPricingDropDown extends StatefulWidget {
  UserDefinedPricingDropDown(
      {this.callback, this.value, this.disabled, this.validator});

  final String value;
  final Function callback;
  final bool disabled;
  final Function validator;

  @override
  _UserDefinedPricingDropDownState createState() =>
      _UserDefinedPricingDropDownState();
}

class _UserDefinedPricingDropDownState
    extends State<UserDefinedPricingDropDown> {
  final ApiService apiService = ApiService();
  var sicCodes = [];
  var disabled;

  @override
  void initState() {
    super.initState();

    initCodes();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  var startVal;

  Future<void> initCodes() async {
    var sicResp = await apiService.authGet(
        context, "/agreementbuilder/userdefinedpricing");
    if (sicResp != null) {
      if (sicResp.statusCode == 200) {
        var sicArrDecoded = sicResp.data;
        if (sicArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              sicCodes = sicArrDecoded;
            });
          }
        }
        for (var sicCode in sicCodes) {
          if (this.widget.value ==
                  sicCode["user_defined_pricing_grid_value"].toString() ||
              this.widget.value == sicCode["user_defined_pricing_grid_value"]) {
            setState(() {
              startVal = sicCode["description"];
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(
                  'Equipment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 8,
                child: SearchableDropdown.single(
                  validator: this.widget.validator != null
                      ? this.widget.validator
                      : null,
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
                  items: sicCodes.map<DropdownMenuItem<String>>((dynamic item) {
                    var businessName;
                    if (item["description"]?.isEmpty ?? true) {
                      businessName = "";
                    } else {
                      businessName = item["description"];
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
                            for (var sicCode in sicCodes) {
                              if (newValue == sicCode["description"]) {
                                setVal = {
                                  "name": sicCode["description"],
                                  "value": [
                                    sicCode["user_defined_pricing_grid_level"],
                                    sicCode["user_defined_pricing_grid_value"]
                                  ]
                                };
                              }
                            }
                            startVal = newValue;
                            this.widget.callback(setVal);
                          });
                        },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
