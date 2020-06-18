import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class EmployeeDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;
  final String role;

  EmployeeDropDown({this.employeeId, this.callback, this.value, this.role});

  @override
  _EmployeeDropDownState createState() => _EmployeeDropDownState();
}

class _EmployeeDropDownState extends State<EmployeeDropDown> {
  final ApiService apiService = ApiService();

  var employees = [];

  @override
  void initState() {
    super.initState();

    initEmployees();
  }

  Future<void> initEmployees() async {
    var employeeResp = await apiService.authGet(context, "/employee");
    if (employeeResp != null) {
      if (employeeResp.statusCode == 200) {
        var employeeArrDecoded = employeeResp.data;
        if (employeeArrDecoded != null) {
          for (var employee in employeeArrDecoded) {
            if (this.widget.role != null) {
              if (employee["document"]["roles"].contains(this.widget.role)) {
                setState(() {
                  employees.add(employee);
                });
              }
            } else {
              setState(() {
                employees = employeeArrDecoded;
              });
            }
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
          'Employee',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        DropdownButtonFormField<String>(
          validator: (value) {
            if (value == null) {
              return 'Please select an employee';
            }
            return null;
          },
          isExpanded: true,
          value: this.widget.value,
          hint: Text("Please choose one"),
          items: employees.map((dynamic item) {
            return DropdownMenuItem<String>(
              value: item["employee"],
              child: Text(
                item["document"]["fullName"],
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
