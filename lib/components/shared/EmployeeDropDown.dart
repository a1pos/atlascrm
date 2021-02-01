import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class EmployeeDropDown extends StatefulWidget {
  EmployeeDropDown(
      {this.employeeId,
      this.callback,
      this.value,
      this.role,
      this.disabled = false,
      this.displayClear = true,
      this.caption = "Employee"});

  final String employeeId;
  final String value;
  final Function callback;
  final String role;
  final bool disabled;
  final bool displayClear;
  final String caption;

  @override
  _EmployeeDropDownState createState() => _EmployeeDropDownState();
}

class _EmployeeDropDownState extends State<EmployeeDropDown> {
  var employees = [];

  @override
  void initState() {
    super.initState();

    initEmployees();
  }

  var startVal;

  Future<void> initEmployees() async {
    QueryOptions options;

    options = QueryOptions(documentNode: gql("""
        query GET_EMPLOYEES {
          employee {
            employee
            displayName: document(path: "displayName")
          }
        }
      """));

    final QueryResult result = await authGqlQuery(options);

    if (result != null) {
      if (result.hasException == false) {
        var employeeArrDecoded = result.data["employee"];
        if (employeeArrDecoded != null) {
          if (this.mounted) {
            employeeArrDecoded.sort((a, b) => a["displayName"]
                .toString()
                .compareTo(b["displayName"].toString()));

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
              this.widget.callback(null);
            });
          },
          hint: "Please choose one",
          searchHint: null,
          isExpanded: true,
          // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
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
                          // {
                          //   "name": employee["title"],
                          //   "employee": employee["employee"]
                          // };
                        }
                      }
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
