import 'dart:async';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:atlascrm/components/shared/MerchantDropdown.dart';

class ViewInventoryScreen extends StatefulWidget {
  final Map incoming;

  ViewInventoryScreen(this.incoming);

  @override
  ViewInventoryScreenState createState() => ViewInventoryScreenState();
}

class ViewInventoryScreenState extends State<ViewInventoryScreen> {
  final _leadFormKey = GlobalKey<FormState>();

  var serialNumberController = TextEditingController();
  var priceTierController = TextEditingController();
  var merchantController = TextEditingController();
  var merchantNameController = TextEditingController();

  var deviceIcon;

  String addressText;
  bool isChanged = false;
  var inventory;
  var inventoryDocument;
  var isLoading = true;
  var displayPhone;
  var deviceStatus;
  void initState() {
    super.initState();
    loadInventoryData();
  }

  var employee;

  var childButtons = List<UnicornButton>();
  Future<void> initStatus() async {
    if (inventory["is_installed"] == true) {
      deviceStatus = "Installed";
      deviceIcon = Icons.done;
      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Return",
          currentButton: FloatingActionButton(
              heroTag: "return",
              backgroundColor: Colors.redAccent,
              mini: true,
              child: Icon(Icons.replay),
              onPressed: () {
                updateDevice("return");
              })));
    }
    if (inventory["merchantByMerchant"] != null &&
        inventory["is_installed"] != true) {
      deviceStatus = "Awaiting Install";
      deviceIcon = Icons.directions_car;
      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Install",
          currentButton: FloatingActionButton(
              heroTag: "install",
              backgroundColor: Colors.greenAccent,
              mini: true,
              child: Icon(Icons.build),
              onPressed: () {
                updateDevice("install");
              })));

      childButtons.add(UnicornButton(
          hasLabel: true,
          labelText: "Return",
          currentButton: FloatingActionButton(
              heroTag: "return2",
              backgroundColor: Colors.redAccent,
              mini: true,
              child: Icon(Icons.replay),
              onPressed: () {
                updateDevice("return");
              })));
    }
    if (inventory["merchantByMerchant"] == null &&
        inventory["employeeByEmployee"] == null) {
      deviceStatus = "In Warehouse";
      deviceIcon = Icons.business;
      childButtons.add(UnicornButton(
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
          )));
    }
  }

  Future<void> loadInventoryData() async {
    QueryOptions options = QueryOptions(documentNode: gql("""
        query {inventory_by_pk(inventory: "${this.widget.incoming["id"]}"){
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
          serial
          inventoryLocationByInventoryLocation{
            name
          }
          inventoryPriceTierByInventoryPriceTier{
            model
          }
          document
        }}
            """), fetchPolicy: FetchPolicy.networkOnly);

    final QueryResult result = await client.query(options);

    if (result.hasException == false) {
      var body = result.data["inventory_by_pk"];
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          inventory = bodyDecoded;
          if (inventory["merchantByMerchant"] != null) {
            merchantController.text =
                inventory["merchantByMerchant"]["merchant"];
            merchantNameController.text = inventory["merchantByMerchant"]
                    ["document"]["ApplicationInformation"]["MpaInfo"]
                ["ClientDbaName"];
          } else {
            merchantController.text = null;
            merchantNameController.text = null;
          }

          if (inventory["employeeByEmployee"] != null) {
            if (inventory["employeeByEmployee"]["document"]["displayName"] !=
                null) {
              setState(() {
                employee =
                    inventory["employeeByEmployee"]["document"]["displayName"];
              });
            }
          }

          isLoading = false;
        });
      }
    }
    initStatus();
  }

  Future<void> updateDevice(type) async {
    Map data;
    var alert;
    var locationName;
    if (type == "checkout") {
      data = {
        "employee": UserService.employee.employee,
        "merchant": merchantController.text
      };
      alert = "Device checked out!";
      locationName = merchantNameController.text;
    }
    if (type == "return") {
      data = {"merchant": null, "employee": null, "is_installed": false};
      alert = "Device returned!";
      locationName = UserService.employee.companyName;
    }
    if (type == "install") {
      data = {"is_installed": true};
      alert = "Device installed!";
      locationName = merchantNameController.text;
    }
    var newDocument = inventory["document"];

    if (newDocument["history"] == null) {
      newDocument["history"] = [];
    }

    var currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    print(currentTimestamp);
    var newEvent = {
      "date": currentTimestamp,
      "employee": UserService.employee.employee,
      "location": merchantController.text,
      "merchant": type == "return" ? false : true,
      "description": type,
      "employeeName": UserService.employee.document["displayName"],
      "locationName": locationName
    };
    newDocument["history"].add(newEvent);

    data["document"] = newDocument;

    MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
      mutation UPDATE_INVENTORY (\$data: inventory_set_input){
        update_inventory_by_pk(pk_columns: {inventory: "${this.widget.incoming["id"]}"}, _set:\$data){
          inventory
          document
        }
      }
      """), variables: {"data": data});
    final QueryResult result = await client.mutate(mutateOptions);

    if (result.hasException == false) {
      await loadInventoryData();

      Fluttertoast.showToast(
          msg: alert,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
      if (this.widget.incoming["origin"] == null) {
        Navigator.pushNamed(context, '/inventory');
      } else {
        Navigator.pop(context);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Failed to udpate device!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
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
                MerchantDropDown(callback: (newValue) {
                  setState(() {
                    merchantController.text = newValue["id"];
                    merchantNameController.text = newValue["name"];
                  });
                })
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Checkout',
                  style: TextStyle(fontSize: 17, color: Colors.green)),
              onPressed: () {
                if (merchantController.text != null &&
                    merchantController.text != "") {
                  updateDevice("checkout");
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                      msg: "Please select a merchant",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCheck(leadId) async {
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
            FlatButton(
              child: Text('Cancel', style: TextStyle(fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Delete',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                deleteDevice(leadId);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteDevice(leadId) async {
    var resp;
    //REPLACE WITH GRAPHQL
    // var resp = await this
    //     .widget
    //     .apiService
    //     .authDelete(context, "/inventory/" + this.widget.incoming["id"], null);

    if (resp.statusCode == 200) {
      Navigator.popAndPushNamed(context, "/inventory");

      Fluttertoast.showToast(
          msg: "Successful delete!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to delete lead!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Widget buildHistoryList() {
    var historyList = [];
    if (inventory["document"] != null) {
      if (inventory["document"]["history"] != null) {
        var reversed = List.from(inventory["document"]["history"].reversed);
        historyList = reversed;
      }
    }
    return ListView(
        shrinkWrap: true,
        children: List.generate(historyList.length, (index) {
          var event = historyList[index];
          DateTime date =
              new DateTime.fromMillisecondsSinceEpoch(event["date"]);
          var dateFormat = DateFormat.yMd().add_jm();
          var eventDate = dateFormat.format(date);
          return Card(
              shape: new RoundedRectangleBorder(
                  side: new BorderSide(color: Colors.grey[200], width: 2.0),
                  borderRadius: BorderRadius.circular(4.0)),
              child: ListTile(
                  isThreeLine: true,
                  title: Text(event["locationName"] != null
                      ? event["locationName"]
                      : ""),
                  subtitle: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Text(event["employeeName"] != null
                            ? event["employeeName"]
                            : ""),
                      )),
                  trailing: Column(
                    children: <Widget>[
                      Text(eventDate),
                      Text(event["description"] != null
                          ? event["description"]
                          : ""),
                    ],
                  )));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: UniversalStyles.backgroundColor,
        appBar: CustomAppBar(
          key: Key("viewTasksAppBar"),
          title: Text(isLoading ? "Loading..." : inventory["serial"]),
          action: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
            //   child: IconButton(
            //     onPressed: () {
            //       deleteCheck(this.widget.deviceId);
            //     },
            //     icon: Icon(Icons.delete, color: Colors.white),
            //   ),
            // )
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
                                    child: Text("Status:",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 0, 8),
                                    child: Text(deviceStatus,
                                        style: TextStyle(fontSize: 15)),
                                  )),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(70, 0, 0, 0),
                                    child: Icon(deviceIcon),
                                  )),
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
                              child: Scrollbar(child: buildHistoryList())),
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
            childButtons: childButtons),
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
}
