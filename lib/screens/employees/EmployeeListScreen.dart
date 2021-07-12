import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';

class EmployeeListScreen extends StatefulWidget {
  final bool isFullScreen;

  EmployeeListScreen(this.isFullScreen);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final UserService userService = new UserService();

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output: CustomOuput(),
  );

  bool isLoading = true;
  bool isEmpty = true;

  List employees = [];
  List employeesFull = [];

  @override
  void initState() {
    super.initState();

    getEmployees();
  }

  Future<void> getEmployees() async {
    QueryOptions options;
    if (UserService.isSalesManager) {
      options = QueryOptions(
        document: gql("""
       query GET_EMPLOYEES {
        employee(where: {_or: [{roleByRole: {title: {_eq: "sales"}}},{roleByRole: {title: {_eq: "salesmanager"}}}]}) {
          employee
          document
          is_active
        }
      }
      """),
      );
    } else {
      options = QueryOptions(
        document: gql("""
        query GET_EMPLOYEES{
          employee{
            employee
            document
            is_active
          }
        }
      """),
      );
    }
    final QueryResult result = await GqlClientFactory().authGqlquery(options);
    if (result.hasException == false) {
      if (result != null) {
        logger.i("Employee list initialized");
        if (result.hasException == false) {
          var employeeArrDecoded = result.data["employee"];
          if (employeeArrDecoded != null) {
            var employeeArr = List.from(employeeArrDecoded);
            employeeArr.sort(
              (a, b) => a["document"]["displayName"].toString().compareTo(
                    b["document"]["displayName"].toString(),
                  ),
            );
            if (employeeArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                employees = employeeArr;
                employeesFull = employeeArr;
              });
            } else {
              setState(() {
                isEmpty = true;
                isLoading = false;
                employees = [];
                employeesFull = [];
              });
            }
          }
        }
      }
    } else {
      logger
          .e("Error in Employees List Screen: " + result.exception.toString());
      Fluttertoast.showToast(
        msg: "Error in Employees List Screen: " + result.exception.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.isFullScreen
        ? Scaffold(
            appBar: CustomAppBar(
              key: Key("employeeListAppBar"),
              title: Text("Employee List"),
            ),
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : getList(this.widget.isFullScreen),
          )
        : getList(this.widget.isFullScreen);
  }

  Widget getList(isFullScreen) {
    return isFullScreen
        ? Container(
            child: isEmpty
                ? Empty("No employees")
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Search Employees",
                            ),
                            onChanged: (value) {
                              var filtered = employeesFull.where((e) {
                                String name = e["document"]["displayName"];

                                return (name != null
                                    ? name
                                        .toLowerCase()
                                        .contains(value.toLowerCase())
                                    : false);
                              }).toList();

                              setState(() {
                                employees = filtered.toList();
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: getListView(),
                        ),
                      ],
                    ),
                  ))
        : Container(
            height: 300,
            child: isEmpty ? Empty("No employees") : getListView(),
          );
  }

  Widget getListView() {
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
              logger.i("Employee selected: " + emp["employee"]);
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
                      padding: emp["is_active"] == false
                          ? EdgeInsets.all(4)
                          : EdgeInsets.all(2),
                      child: CircleAvatar(
                        child: empPicture,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: emp["is_active"] == false
                          ? EdgeInsets.all(8)
                          : EdgeInsets.all(5),
                      child: Text(
                        emp["document"]["displayName"] ?? "N/A",
                        style: TextStyle(
                          fontSize: 14,
                          color: emp["is_active"] == false
                              ? Colors.grey[400]
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  emp["is_active"] == false
                      ? Container(
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
