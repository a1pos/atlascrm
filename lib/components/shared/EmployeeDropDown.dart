import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class EmployeeDropDown extends StatefulWidget {
  EmployeeDropDown(
      {this.employeeId, this.callback, this.value, this.role, this.disabled});

  final String employeeId;
  final String value;
  final Function callback;
  final String role;
  final bool disabled;

  @override
  _EmployeeDropDownState createState() => _EmployeeDropDownState();
}

class _EmployeeDropDownState extends State<EmployeeDropDown> {
  final ApiService apiService = ApiService();
  var employees = [];
  var disabled;

  @override
  void initState() {
    super.initState();

    initEmployees();
    if (this.widget.disabled != null) {
      setState(() {
        disabled = this.widget.disabled;
      });
    } else {
      disabled = false;
    }
  }

  var startVal;

  Future<void> initEmployees() async {
    QueryOptions options = QueryOptions(documentNode: gql("""
      query Employee {
        employee {
          employee
          fullName:document(path:"fullName")
        }
      }
    """));

    final QueryResult result = await client.query(options);

    if (result != null) {
      if (!result.hasException) {
        var employeeArrDecoded = result.data["employee"];
        if (employeeArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              employees = employeeArrDecoded;
            });
          }
        }
        for (var employee in employees) {
          if (this.widget.value == employee["employee"]) {
            startVal = employee["fullName"];
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
          items: employees.map<DropdownMenuItem<String>>((dynamic item) {
            var employeeName;
            if (item["fullName"]?.isEmpty ?? true) {
              employeeName = "";
            } else {
              employeeName = item["fullName"];
            }
            return DropdownMenuItem<String>(
              value: employeeName,
              child: Text(
                employeeName,
              ),
            );
          }).toList(),
          disabledHint: startVal,
          onChanged: disabled
              ? null
              : (newValue) {
                  setState(() {
                    var setVal;
                    for (var employee in employees) {
                      if (newValue == employee["fullName"]) {
                        setVal = employee["employee"];
                        // {
                        //   "name": employee["title"],
                        //   "employee": employee["employee"]
                        // };
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

// import 'package:atlascrm/services/ApiService.dart';
// import 'package:flutter/material.dart';

// class EmployeeDropDown extends StatefulWidget {
//   final String employeeId;
//   final String value;
//   final Function callback;
//   final String role;

//   EmployeeDropDown({this.employeeId, this.callback, this.value, this.role});

//   @override
//   _EmployeeDropDownState createState() => _EmployeeDropDownState();
// }

// class _EmployeeDropDownState extends State<EmployeeDropDown> {
//   final ApiService apiService = ApiService();

//   var employees = [];

//   @override
//   void initState() {
//     super.initState();

//     initEmployees();
//   }

//   Future<void> initEmployees() async {
//     var employeeResp = await apiService.authGet(context, "/employee");
//     if (employeeResp != null) {
//       if (employeeResp.statusCode == 200) {
//         var employeeArrDecoded = employeeResp.data;
//         if (employeeArrDecoded != null) {
//           if (this.widget.role != null) {
//             for (var employee in employeeArrDecoded) {
//               if (employee["document"]["roles"].contains(this.widget.role)) {
//                 setState(() {
//                   employees.add(employee);
//                 });
//               }
//             }
//           } else {
//             setState(() {
//               employees = employeeArrDecoded;
//             });
//           }
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           'Employee',
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 13,
//           ),
//         ),
//         DropdownButtonFormField<String>(
//           validator: (value) {
//             if (value == null) {
//               return 'Please select an employee';
//             }
//             return null;
//           },
//           isExpanded: true,
//           value: this.widget.value,
//           hint: Text("Please choose one"),
//           items: employees.map((dynamic item) {
//             return DropdownMenuItem<String>(
//               value: item["employee"],
//               child: Text(
//                 item["document"]["fullName"],
//               ),
//             );
//           }).toList(),
//           onChanged: (newValue) {
//             this.widget.callback(newValue);
//           },
//         ),
//       ],
//     );
//   }
// }
