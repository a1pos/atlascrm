import 'dart:convert';
import 'dart:developer';

import 'package:atlascrm/components/CustomAppBar.dart';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/components/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

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
      await loadEmployeeData(this.widget.employeeId);
      await loadDefaultRoles();
    } catch (err) {
      log(err);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadEmployeeData(employeeId) async {
    var resp = await apiService.authGet(
        context, "/employees/" + this.widget.employeeId);

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
    var resp = await apiService.authGet(context, "/employee/roles");

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;
        var rolesArr = bodyDecoded["document"];

        var rolesFull = [];

        for (var i = 0; i < List.from(rolesArr).length; i++) {
          rolesFull.add({"display": rolesArr[i], "value": rolesArr[i]});
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
          context, "/employees/" + employee.employee, employee);
      if (resp.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Update Successful!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);

        await loadEmployeeData(this.widget.employeeId);
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

      await loadEmployeeData(this.widget.employeeId);
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
                await validateAndSave();
                Navigator.pop(context);
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

  Future<void> validateAndSave() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      var devicesList = List.from(employee.document["devices"]);

      devicesList.add({
        "deviceId": deviceSerialNumberController.text,
        "deviceName": deviceNameController.text
      });

      employee.document["devices"] = devicesList;

      await updateEmployee();
    }
  }

  void deleteEmployeeDevice(deviceId) async {
    var employeeDeviceArr = List.from(employee.document["devices"]);
    employeeDeviceArr.removeWhere(
        (deviceToRemove) => deviceToRemove["deviceId"] == deviceId);

    employee.document["devices"] = employeeDeviceArr;

    await updateEmployee();
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
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: ExpansionTile(
                        backgroundColor: Colors.white,
                        leading: Icon(Icons.verified_user),
                        title: Container(
                          child: Text(
                            "Account Information",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: getLabel("Account Status"),
                              ),
                              Expanded(
                                flex: 1,
                                child: Switch(
                                  value: employee.isActive,
                                  onChanged: (value) {
                                    setState(() {
                                      employee.isActive = value;
                                    });
                                  },
                                  activeTrackColor: Colors.green[200],
                                  activeColor: Colors.green,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    rowDivider(),
                    Container(
                      child: ExpansionTile(
                        leading: Icon(Icons.lock),
                        backgroundColor: Colors.white,
                        title: Container(
                          child: Text(
                            "Roles",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        children: <Widget>[
                          MultiSelectFormField(
                            autovalidate: false,
                            titleText: 'Current Roles',
                            validator: (value) {
                              if (value == null || value.length == 0) {
                                return 'Please select one or more options';
                              }
                            },
                            dataSource: defaultRoles,
                            textField: 'display',

                            valueField: 'value',
                            okButtonLabel: 'OK',
                            cancelButtonLabel: 'CANCEL',
                            // required: true,
                            hintText: 'Please choose one or more',
                            value: employee.document["roles"],
                            onSaved: (value) {
                              updateEmployeeRoles(value);
                            },
                          ),
                        ],
                      ),
                    ),
                    rowDivider(),
                    Container(
                      child: ExpansionTile(
                        backgroundColor: Colors.white,
                        leading: Icon(Icons.phone),
                        title: Container(
                          child: Text(
                            "Devices",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        children: <Widget>[
                          ListView(
                            shrinkWrap: true,
                            children: List.from(employee.document["devices"])
                                .map((device) {
                              return Card(
                                child: Container(
                                  color: Colors.green[50],
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          "Name: " + device["deviceName"],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Text(
                                          "Id: " + device["deviceId"],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
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
                                ),
                              );
                            }).toList(),
                          ),
                          MaterialButton(
                            color: Colors.green[200],
                            onPressed: addDeviceDialog,
                            child: Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    rowDivider(),
                    Container(
                      child: ExpansionTile(
                        backgroundColor: Colors.white,
                        leading: Icon(Icons.history),
                        title: Container(
                          child: Text(
                            "Employee History",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              MaterialButton(
                                color: Colors.green[200],
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.track_changes),
                                    Text(' Map History'),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, "/employeemaphistory",
                                      arguments: this.widget.employeeId);
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              ),
                              MaterialButton(
                                color: Colors.green[200],
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.call_split),
                                    Text(' Call Log'),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, "/employeecallhistory",
                                      arguments: this.widget.employeeId);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Colors.blue[300],
        onPressed: () async {
          await updateEmployee();
        },
      ),
    );
  }

  Widget getInfoRow(label, value) {
    var valueFmt = value ?? "N/A";

    if (valueFmt == "") {
      valueFmt = "N/A";
    }

    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Text(
            '$label: ',
            style: TextStyle(fontSize: 16),
          ),
          Text(valueFmt),
        ],
      ),
    );
  }

  Widget getLabel(labelText) {
    return Text(
      '$labelText:',
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }

  Widget rowDivider() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
    );
  }
}
