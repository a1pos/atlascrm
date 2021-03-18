import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/Empty.dart';

class Employees extends StatefulWidget {
  @override
  _EmployeesState createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  var isLoading = true;
  var isEmpty = true;
  var employees = [];
  var allEmployees = [];

  @override
  void initState() {
    super.initState();

    getEmployeesList();
  }

  Future<void> getEmployeesList() async {
    QueryOptions options;

    options = QueryOptions(documentNode: gql("""
    query GET_EMPLOYEES_LIST{
      employee{
        employee
        document
        is_active
      }
    }
    """), fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        var employeeArrayDecoded = result.data["employee"];

        if (employeeArrayDecoded != null) {
          var employeeArray = List.from(employeeArrayDecoded);

          employeeArray.sort((a, b) => a["document"]["displayName"]
              .toString()
              .compareTo(b["document"]["displayName"].toString()));

          if (employeeArray.length > 0) {
            setState(() {
              isEmpty = false;
              isLoading = false;
              employees = employeeArray;
              allEmployees = employeeArray;
            });
          } else {
            setState(() {
              isEmpty = true;
              isLoading = false;
              employees = [];
              allEmployees = [];
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return employeesList();
  }

  Widget employeesList() {
    return Container(
      height: 450,
      child: isEmpty ? Empty("There are no employees") : getEListView(),
    );
  }

  Widget getEListView() {
    return ListView(
      children: employees.map(
        (emp) {
          var empPicture;
          try {
            empPicture = Image.network(emp["document"]["photoURL"]);

            if (emp["is_active"] != true) {
              empPicture = Image.asset("assets/disabled_user.png");
            }
          } catch (err) {
            empPicture = Image.asset("assets/google_logo.png");

            if (emp["is_active"] != true) {
              empPicture = Image.asset("assets/disabled_user.png");
            }
          }

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/viewemployee",
                  arguments: emp["employee"]);
            },
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: CircleAvatar(
                        child: empPicture,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        emp["document"]["displayName"] ?? "N/A",
                        style: TextStyle(
                            fontSize: 14,
                            color: emp["is_active"] == false
                                ? Colors.grey[400]
                                : Colors.black),
                      ),
                    ),
                  ),
                  emp["is_active"] == false
                      ? Expanded(
                          child: Text(
                            "IA",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
