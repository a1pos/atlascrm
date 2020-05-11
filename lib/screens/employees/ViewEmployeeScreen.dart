import 'dart:developer';

import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/screens/employees/widgets/Tasks.dart';

class ViewEmployeeScreen extends StatefulWidget {
  final String employeeId;

  ViewEmployeeScreen(this.employeeId);

  @override
  ViewEmployeeScreenState createState() => ViewEmployeeScreenState();
}

class ViewEmployeeScreenState extends State<ViewEmployeeScreen> {
  final ApiService apiService = new ApiService();

  final deviceNameController = new TextEditingController();
  final deviceSerialNumberController = new TextEditingController();

  final _formKey = new GlobalKey<FormState>();

  var isLoading = true;

  Employee employee;

  var defaultRoles = [];

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future<void> initData() async {
    try {
      await loadEmployeeData();
      await loadDefaultRoles();
    } catch (err) {
      log(err);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadEmployeeData() async {
    var resp = await apiService.authGet(
        context, "/employee/" + this.widget.employeeId);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          employee = Employee.fromJson(bodyDecoded);
        });
      }
    }
  }

  Future<void> loadDefaultRoles() async {
    var resp = await apiService.authGet(context, "/role");

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var rolesArr = body;

        var rolesFull = [];

        for (var i = 0; i < List.from(rolesArr).length; i++) {
          rolesFull.add(
              {"display": rolesArr[i]["title"], "value": rolesArr[i]["role"]});
        }

        setState(() {
          defaultRoles = rolesFull;
        });
      }
    }
  }

  Future<void> updateEmployee() async {
    try {
      var resp = await apiService.authPut(
          context, "/employee/" + employee.employee, employee);
      if (resp.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Update Successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);

        await loadEmployeeData();
      } else {
        throw ('ERROR');
      }
    } catch (err) {
      Fluttertoast.showToast(
          msg: "Failed to udpate employee!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);

      await loadEmployeeData();
    }
  }

  void addDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add A Device"),
          content: Form(
            key: _formKey,
            child: Container(
              height: 175,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: deviceNameController,
                          decoration: InputDecoration(labelText: "Device Name"),
                          validator: (value) =>
                              value.isEmpty ? 'Cannot be blank' : null,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: deviceSerialNumberController,
                          decoration: InputDecoration(
                              labelText: "Device Serial Number"),
                          validator: (value) =>
                              value.isEmpty ? 'Cannot be blank' : null,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                final form = _formKey.currentState;
                if (form.validate()) {
                  var devicesList = List.from(employee.document["devices"]);

                  devicesList.add({
                    "deviceId": deviceSerialNumberController.text,
                    "deviceName": deviceNameController.text
                  });

                  employee.document["devices"] = devicesList;

                  await updateEmployee();

                  Navigator.pop(context);
                }
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void deleteEmployeeDevice(deviceId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Device"),
          content: Text("Are you sure you want to delete this device?"),
          actions: <Widget>[
            MaterialButton(
              child: Text("Confirm"),
              onPressed: () async {
                var employeeDeviceArr = List.from(employee.document["devices"]);
                employeeDeviceArr.removeWhere(
                    (deviceToRemove) => deviceToRemove["deviceId"] == deviceId);

                employee.document["devices"] = employeeDeviceArr;

                await updateEmployee();
              },
            ),
            MaterialButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void updateEmployeeRoles(value) {
    if (value == null) return;

    setState(() {
      employee.document["roles"] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: Key("viewEmployeeScreenAppBar"),
        title: Text(isLoading ? "Loading..." : employee.document["fullName"]),
      ),
      body: isLoading
          ? CenteredClearLoadingScreen()
          : Container(
              padding: EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CustomCard(
                      key: Key("viewEmp1"),
                      title: "Account Information",
                      icon: Icons.account_box,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: getLabel("Roles"),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: ListView(
                                    shrinkWrap: true,
                                    children: defaultRoles.map((e) {
                                      var employeeRoles =
                                          employee.document["roles"];

                                      return Row(
                                        children: <Widget>[
                                          Checkbox(
                                            activeColor: Color.fromARGB(
                                                500, 1, 224, 143),
                                            key: Key(e["display"]),
                                            value: employeeRoles
                                                .contains(e["value"]),
                                            onChanged: (bool enabled) {
                                              var roles =
                                                  employee.document["roles"]
                                                      as List<dynamic>;
                                              if (enabled) {
                                                roles.add(e["value"]);
                                              } else {
                                                roles.remove(e["value"]);
                                              }

                                              setState(() {
                                                employee.document["roles"] =
                                                    roles;
                                              });
                                            },
                                          ),
                                          Text(' '),
                                          Text(
                                            e["display"]
                                                .toString()
                                                .toUpperCase(),
                                          ),
                                        ],
                                      );
                                    }).toList()),
                              ),
                            ],
                          ),
                          rowDivider(),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: getLabel("Devices"),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: ListView(
                                  shrinkWrap: true,
                                  children:
                                      List.from(employee.document["devices"])
                                          .map((device) {
                                    return Container(
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 8,
                                            child: Text(
                                              "Name: " + device["deviceName"],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 10,
                                            child: Text(
                                              "Id: " + device["deviceId"],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: GestureDetector(
                                              onTap: () {
                                                deleteEmployeeDevice(
                                                    device["deviceId"]);
                                              },
                                              child: Icon(
                                                Icons.delete,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: MaterialButton(
                                  onPressed: addDeviceDialog,
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      key: Key("viewEmp2"),
                      title: 'History Information',
                      icon: Icons.history,
                      child: Column(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "/employeemaphistory",
                                      arguments: this.widget.employeeId);
                                },
                                child: Container(
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Map History'),
                                      Icon(Icons.arrow_forward_ios, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                              rowDivider(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "/employeecallhistory",
                                      arguments: this.widget.employeeId);
                                },
                                child: Container(
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Call Log'),
                                      Icon(Icons.arrow_forward_ios, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      title: "Tasks",
                      icon: Icons.track_changes,
                      child: Container(
                        height: 200,
                        child: Tasks(employeeId: this.widget.employeeId),
                      ),
                    )
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Color.fromARGB(500, 1, 224, 143),
        onPressed: () async {
          await updateEmployee();
        },
      ),
    );
  }

  Widget getLabel(labelText) {
    return Text(
      '$labelText:',
      style: TextStyle(
        fontSize: 15,
      ),
    );
  }

  Widget rowDivider() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[200],
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
