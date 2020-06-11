import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class LeadDropDown extends StatefulWidget {
  LeadDropDown({this.employeeId, this.callback, this.value, this.disabled});

  final String employeeId;
  final String value;
  final Function callback;
  final bool disabled;

  @override
  _LeadDropDownState createState() => _LeadDropDownState();
}

class _LeadDropDownState extends State<LeadDropDown> {
  final ApiService apiService = ApiService();
  var leads = [];
  var disabled;

  @override
  void initState() {
    super.initState();

    initLeads(this.widget.employeeId);
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  var startVal;

  Future<void> initLeads(e) async {
    var leadsResp = await apiService.authGet(context,
        this.widget.employeeId == null ? "/lead" : "/employee/$e/lead");
    if (leadsResp != null) {
      if (leadsResp.statusCode == 200) {
        var leadsArrDecoded = leadsResp.data["data"];
        if (leadsArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              leads = leadsArrDecoded;
            });
          }
        }
        for (var lead in leads) {
          if (this.widget.value == lead["lead"]) {
            startVal = lead["document"]["businessName"];
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    initLeads(this.widget.employeeId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Lead',
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
          items: leads.map<DropdownMenuItem<String>>((dynamic item) {
            var businessName;
            if (item["document"]?.isEmpty ?? true) {
              businessName = "";
            } else {
              businessName = item["document"]["businessName"];
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
                    for (var lead in leads) {
                      if (newValue == lead["document"]["businessName"]) {
                        setVal = lead["lead"];
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
