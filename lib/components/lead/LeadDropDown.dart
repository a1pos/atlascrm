import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class LeadDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;

  LeadDropDown({this.employeeId, this.callback, this.value});

  @override
  _LeadDropDownState createState() => _LeadDropDownState();
}

class _LeadDropDownState extends State<LeadDropDown> {
  final ApiService apiService = ApiService();

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
            ? "/lead"
            : "/employee/${this.widget.employeeId}/lead");
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
        DropdownButton<String>(
          isExpanded: true,
          value: this.widget.value,
          hint: Text("Please choose one"),
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
        ),
      ],
    );
  }
}
