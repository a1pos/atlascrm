import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';

class EmployeeListScreen extends StatefulWidget {
  final bool isFullScreen;

  EmployeeListScreen(this.isFullScreen);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final UserService userService = new UserService();
  final ApiService apiService = new ApiService();

  var employees = [];
  var employeesFull = [];
  var isLoading = true;
  var isEmpty = true;

  @override
  void initState() {
    super.initState();

    getEmployees();
  }

  Future<void> getEmployees() async {
    var resp = await apiService.authGet(context, "/employee");
    if (resp != null) {
      if (resp.statusCode == 200) {
        var employeeArrDecoded = resp.data;
        if (employeeArrDecoded != null) {
          var employeeArr = List.from(employeeArrDecoded);
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
                : Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Search Employees",
                          ),
                          onChanged: (value) {
                            var filtered = employeesFull.where((e) {
                              String name = e["document"]["fullName"];
                              return name
                                  .toLowerCase()
                                  .contains(value.toLowerCase());
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
          )
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
            empPicture =
                Image.network(emp["document"]["googleClaims"]["picture"]);
          } catch (err) {
            empPicture = Image.asset("assets/google_logo.png");
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
                    flex: 8,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        emp["document"]["fullName"] ?? "N/A",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
