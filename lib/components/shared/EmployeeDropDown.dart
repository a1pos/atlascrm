import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class EmployeeDropDown extends StatefulWidget {
  final bool disabled;
  final bool displayClear;
  final Function callback;
  final List roles;
  final String employeeId;
  final String value;
  final String caption;

  EmployeeDropDown(
      {this.employeeId,
      this.callback,
      this.value,
      this.roles,
      this.disabled = false,
      this.displayClear = true,
      this.caption = "Employee"});

  @override
  _EmployeeDropDownState createState() => _EmployeeDropDownState();
}

class _EmployeeDropDownState extends State<EmployeeDropDown> {
  var employees = [];

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();

    initEmployees();
  }

  var startVal;
  String roleTitleString = "";

  Future<void> initEmployees() async {
    QueryOptions options;
    if (this.widget.roles != null) {
      for (var role in this.widget.roles) {
        roleTitleString += '{roleByRole: {title: {_ilike: "$role"}}}, ';
      }
    }

    options = QueryOptions(
      document: this.widget.roles == null ? gql("""
        query GET_EMPLOYEES {
          employee (where: {is_active: {_eq: true}}) {
            employee
            displayName: document(path: "displayName")
          }
        }
      """) : gql("""
      query GET_EMPLOYEES {
          employee(where: {_and: [{is_active: {_eq: true}}, 
            {_or: 
              [
                $roleTitleString
              ]
            }]}) {
            employee
            displayName: document(path: "displayName")
          }
        }
      """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);
    if (result != null) {
      if (result.hasException == false) {
        var employeeArrDecoded = result.data["employee"];
        if (employeeArrDecoded != null) {
          if (this.mounted) {
            logger.i("Employee data loaded");
            employeeArrDecoded.sort(
              (a, b) => a["displayName"]
                  .toString()
                  .compareTo(b["displayName"].toString()),
            );
            setState(() {
              employees = employeeArrDecoded;
            });
          }
        }
        for (var employee in employees) {
          if (this.widget.value == employee["employee"]) {
            startVal = employee["displayName"];
          }
        }
      } else {
        print(
            "Error getting employees by role: " + result.exception.toString());
        logger.e(
            "Error getting employees by role: " + result.exception.toString());

        Fluttertoast.showToast(
          msg:
              "Error getting employees by role: " + result.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          this.widget.caption,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        SearchableDropdown.single(
          displayClearIcon: this.widget.displayClear,
          value: startVal,
          onClear: () {
            setState(() {
              startVal = null;
              this.widget.callback(null);
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          items: employees.map<DropdownMenuItem<String>>((dynamic item) {
            var employeeName;
            if (item["displayName"]?.isEmpty ?? true) {
              employeeName = "";
            } else {
              employeeName = item["displayName"];
            }
            return DropdownMenuItem<String>(
              value: employeeName,
              child: Text(
                employeeName,
              ),
            );
          }).toList(),
          disabledHint: startVal,
          onChanged: this.widget.disabled
              ? null
              : (newValue) {
                  setState(() {
                    startVal = null;
                    var setVal;
                    if (newValue != null) {
                      for (var employee in employees) {
                        if (newValue == employee["displayName"]) {
                          setVal = employee["employee"];
                        }
                      }

                      logger.i("Employee changed to: " +
                          newValue +
                          " in role(s): " +
                          this.widget.roles.toString());
                    } else {
                      newValue = "";
                      logger.i("Employee filter cleared " +
                          "in role(s): " +
                          this.widget.roles.toString());
                    }
                    startVal = newValue;
                    this.widget.callback(setVal);
                  });
                },
        )
      ],
    );
  }
}
