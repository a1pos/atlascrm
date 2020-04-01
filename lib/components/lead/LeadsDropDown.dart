import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class LeadsDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;

  LeadsDropDown({this.employeeId, this.callback, this.value});

  @override
  _LeadsDropDownState createState() => _LeadsDropDownState();
}

class _LeadsDropDownState extends State<LeadsDropDown> {
  final ApiService apiService = ApiService();

  var dropDownValue;

  var leads = [];

  @override
  void initState() {
    super.initState();

    initLeads();
  }

  Future<void> initLeads() async {
    var leadsResp = await apiService.authGet(
        context,
        this.widget.employeeId == null
            ? "/leads"
            : "/leads/byemployee/${this.widget.employeeId}");
    if (leadsResp != null) {
      if (leadsResp.statusCode == 200) {
        var leadsArrDecoded = leadsResp.data;
        if (leadsArrDecoded != null) {
          setState(() {
            leads = leadsArrDecoded;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: this.widget.value,
      hint: Text("Lead"),
      items: leads.map((dynamic item) {
        return DropdownMenuItem<String>(
          value: item["lead"],
          child: Text(
            item["document"]["businessName"],
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        this.widget.callback(newValue);
      },
    );
  }
}
