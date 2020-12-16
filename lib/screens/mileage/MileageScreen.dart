import 'dart:developer';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/components/shared/MerchantDropdown.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class MileageScreen extends StatefulWidget {
  final StorageService storageService = new StorageService();

  @override
  _MileageScreenState createState() => _MileageScreenState();
}

class _MileageScreenState extends State<MileageScreen> {
  var isLoading = true;
  var isRunning = false;
  final destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getInitialTripStatus();
  }

  Future<void> selectDestination(isMerchant) async {
    var destinationMerchant;
    if (isMerchant) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Merchant Destination'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                    child: Text('Select a Merchant.'),
                  ),
                  MerchantDropDown(callback: (newValue) {
                    setState(() {
                      destinationMerchant = newValue["id"];
                    });
                  }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 50, 15, 30),
                    child: MaterialButton(
                      padding: EdgeInsets.all(5),
                      color: UniversalStyles.actionColor,
                      onPressed: () {
                        var destination = {
                          "destination": destinationMerchant,
                          "merchant": isMerchant
                        };
                        if (destination["destination"] != null &&
                            destination["destination"] != "") {
                          toggleTripStatus(destination);
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.directions_car,
                              color: Colors.white,
                            ),
                            Text(
                              'Start Trip',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Not a Merchant?',
                    style: TextStyle(fontSize: 17, color: Colors.green)),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    selectDestination(false);
                    // destination["merchant"] = !destination["merchant"];
                    // print(destination);
                  });
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
            title: Text('Custom Destination'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                    child: Text('Enter a Destination.'),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Destination: ',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: TextFormField(
                          controller: destinationController,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 50, 15, 30),
                    child: MaterialButton(
                      padding: EdgeInsets.all(5),
                      color: UniversalStyles.actionColor,
                      onPressed: () {
                        if (destinationController.text != null &&
                            destinationController.text != "") {
                          var destination = {
                            "destination": destinationController.text,
                            "merchant": isMerchant
                          };
                          toggleTripStatus(destination);
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please enter a destination",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[600],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.directions_car,
                              color: Colors.white,
                            ),
                            Text(
                              'Start Trip',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Merchant?',
                    style: TextStyle(fontSize: 17, color: Colors.green)),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    selectDestination(true);
                  });
                },
              ),
            ],
          );
        },
      );
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

    setState(() {
      isLoading = false;
    });
  }

  Future<void> toggleTripStatus(destination) async {
    destinationController.clear();
    try {
      setState(() {
        isLoading = true;
      });
      bool status = !isRunning;
      String currentTime =
          DateFormat('yyyy-MM-dd HH:mm:ss.mmm').format(DateTime.now().toUtc());
      var sendMerchant;
      Map sendDocument = {};
      if (destination["merchant"] != null) {
        if (destination["merchant"]) {
          sendMerchant = destination["destination"];
        } else {
          sendMerchant = null;
        }

        if (destination["merchant"]) {
          sendDocument = {};
        } else {
          sendDocument["destination"] = destination["destination"];
        }
      }
      if (status) {
        //START TRIP LOGIC
        MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
          mutation INSERT_TRIP (\$started_at: timestamptz, \$merchant: uuid, \$employee: uuid, \$document: jsonb){
            insert_trip_one(object: {started_at: \$started_at, merchant: \$merchant, employee: \$employee, document: \$document}) {
              trip
            }
          }
        """), variables: {
          "started_at": currentTime,
          "merchant": sendMerchant,
          "document": sendDocument,
          "employee": UserService.employee.employee
        });

        final QueryResult result = await authGqlMutate(mutateOptions);
        if (result.hasException == true) {
          Fluttertoast.showToast(
              msg: result.exception.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        } else {
          await this.widget.storageService.save(
              "techTripId", result.data["insert_trip_one"]["trip"].toString());
          setState(() {
            isRunning = status;
          });
        }
      } else {
        //END TRIP LOGIC
        var trip = await this.widget.storageService.read("techTripId");
        if (trip != "" && trip != "null") {
          MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
           mutation UPDATE_TRIP_COMPLETE (\$completed_at: timestamptz, \$trip: uuid!) {
            update_trip_by_pk(pk_columns: {trip: \$trip}, _set: {is_completed: true, completed_at: \$completed_at}) {
              trip
            }
          }
           """), variables: {"completed_at": currentTime, "trip": trip});

          final QueryResult result = await authGqlMutate(mutateOptions);
          if (result.hasException == true) {
            Fluttertoast.showToast(
                msg: result.exception.toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          } else {
            setState(() {
              isRunning = status;
            });
          }
        } else {
          Fluttertoast.showToast(
              msg: "Failed to get status from StorageService!",
              toastLength: Toast.LENGTH_LONG,
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/dashboard");
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.orange,
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          key: Key("mileageCustomAppBar"),
          title: Text("Mileage"),
        ),
        body: isLoading
            ? LoadingScreen()
            : Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    isRunning
                        ? Expanded(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        "https://media.giphy.com/media/l378BzHA5FwWFXVSg/giphy.gif"),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        "https://media.giphy.com/media/brHaCdJqCXijm/source.gif"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Expanded(
                      child: isRunning
                          ? MaterialButton(
                              height: MediaQuery.of(context).size.height / 2,
                              color: Colors.red[300],
                              onPressed: () {
                                toggleTripStatus({});
                              },
                              child: Text(
                                'STOP',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 10,
                                ),
                              ),
                            )
                          : MaterialButton(
                              height: MediaQuery.of(context).size.height / 2,
                              color: Colors.green[200],
                              onPressed: () {
                                selectDestination(true);
                              },
                              child: Text(
                                'START',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 10,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
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
              child: TextFormField(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
