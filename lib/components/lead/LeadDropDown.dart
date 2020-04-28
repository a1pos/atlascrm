import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class LeadDropDown extends StatefulWidget {
  LeadDropDown({this.employeeId, this.callback, this.value});

  final String employeeId;
  final String value;
  final Function callback;

  @override
  _LeadDropDownState createState() => _LeadDropDownState();
}

class _LeadDropDownState extends State<LeadDropDown> {
  final ApiService apiService = ApiService();

  var leads = [];

  @override
  void initState() {
    super.initState();
    initLeads(this.widget.employeeId);
  }

  Future<void> initLeads(e) async {
    var leadsResp = await apiService.authGet(context,
        this.widget.employeeId == null ? "/lead" : "/employee/$e/lead");
    if (leadsResp != null) {
      if (leadsResp.statusCode == 200) {
        var leadsArrDecoded = leadsResp.data;
        if (leadsArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              leads = leadsArrDecoded;
            });
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
        DropdownButtonFormField<String>(
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
