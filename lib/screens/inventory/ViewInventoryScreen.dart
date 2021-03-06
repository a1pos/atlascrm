import 'dart:async';
import 'package:round2crm/components/inventory/InventoryHistoryList.dart';
import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/CustomCard.dart';
import 'package:round2crm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:round2crm/components/shared/MerchantDropdown.dart';

class ViewInventoryScreen extends StatefulWidget {
  final Map incoming;

  ViewInventoryScreen(this.incoming);

  @override
  ViewInventoryScreenState createState() => ViewInventoryScreenState();
}

class ViewInventoryScreenState extends State<ViewInventoryScreen> {
  final _leadFormKey = GlobalKey<FormState>();

  bool idChanged = false;
  bool isLoading = true;
  String addressText;
  Map inventory;

  var serialNumberController = TextEditingController();
  var priceTierController = TextEditingController();
  var merchantController = TextEditingController();
  var merchantNameController = TextEditingController();
  var idController = TextEditingController();

  var deviceIcon;

  var historyList = [];
  var inventoryDocument;

  var displayPhone;
  var deviceStatus = "?";

  var employee;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  List<UnicornButton> childButtons = [];

  void initState() {
    super.initState();

    loadInventoryData();
  }

  Future<void> initStatus() async {
    childButtons = <UnicornButton>[];

    if (inventory["is_installed"] == true) {
      deviceStatus = "Installed";
      deviceIcon = Icons.done;
      childButtons.add(
        UnicornButton(
          hasLabel: true,
          labelText: "Return",
          currentButton: FloatingActionButton(
            heroTag: "return",
            backgroundColor: Colors.redAccent,
            mini: true,
            child: Icon(Icons.replay),
            onPressed: () {
              updateDevice("return");
            },
          ),
        ),
      );
    }
    if (inventory["merchantByMerchant"] != null &&
        inventory["is_installed"] != true) {
      deviceStatus = "Awaiting Install";
      deviceIcon = Icons.directions_car;
      childButtons.add(
        UnicornButton(
          hasLabel: true,
          labelText: "Install",
          currentButton: FloatingActionButton(
            heroTag: "install",
            backgroundColor: Colors.greenAccent,
            mini: true,
            child: Icon(Icons.build),
            onPressed: () {
              updateDevice("install");
            },
          ),
        ),
      );

      childButtons.add(
        UnicornButton(
          hasLabel: true,
          labelText: "Return",
          currentButton: FloatingActionButton(
            heroTag: "return2",
            backgroundColor: Colors.redAccent,
            mini: true,
            child: Icon(Icons.replay),
            onPressed: () {
              updateDevice("return");
            },
          ),
        ),
      );
    }
    if (inventory["merchantByMerchant"] == null &&
        inventory["employeeByEmployee"] == null) {
      deviceStatus = "In Warehouse";
      deviceIcon = Icons.business;
      childButtons.add(
        UnicornButton(
          hasLabel: true,
          labelText: "Checkout",
          currentButton: FloatingActionButton(
            heroTag: "checkout",
            backgroundColor: Colors.blueAccent,
            mini: true,
            child: Icon(Icons.devices),
            onPressed: () {
              checkout();
            },
          ),
        ),
      );
    }
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Device status: " + deviceStatus);
    });
  }

  Future<void> loadInventoryData() async {
    QueryOptions options = QueryOptions(
      document: gql("""
        query GET_INVENTORY{inventory_by_pk(inventory: "${this.widget.incoming["id"]}"){
            inventory
            merchantByMerchant{
              merchant
              document
            }
            is_installed
            employeeByEmployee{
              employee
              document
            }
            id
            serial
            inventoryLocationByInventoryLocation{
              name
            }
            inventoryPriceTierByInventoryPriceTier{
              model
            }
            document
          }
        }
        """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result.hasException == false) {
      var body = result.data["inventory_by_pk"];
      if (body != null) {
        var bodyDecoded = body;
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Device information loaded");
        });

        setState(
          () {
            inventory = bodyDecoded;
            if (inventory["id"] != null) {
              idController.text = inventory["id"];
            }
            if (inventory["merchantByMerchant"] != null) {
              merchantController.text =
                  inventory["merchantByMerchant"]["merchant"];

              merchantNameController.text = inventory["merchantByMerchant"]
                  ["document"]["leadDocument"]["businessName"];
            } else {
              merchantController.text = null;
              merchantNameController.text = null;
            }

            if (inventory["employeeByEmployee"] != null) {
              if (inventory["employeeByEmployee"]["document"]["displayName"] !=
                  null) {
                setState(
                  () {
                    employee = inventory["employeeByEmployee"]["document"]
                        ["displayName"];
                  },
                );
              }
            }
            idController.addListener(
              () {
                if (!idChanged) idChanged = true;
              },
            );
            isLoading = false;
          },
        );
      }
    } else {
      Future.delayed(Duration(seconds: 1), () {
        logger
            .e("Error loading Inventory data: " + result.exception.toString());
      });
      Fluttertoast.showToast(
        msg: result.exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    initStatus();
  }

  Future<void> updateDevice(type) async {
    Map data = {};
    var alert;

    alert = "ID updated!";

    if (type != "id") {
      if (type == "checkout") {
        data = {
          "employee": UserService.employee.employee,
          "merchant": merchantController.text,
          "id": idController.text
        };
        alert = "Device checked out!";
      }
      if (type == "return") {
        data = {
          "merchant": null,
          "employee": null,
          "is_installed": false,
          "id": idController.text
        };
        alert = "Device returned!";
      }
      if (type == "install") {
        data = {"is_installed": true, "id": idController.text};
        alert = "Device installed!";
      }
    } else {
      data = {"id": idController.text};
    }

    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
      mutation UPDATE_INVENTORY (\$data: inventory_set_input){
        update_inventory_by_pk(pk_columns: {inventory: "${this.widget.incoming["id"]}"}, _set:\$data){
          inventory
          document
        }
      }
      """),
      fetchPolicy: FetchPolicy.networkOnly,
      variables: {
        "data": data,
      },
    );
    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);

    if (result.hasException == false) {
      Future.delayed(Duration(seconds: 1), () {
        logger.i(alert +
            " Merchant: " +
            merchantNameController.text +
            " (" +
            merchantController.text +
            ")");
      });
      Fluttertoast.showToast(
        msg: alert,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      loadInventoryData();
    } else {
      Future.delayed(Duration(seconds: 1), () {
        logger.e(
            "ERROR: Error checking out device: " + result.exception.toString());
      });

      Fluttertoast.showToast(
        msg: result.exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> checkout() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Text('Checkout this Device'),
                ),
                MerchantDropDown(
                  callback: (newValue) {
                    setState(
                      () {
                        merchantController.text = newValue["id"];
                        merchantNameController.text = newValue["name"];
                      },
                    );
                    if (newValue[0] != null) {
                      Future.delayed(Duration(seconds: 1), () {
                        logger.i("Merchant selected: " + newValue["name"]);
                      });
                    }
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Checkout',
                style: TextStyle(fontSize: 17, color: Colors.green),
              ),
              onPressed: () {
                if (merchantController.text != null &&
                    merchantController.text != "") {
                  setState(() {
                    updateDevice("checkout");
                  });

                  Navigator.of(context).pop();
                } else {
                  Future.delayed(Duration(seconds: 1), () {
                    logger.i("Merchant not selected for checkout");
                  });

                  Fluttertoast.showToast(
                    msg: "Please select a merchant",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey[600],
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCheck() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete from inventory?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this device?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 17),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
              onPressed: () {
                deleteDevice();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteDevice() async {
    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
     mutation DELETE_INVENTORY (\$inventory: uuid!){
      delete_inventory_by_pk(inventory: \$inventory){
        serial
      }
    }
          """),
      fetchPolicy: FetchPolicy.noCache,
      variables: {"inventory": inventory["inventory"]},
    );
    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);

    if (result.hasException == true) {
      Future.delayed(Duration(seconds: 1), () {
        logger.e(
          "Error deleting inventory device: " + result.exception.toString(),
        );
      });

      Fluttertoast.showToast(
        msg: result.exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Navigator.popAndPushNamed(context, "/inventory");
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Inventory device deleted: " + inventory["inventory"]);
      });

      Fluttertoast.showToast(
        msg: "Device deleted!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  getEmployee(employeeId) async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_EMPLOYEE_BY_PK {
        employee_by_pk(employee: "$employeeId"){
          displayName: document(path: "displayName")
        }
      }
    """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result.hasException == false) {
      var body = result.data["employee_by_pk"];
      if (body != null) {
        return await body["displayName"];
      }
    } else {
      Fluttertoast.showToast(
        msg: result.exception.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Future.delayed(Duration(seconds: 1), () {
        logger.e("ERROR: Error getting employee data: " +
            result.exception.toString());
      });
    }
  }

  Widget buildHistoryList() {
    var historyList = [];
    if (inventory["inventory_trackings"].length != 0) {
      var reversed = List.from(inventory["inventory_trackings"].reversed);
      historyList = reversed;
    }

    Future.delayed(Duration(seconds: 1), () {
      logger.i("Device history list built");
    });

    return ListView(
      shrinkWrap: true,
      children: List.generate(
        historyList.length,
        (index) {
          var event = historyList[index];
          var eventType =
              event["inventoryTrackingTypeByInventoryTrackingType"]["title"];
          var eventEmployee;
          if (eventType == "Returned" || eventType == "Scanned In") {
            eventEmployee = FutureBuilder(
              future: getEmployee(event["created_by"]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    return Text(snapshot.data);
                  }
                  return Container();
                } else if (snapshot.hasError) {
                  logger
                      .e("Error getting employee" + snapshot.error.toString());
                  return Text(
                      "Error getting employee" + snapshot.error.toString());
                } else {
                  return Text("loading...");
                }
              },
            );
          } else {
            eventEmployee =
                Text(event["employeeByEmployee"]["document"]["displayName"]);
          }
          var initDate = DateTime.parse(event["created_at"]).toLocal();
          var eventDate = DateFormat.yMd().add_jm().format(initDate);
          var inventoryMerchant = event["merchant"];
          var inventoryMerchantDoc = event["merchantByMerchant"];
          var otherCompany = false;

          if (inventoryMerchantDoc == null && inventoryMerchant != null) {
            otherCompany = true;
          }

          return !otherCompany
              ? Card(
                  shape: new RoundedRectangleBorder(
                      side: new BorderSide(color: Colors.grey[200], width: 2.0),
                      borderRadius: BorderRadius.circular(4.0)),
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(
                      eventType == "Returned" || eventType == "Scanned In"
                          ? event["inventoryLocationByInventoryLocation"]
                              ["name"]
                          : event["merchantByMerchant"]["document"]
                              ["leadDocument"]["businessName"],
                      style:
                          eventType == "Returned" || eventType == "Scanned In"
                              ? TextStyle(color: UniversalStyles.actionColor)
                              : null,
                    ),
                    subtitle: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: eventEmployee,
                      ),
                    ),
                    trailing: Column(
                      children: <Widget>[
                        Text(eventDate),
                        Text(eventType),
                      ],
                    ),
                  ),
                )
              : Container();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (idChanged) {
          await updateDevice("id");
        }
        Navigator.pop(context);

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: UniversalStyles.backgroundColor,
        appBar: CustomAppBar(
          key: Key("viewTasksAppBar"),
          title: Text(isLoading ? "Loading..." : inventory["serial"]),
          action: <Widget>[
            UserService.isAdmin
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
                    child: IconButton(
                      onPressed: () {
                        deleteCheck();
                      },
                      icon: Icon(Icons.delete, color: Colors.white),
                    ),
                  )
                : Container()
          ],
        ),
        body: isLoading
            ? CenteredClearLoadingScreen()
            : Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _leadFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomCard(
                          key: Key("inventory1"),
                          icon: Icons.devices,
                          title: "Device Info.",
                          child: Column(
                            children: <Widget>[
                              showInfoRow(
                                  "Model",
                                  inventory[
                                          "inventoryPriceTierByInventoryPriceTier"]
                                      ["model"]),
                              showInfoRow("Serial Number", inventory["serial"]),
                              inventory["merchantByMerchant"] == null &&
                                      inventory["employeeByEmployee"] == null
                                  ? Container()
                                  : getInfoRow(
                                      "ID", idController.text, idController),
                              showInfoRow(
                                  "Location",
                                  inventory[
                                          "inventoryLocationByInventoryLocation"]
                                      ["name"]),
                              showInfoRow("Current Merchant",
                                  merchantNameController.text),
                              showInfoRow("Current Employee", employee),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(17, 0, 0, 0),
                                    child: Text(
                                      "Status:",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 8, 0, 8),
                                      child: Text(
                                        deviceStatus,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          70, 0, 0, 0),
                                      child: Icon(deviceIcon),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("inventory2"),
                          icon: Icons.history,
                          title: "Device History",
                          child: ConstrainedBox(
                            constraints: new BoxConstraints(
                              minHeight: 35.0,
                              maxHeight: 340.0,
                            ),
                            child: Scrollbar(
                              child: InventoryHistoryList(
                                this.widget.incoming["id"],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.0),
          parentButtonBackground: UniversalStyles.actionColor,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.menu),
          childButtons: childButtons.toList(),
        ),
      ),
    );
  }

  Widget showInfoRow(label, value) {
    if (value == null) {
      value = "";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(flex: 8, child: Text(value)),
          ],
        ),
      ),
    );
  }

  Widget validatorRow(label, value, controller, validator) {
    if (value != null) {
      controller.text = value;
    }

    var valueFmt = value ?? "N/A";

    if (valueFmt == "") {
      valueFmt = "N/A";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextFormField(
                controller: controller,
                validator: validator,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfoRow(label, value, controller) {
    if (value != null) {
      controller.text = value;
    }

    var valueFmt = value ?? "N/A";

    if (valueFmt == "") {
      valueFmt = "N/A";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextField(
                onChanged: null,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
