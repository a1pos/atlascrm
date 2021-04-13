import 'dart:async';
import 'dart:developer';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:dan_barcode_scan/dan_barcode_scan.dart';
import 'package:dan_barcode_scan/model/scan_options.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

class ViewInstallScreen extends StatefulWidget {
  final StorageService storageService = StorageService();
  final Map incoming;

  ViewInstallScreen(this.incoming);

  @override
  ViewInstallScreenState createState() => ViewInstallScreenState();
}

class ViewInstallScreenState extends State<ViewInstallScreen> {
  final _leadFormKey = GlobalKey<FormState>();
  String addressText;
  bool isChanged = false;
  bool isLoading = true;
  bool isRunning = false;

  var serialNumberController = TextEditingController();
  var priceTierController = TextEditingController();
  var merchantController = TextEditingController();

  var devices = [];
  var deviceIcon;
  var install;
  var installDocument;
  var displayPhone;
  var deviceStatus;
  var merchant;
  var destination;
  var merchantLocation = "";

  void initState() {
    super.initState();
    loadMerchantData();
    loadInventory();
    getInitialTripStatus();
  }

  Future<void> loadMerchantData() async {
    if (this.widget.incoming["ticket"]["merchant"] != null) {
      var resp;

      if (resp.statusCode == 200) {
        var body = resp.data;
        if (body != null) {
          var bodyDecoded = body;

          setState(
            () {
              merchant = bodyDecoded;
              destination = {
                "destination": merchant["merchant"],
                "merchant": true
              };
              isLoading = false;
            },
          );
        }
      }
    } else {
      setState(
        () {
          merchant = null;
          isLoading = false;
        },
      );
    }
    if (merchant != null) {
      if (merchant['document']['ApplicationInformation']['MpaOutletInfo']
                  ['Outlet']['BusinessInfo']['LocationAddress1'] !=
              null &&
          merchant['document']['ApplicationInformation']['MpaOutletInfo']
                  ['Outlet']['BusinessInfo']['LocationAddress1'] !=
              "") {
        merchantLocation = merchant['document']['ApplicationInformation']
                    ['MpaOutletInfo']['Outlet']['BusinessInfo']
                ['LocationAddress1'] +
            ", " +
            merchant['document']['ApplicationInformation']['MpaOutletInfo']
                ['Outlet']['BusinessInfo']['City'] +
            ", " +
            merchant['document']['ApplicationInformation']['MpaOutletInfo']
                ['Outlet']['BusinessInfo']['State'] +
            ", " +
            merchant['document']['ApplicationInformation']['MpaOutletInfo']
                ['Outlet']['BusinessInfo']['First5Zip'];
      } else {
        merchantLocation = merchant['document']['ApplicationInformation']
                ["CorporateInfo"]['Address1'] +
            ", " +
            merchant['document']['ApplicationInformation']["CorporateInfo"]
                ['City'] +
            ", " +
            merchant['document']['ApplicationInformation']["CorporateInfo"]
                ['State'] +
            ", " +
            merchant['document']['ApplicationInformation']["CorporateInfo"]
                ['First5Zip'];
      }
    }
  }

  Future<void> loadInventory() async {
    var resp2;

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

    setState(
      () {},
    );
  }

  Future<void> toggleTripStatus() async {
    try {
      setState(() {
        isLoading = true;
      });
      var status = !isRunning;

      if (status) {
        var resp;

        if (resp.statusCode == 200) {
          await this
              .widget
              .storageService
              .save("techTripId", resp.data.toString());
          setState(
            () {
              isRunning = status;
            },
          );
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
          var resp;

          if (resp.statusCode == 200) {
            setState(
              () {
                isRunning = status;
              },
            );
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

      await this.widget.storageService.save(
            "isTechTripRunning",
            status.toString(),
          );

      setState(
        () {
          isLoading = false;
        },
      );
    } catch (err) {
      await this.widget.storageService.delete("isTechTripRunning");
      await this.widget.storageService.delete("techTripId");

      setState(
        () {
          isLoading = false;
          isRunning = false;
        },
      );

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
              TextButton(
                child: Text('Cancel',
                    style: TextStyle(fontSize: 17, color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
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
              TextButton(
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
    var resp;
    var resp2;
    var resp3;

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {}
    }

    if (resp2.statusCode == 200) {
      var body = resp2.data;
      if (body != null) {}
    }

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
      children: List.generate(
        devices.length,
        (index) {
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
                trailing: Icon(deviceIcon),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> scanBarcode() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": "done",
          "flash_on": "flash on",
          "flash_off": "flash off",
        },
      );
      var result = await BarcodeScanner.scan(options: options);

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
    var resp2;

    data = {
      "employee": UserService.employee.employee,
      "merchant": merchant["merchant"]
    };

    alert = "Device checked out!";

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
            var resp;

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

  var installDate;

  @override
  Widget build(BuildContext context) {
    if (this.widget.incoming["ticket"]["due_date"] != null) {
      installDate = DateFormat.yMMMMd('en_US').format(
        DateTime.parse(this.widget.incoming["ticket"]["due_date"]),
      );
    }
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: UniversalStyles.backgroundColor,
        appBar: CustomAppBar(
          key: Key("viewInstallAppBar"),
          title: Text(
            isLoading
                ? "Loading..."
                : this.widget.incoming["ticket"]["document"]["title"],
          ),
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
                                  : Row(
                                      children: <Widget>[
                                        Icon(Icons.info_outline,
                                            color: Colors.red),
                                        Text(
                                            "Notice: No merchant record found for this ticket",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                              showInfoRow(
                                  "Description",
                                  this.widget.incoming["ticket"]["document"]
                                      ["description"]),
                              this.widget.incoming["ticket"]["due_date"] != null
                                  ? showInfoRow("Due Date", installDate)
                                  : Container(),
                              merchant != null
                                  ? MaterialButton(
                                      color: Colors.grey[200],
                                      child: showInfoRow(
                                          "Location", merchantLocation),
                                      onPressed: () {
                                        MapsLauncher.launchQuery(
                                            merchantLocation);
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        merchant != null
                            ? CustomCard(
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
                                              UniversalStyles.actionColor,
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
                              )
                            : Container(),
                        merchant != null
                            ? CustomCard(
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
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              toggleTripStatus();
                                            },
                                            child: CircleAvatar(
                                              radius: 60,
                                              backgroundColor: Color.fromARGB(
                                                  500, 1, 224, 143),
                                              child: Text("START TRIP",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: merchant != null || isRunning
            ? FloatingActionButton(
                onPressed: installCheck,
                backgroundColor: UniversalStyles.actionColor,
                foregroundColor: Colors.white,
                child: Icon(Icons.done),
                splashColor: Colors.white,
              )
            : Container(),
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
            Expanded(
              flex: 8,
              child: Text(value),
            ),
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
