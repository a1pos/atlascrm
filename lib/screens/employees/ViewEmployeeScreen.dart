import 'dart:developer';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/RoleDropdown.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/screens/employees/widgets/Tasks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ViewEmployeeScreen extends StatefulWidget {
  final String employeeId;

  ViewEmployeeScreen(this.employeeId);

  @override
  ViewEmployeeScreenState createState() => ViewEmployeeScreenState();
}

class ViewEmployeeScreenState extends State<ViewEmployeeScreen> {
  final deviceNameController = new TextEditingController();
  final deviceIdController = new TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  bool isLoading = true;

  var employee;

  var defaultRoles = [];
  var devices = [];
  var subscription;

  @override
  void initState() {
    super.initState();

    initData();
  }

  @override
  void dispose() async {
    super.dispose();
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
  }

  Future<void> initData() async {
    try {
      await loadEmployeeData();
      await loadDevices();
    } catch (err) {
      log(err);
    }
    setState(
      () {
        isLoading = false;
      },
    );
  }

  Future<void> loadDevices() async {
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "SUB_EMPLOYEE_DEVICES",
      document: gql("""
        subscription SUB_EMPLOYEE_DEVICES(\$employee: uuid!) {
          employee_device(where: {employee: {_eq: \$employee}}) {
            employee_device
            deviceName: document(path: "deviceName")
            device_id
          }
        }
    """),
      fetchPolicy: FetchPolicy.networkOnly,
      variables: {"employee": "${this.widget.employeeId}"},
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) {
        var deviceArrDecoded = data.data["employee_device"];
        if (deviceArrDecoded != null) {
          if (this.mounted) {
            setState(() {
              devices = deviceArrDecoded.toList();
            });
          }
        }
      },
      (error) {},
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      loadDevices();
    }
  }

  Future<void> loadEmployeeData() async {
    QueryOptions options = QueryOptions(document: gql("""
      query GET_EMPLOYEE{
        employee_by_pk(employee: "${this.widget.employeeId}"){
          employee
          document
          role
        }
      }
    """), fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result.hasException == false) {
      var body = result.data["employee_by_pk"];
      if (body != null) {
        var bodyDecoded = body;

        setState(
          () {
            employee = bodyDecoded;

            if (employee["document"]["displayName"] == null) {
              employee["document"]["displayName"] = "N/A";
            }
          },
        );
      }
    }
  }

  Future<void> updateRole(role) async {
    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_ROLE (\$employee: uuid!, \$role: uuid!){
        update_employee_by_pk(pk_columns: {employee: \$employee}, _set: {role: \$role}){
          roleByRole{
            role
            title
          }
        }
      }
          """),
      fetchPolicy: FetchPolicy.networkOnly,
      variables: {"employee": this.widget.employeeId, "role": role},
    );
    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);
    if (result.hasException == true) {
      Fluttertoast.showToast(
          msg: result.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Fluttertoast.showToast(
        msg: "Role set to " +
            result.data["update_employee_by_pk"]["roleByRole"]["title"] +
            "!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0);
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
                          controller: deviceIdController,
                          decoration: InputDecoration(labelText: "Device ID"),
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
                  Map newDevice = {
                    "employee": this.widget.employeeId,
                    "device_id": deviceIdController.text,
                    "document": {"deviceName": deviceNameController.text}
                  };
                  //LOGIC TO MUTATE ADD DEVICE
                  MutationOptions mutateOptions = MutationOptions(
                      document: gql("""
                        mutation INSERT_ONE_EMPLOYEE_DEVICE (\$object: employee_device_insert_input!){
                          insert_employee_device_one(object: \$object){
                          employee_device
                        }
                      }
                  """),
                      fetchPolicy: FetchPolicy.networkOnly,
                      variables: {"object": newDevice});

                  final QueryResult result =
                      await GqlClientFactory().authGqlmutate(mutateOptions);

                  if (result.hasException == true) {
                    Fluttertoast.showToast(
                        msg: result.exception.toString(),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.grey[600],
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }

                  deviceIdController.text = "";
                  deviceNameController.text = "";

                  Navigator.pop(context);

                  Fluttertoast.showToast(
                      msg: "Device Added!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                      fontSize: 16.0);
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
              child: Text("Confirm",
                  style: TextStyle(fontSize: 17, color: Colors.green)),
              onPressed: () async {
                //LOGIC TO MUTATE DELETE A DEVICE
                MutationOptions mutateOptions = MutationOptions(
                  document: gql("""
                      mutation INSERT_ONE_EMPLOYEE_DEVICE(\$employee_device: uuid!) {
                        delete_employee_device_by_pk(employee_device: \$employee_device){
                          employee_device
                        }
                      }
                  """),
                  fetchPolicy: FetchPolicy.networkOnly,
                  variables: {"employee_device": deviceId},
                );

                final QueryResult result =
                    await GqlClientFactory().authGqlmutate(mutateOptions);

                if (result.hasException == true) {
                  Fluttertoast.showToast(
                      msg: result.exception.toString(),
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
                Navigator.pop(context);

                Fluttertoast.showToast(
                    msg: "Device Deleted!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey[600],
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
            ),
            MaterialButton(
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
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
      employee["document"]["roles"] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalStyles.backgroundColor,
      appBar: CustomAppBar(
        key: Key("viewEmployeeScreenAppBar"),
        title: Text(
          isLoading ? "Loading..." : employee["document"]["displayName"],
        ),
      ),
      body: isLoading
          ? CenteredLoadingSpinner()
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
                          Row(children: <Widget>[
                            Expanded(
                              child: RoleDropDown(
                                  value: employee["role"],
                                  callback: (newValue) {
                                    setState(() {
                                      employee["role"] = newValue;
                                    });
                                    updateRole(newValue);
                                  }),
                            )
                          ]),
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
                                  children: List.from(devices).map(
                                    (device) {
                                      return Card(
                                        child: ListTile(
                                          title: Text(
                                            device["deviceName"],
                                          ),
                                          subtitle: Text(
                                            "ID: " + device["device_id"],
                                          ),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              deleteEmployeeDevice(
                                                  device["employee_device"]);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
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
                                      arguments: employee);
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
                        child: Tasks(employee: this.widget.employeeId),
                      ),
                    )
                  ],
                ),
              ),
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
