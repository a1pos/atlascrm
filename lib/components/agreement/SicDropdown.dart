import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class SicDropDown extends StatefulWidget {
  SicDropDown({this.callback, this.value, this.disabled});

  final String value;
  final Function callback;
  final bool disabled;

  @override
  _SicDropDownState createState() => _SicDropDownState();
}

class _SicDropDownState extends State<SicDropDown> {
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
    var sicResp = await apiService.authGet(context, "/agreementbuilder/sic");
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
          if (this.widget.value == sicCode["ref_value"]) {
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
                  'SIC/MCC Code',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 8,
                child: SearchableDropdown.single(
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
                                  "value": sicCode["ref_value"]
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
