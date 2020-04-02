import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class EmployeeDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;

  EmployeeDropDown({this.employeeId, this.callback, this.value});

  @override
  _EmployeeDropDownState createState() => _EmployeeDropDownState();
}

class _EmployeeDropDownState extends State<EmployeeDropDown> {
  final ApiService apiService = ApiService();

  var dropDownValue;

  var employees = [];

  @override
  void initState() {
    super.initState();

    initEmployees();
  }

  Future<void> initEmployees() async {
    var employeeResp = await apiService.authGet(context, "/employees");
    if (employeeResp != null) {
      if (employeeResp.statusCode == 200) {
        var employeeArrDecoded = employeeResp.data;
        if (employeeArrDecoded != null) {
          setState(() {
            employees = employeeArrDecoded;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: dropDownValue,
      hint: Text("Employee"),
      items: employees.map((dynamic item) {
        return DropdownMenuItem<String>(
          value: item["employee"],
          child: Text(
            item["document"]["fullName"],
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        this.widget.callback(newValue);
      },
    );
  }
}
