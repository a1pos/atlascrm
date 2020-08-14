import 'dart:async';
import 'dart:developer';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/model/scan_options.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';

class ViewInstallScreen extends StatefulWidget {
  final ApiService apiService = ApiService();
  final StorageService storageService = StorageService();

  final Map incoming;

  ViewInstallScreen(this.incoming);

  @override
  ViewInstallScreenState createState() => ViewInstallScreenState();
}

class ViewInstallScreenState extends State<ViewInstallScreen> {
  final _leadFormKey = GlobalKey<FormState>();

  var serialNumberController = TextEditingController();
  var priceTierController = TextEditingController();
  var merchantController = TextEditingController();

  var deviceIcon;

  String addressText;
  bool isChanged = false;
  var install;
  var installDocument;
  var isLoading = true;
  var displayPhone;
  var deviceStatus;
  var merchant;
  var isRunning = false;
  var destination;
  void initState() {
    super.initState();
    loadMerchantData();
    loadInventory();
    getInitialTripStatus();
  }

  var devices = [];

  Future<void> loadMerchantData() async {
    if (this.widget.incoming["ticket"]["merchant"] != null) {
      var resp = await this.widget.apiService.authGet(
          context, "/merchant/${this.widget.incoming["ticket"]["merchant"]}");

      if (resp.statusCode == 200) {
        var body = resp.data;
        if (body != null) {
          var bodyDecoded = body;

          setState(() {
            merchant = bodyDecoded;
            destination = {
              "destination": merchant["merchant"],
              "merchant": true
            };
            isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        merchant = null;
        isLoading = false;
      });
    }
  }

  Future<void> loadInventory() async {
    var resp2 = await this.widget.apiService.authGet(context,
        "/inventory/merchant/" + this.widget.incoming["ticket"]["merchant"]);

    if (resp2.statusCode == 200) {
      var body = resp2.data;
      if (body != null) {
        var bodyDecoded = body;
        if (bodyDecoded[0]["inventory"] != null) {
          for (Map device in bodyDecoded) {
            if (device["is_installed"] != true) {
              setState(() {
                devices.add(device);
              });
            }
          }
        }
      }
    }
  }

  Future<void> getInitialTripStatus() async {
    try {
      var storedStatus =
          await this.widget.storageService.read("isTechTripRunning");
      setState(() {
        isRunning = storedStatus.toLowerCase() == 'true';
      });
    } catch (err) {
      setState(() {
        isRunning = false;
      });
    }

    setState(() {});
  }

  Future<void> toggleTripStatus() async {
    try {
      setState(() {
        isLoading = true;
      });
      var status = !isRunning;

      if (status) {
        var resp = await this.widget.apiService.authPost(context,
            "/employee/${UserService.employee.employee}/trip", destination);
        if (resp.statusCode == 200) {
          await this
              .widget
              .storageService
              .save("techTripId", resp.data.toString());
          setState(() {
            isRunning = status;
          });
        } else {
          Fluttertoast.showToast(
              msg: "Failed to set status!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }
      } else {
        var trip = await this.widget.storageService.read("techTripId");
        if (trip != "") {
          var resp = await this
              .widget
              .apiService
              .authPost(context, "/employee/trip/$trip", {});
          if (resp.statusCode == 200) {
            setState(() {
              isRunning = status;
            });
          } else {
            Fluttertoast.showToast(
                msg: "Failed to set status!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          }
        } else {
          Fluttertoast.showToast(
              msg: "Failed to set status!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }
      }

      await this
          .widget
          .storageService
          .save("isTechTripRunning", status.toString());

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      await this.widget.storageService.delete("isTechTripRunning");
      await this.widget.storageService.delete("techTripId");
      setState(() {
        isLoading = false;
        isRunning = false;
      });
      log(err);
    }
  }

  Future<void> installCheck() async {
    if (devices.length > 0) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Finish this Install?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Please ensure you have completed the install checklist.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel',
                    style: TextStyle(fontSize: 17, color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Complete',
                    style: TextStyle(fontSize: 17, color: Colors.green)),
                onPressed: () {
                  completeInstall();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Devices!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Make sure you check out devices for this install!'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close',
                    style: TextStyle(fontSize: 17, color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> completeInstall() async {
    var resp = await this
        .widget
        .apiService
        .authPost(context, "/merchant/install/" + merchant["merchant"], null);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        // var bodyDecoded = body;
      }
    }

    var resp2 = await this
        .widget
        .apiService
        .authPut(context, "/status/Closed", this.widget.incoming["ticket"]);

    if (resp2.statusCode == 200) {
      var body = resp2.data;
      if (body != null) {
        // var bodyDecoded = body;
      }
    }

    var resp3 = await this
        .widget
        .apiService
        .authPut(context, "/inventory/install", devices);

    if (resp3.statusCode == 200) {
      await loadInventory();

      Fluttertoast.showToast(
          msg: "Devices Installed",
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
          msg: "Failed to update device!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Fluttertoast.showToast(
        msg: "INSTALL COMPLETE",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget buildList() {
    return ListView(
        shrinkWrap: true,
        children: List.generate(devices.length, (index) {
          var device = devices[index];
          var deviceIcon;

          if (device["is_installed"] == true) {
            deviceIcon = Icons.done;
          }
          if (device["merchant"] != null && device["is_installed"] != true) {
            deviceIcon = Icons.directions_car;
          }
          if (device["merchant"] == null && device["employee"] == null) {
            deviceIcon = Icons.business;
          }
          var sendable = {"id": device["inventory"], "origin": "merchant"};
          return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/viewinventory",
                    arguments: sendable);
              },
              child: Card(
                  child: ListTile(
                      title: Text(device["model"]),
                      subtitle: Text(device["serial"]),
                      trailing: Icon(deviceIcon))));
        }));
  }

  Future<void> scanBarcode() async {
    try {
      var options = ScanOptions(strings: {
        "cancel": "done",
        "flash_on": "flash on",
        "flash_off": "flash off",
      });
      var result = await BarcodeScanner.scan(options: options);

      print(result.rawContent);
      checkoutDevice(result.rawContent);
      if (result.type != ResultType.Cancelled) {}
    } catch (err) {
      log(err);
    }
  }

  Future<void> checkoutDevice(serial) async {
    var deviceId;
    var data;
    var alert;
    data = {
      "employee": UserService.employee.employee,
      "merchant": merchant["merchant"]
    };
    alert = "Device checked out!";

    var resp2 = await this
        .widget
        .apiService
        .authGet(context, "/inventory/serial/" + serial);
    if (resp2.statusCode == 200) {
      var body = resp2.data;
      if (body != null) {
        var bodyDecoded = body;
        if (bodyDecoded["inventory"] != null) {
          if (bodyDecoded["merchant"] != null &&
              bodyDecoded["is_installed"] != true) {
            Fluttertoast.showToast(
                msg: "This device has already been checked out!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
          } else if (bodyDecoded["is_installed"] == true) {
            Fluttertoast.showToast(
                msg: "This device has already been installed!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            setState(() {
              deviceId = bodyDecoded["inventory"];
            });
            var resp = await this
                .widget
                .apiService
                .authPut(context, "/inventory/" + deviceId, data);

            if (resp.statusCode == 200) {
              await loadInventory();

              Fluttertoast.showToast(
                  msg: alert,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "Failed to update install!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          }
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: "This device hasn't been registered!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 242, 242, 242),
        appBar: CustomAppBar(
          key: Key("viewInstallAppBar"),
          title: Text(isLoading
              ? "Loading..."
              : this.widget.incoming["ticket"]["document"]["title"]),
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
                          key: Key("install1"),
                          icon: Icons.build,
                          title: "Install Info.",
                          child: Column(
                            children: <Widget>[
                              merchant != null
                                  ? showInfoRow(
                                      "Merchant",
                                      merchant["document"]
                                              ["ApplicationInformation"]
                                          ["MpaInfo"]["ClientDbaName"])
                                  : Container(),
                              merchant != null
                                  ? showInfoRow(
                                      "Location",
                                      merchant['document']['ApplicationInformation']
                                                      ['MpaOutletInfo']
                                                  ['Outlet']['BusinessInfo']
                                              ['LocationAddress1'] +
                                          ", " +
                                          merchant['document']['ApplicationInformation']
                                                  ['MpaOutletInfo']['Outlet']
                                              ['BusinessInfo']['City'] +
                                          ", " +
                                          merchant['document']['ApplicationInformation']
                                                  ['MpaOutletInfo']['Outlet']
                                              ['BusinessInfo']['State'] +
                                          ", " +
                                          merchant['document']['ApplicationInformation']
                                                  ['MpaOutletInfo']['Outlet']
                                              ['BusinessInfo']['First5Zip'])
                                  : Container(),
                              showInfoRow(
                                  "Description",
                                  this.widget.incoming["ticket"]["document"]
                                      ["description"]),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("install2"),
                          icon: Icons.devices,
                          title: "Checkout Devices",
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: getInfoRow(
                                        "S/N",
                                        serialNumberController.text,
                                        serialNumberController, (serial) {
                                      checkoutDevice(serial);
                                    }),
                                  ),
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor:
                                        Color.fromARGB(500, 1, 224, 143),
                                    child: IconButton(
                                      icon: Icon(Icons.center_focus_weak,
                                          color: Colors.white),
                                      onPressed: () {
                                        scanBarcode();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              buildList()
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("install3"),
                          icon: Icons.directions,
                          title: "Mileage",
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              isRunning
                                  ? GestureDetector(
                                      onTap: () {
                                        toggleTripStatus();
                                      },
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.red,
                                        child: Text("STOP TRIP",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        toggleTripStatus();
                                      },
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor:
                                            Color.fromARGB(500, 1, 224, 143),
                                        child: Text("START TRIP",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: installCheck,
          backgroundColor: Color.fromARGB(500, 1, 224, 143),
          foregroundColor: Colors.white,
          child: Icon(Icons.done),
          splashColor: Colors.white,
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

  Widget getInfoRow(label, value, controller, onSubmit) {
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
                onSubmitted: onSubmit,
                controller: controller,
              ),
            ),
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
