import 'dart:async';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class MerchantInfoEntry {
  final TextEditingController controller;
  final Key key;
  MerchantInfoEntry(this.controller, this.key);
}

class ViewMerchantScreen extends StatefulWidget {
  final String merchantId;
  ViewMerchantScreen(this.merchantId);

  @override
  ViewMerchantScreenState createState() => ViewMerchantScreenState();
}

class ViewMerchantScreenState extends State<ViewMerchantScreen> {
  final _merchantFormKey = GlobalKey<FormState>();

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailAddrController = TextEditingController();
  var phoneNumberController = MaskedTextController(mask: '000-000-0000');
  var businessNameController = TextEditingController();
  var dbaController = TextEditingController();
  var businessAddressController = TextEditingController();
  var notesController = TextEditingController();
  var merchantSourceController = TextEditingController();

  var merchantInfoEntries = List<MerchantInfoEntry>();

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  String addressText;
  bool isChanged = false;
  var merchant;
  var merchantDocument;
  var isLoading = true;
  var devicesLoading = false;
  var displayPhone;
  var devices = [];

  void initState() {
    super.initState();
    loadMerchantData(this.widget.merchantId);
  }

  Future<void> loadMerchantData(merchantId) async {
    QueryOptions options =
        QueryOptions(fetchPolicy: FetchPolicy.networkOnly, documentNode: gql("""
      query Merchant(\$merchant: uuid!){
        merchant_by_pk(merchant: \$merchant){
          merchant
          document
          employee: employeeByEmployee{
            employee
            displayName:document(path:"displayName")
          }
		    }
      }
    """), variables: {"merchant": merchantId});

    final QueryResult result = await client.query(options);

    if (result.hasException == false) {
      var body = result.data["merchant_by_pk"];
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          merchant = bodyDecoded;
          merchantDocument = bodyDecoded["document"];
          firstNameController.text = merchantDocument["firstName"];
        });
      }
    }

    // setState(() {
    //   isLoading = false;
    // });

    Operation deviceOptions =
        Operation(operationName: "MerchantDevices", documentNode: gql("""
          subscription MerchantDevices(\$merchant: uuid!) {
            inventory(where: {merchant: {_eq: \$merchant}}){
              serial
              inventory
              is_installed
              employee
              merchant
              document
              priceTier:inventoryPriceTierByInventoryPriceTier{
                model
              }
            }
          }
            """), variables: {"merchant": "${this.widget.merchantId}"});

    var result2 = wsClient.subscribe(deviceOptions);
    result2.listen(
      (data) async {
        var devicesArrDecoded = data.data["inventory"];
        if (devicesArrDecoded != null) {
          setState(() {
            devices = devicesArrDecoded;
          });
        }
        isLoading = false;
      },
      onError: (error) {
        print("STREAM LISTEN ERROR: " + error);
        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(
            msg: "Failed to load devices for employee!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  Future<void> updateMerchant(merchantId) async {
    String rawNumber = phoneNumberController.text;
    var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");
    var merchantToUpdate = {
      "dbaName": dbaController.text,
      "businessType": "",
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "emailAddr": emailAddrController.text,
      "phoneNumber": filteredNumber,
      "address": businessAddress["address"],
      "city": businessAddress["city"],
      "state": businessAddress["state"],
      "zipCode": businessAddress["zipcode"],
    };
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
                      title: Text(device["priceTier"]["model"]),
                      subtitle: Text(device["serial"]),
                      trailing: Icon(deviceIcon))));
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
          title: Text(isLoading
              ? "Loading..."
              : merchantDocument["ApplicationInformation"]["MpaInfo"]
                  ["ClientDbaName"]),
        ),
        body: isLoading
            ? CenteredClearLoadingScreen()
            : Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _merchantFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomCard(
                          key: Key("merchants1"),
                          icon: Icons.person,
                          title: "Business Info",
                          child: Column(
                            children: <Widget>[
                              showInfoRow(
                                  "Address",
                                  merchantDocument["ApplicationInformation"]
                                      ["CorporateInfo"]["Address1"]),
                              showInfoRow("City, State ZIP",
                                  "${merchantDocument["ApplicationInformation"]["CorporateInfo"]["City"]}, ${merchantDocument["ApplicationInformation"]["CorporateInfo"]["State"]}, ${merchantDocument["ApplicationInformation"]["CorporateInfo"]["First5Zip"]}"),
                              showInfoRow(
                                  "Email",
                                  merchantDocument["ApplicationInformation"]
                                          ["MpaOutletInfo"]["Outlet"]
                                      ["BusinessInfo"]["BusinessEmailAddress"]),
                              showInfoRow(
                                  "Phone",
                                  merchantDocument["ApplicationInformation"]
                                          ["MpaOutletInfo"]["Outlet"]
                                      ["BusinessInfo"]["LocationPhone"]),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      color: UniversalStyles.actionColor,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.mail, color: Colors.white),
                                          Text("Email",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                      onPressed: () {
                                        if (merchantDocument["ApplicationInformation"]
                                                                ["MpaOutletInfo"]
                                                            ["Outlet"]
                                                        ["BusinessInfo"]
                                                    ["BusinessEmailAddress"] !=
                                                null &&
                                            merchantDocument["ApplicationInformation"]
                                                                [
                                                                "MpaOutletInfo"]
                                                            [
                                                            "Outlet"]
                                                        ["BusinessInfo"]
                                                    ["BusinessEmailAddress"] !=
                                                "") {
                                          var launchURL1 =
                                              'mailto:${merchantDocument["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]["BusinessInfo"]["BusinessEmailAddress"]}?subject=Followup about ${merchantDocument["ApplicationInformation"]["MpaInfo"]["ClientDbaName"]}';
                                          launch(launchURL1);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "No email specified!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.grey[600],
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      color: UniversalStyles.actionColor,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.call, color: Colors.white),
                                          Text("Call",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                      onPressed: () {
                                        if (merchantDocument["ApplicationInformation"]
                                                                ["MpaOutletInfo"]
                                                            ["Outlet"]
                                                        ["BusinessInfo"]
                                                    ["LocationPhone"] !=
                                                null &&
                                            merchantDocument["ApplicationInformation"]
                                                                [
                                                                "MpaOutletInfo"]
                                                            [
                                                            "Outlet"]
                                                        ["BusinessInfo"]
                                                    ["LocationPhone"] !=
                                                "") {
                                          var launchURL2 =
                                              'tel:${merchantDocument["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]["BusinessInfo"]["LocationPhone"]}';
                                          launch(launchURL2);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "No phone number specified!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.grey[600],
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("merchants3"),
                          icon: Icons.devices,
                          title: "Devices",
                          child: Column(
                            children: <Widget>[
                              devicesLoading
                                  ? CenteredLoadingSpinner()
                                  : devices.length > 0
                                      ? buildList()
                                      : Empty("No Devices Found")
                            ],
                          ),
                        ),
                        // CustomCard(
                        //     key: Key("merchants4"),
                        //     title: "Tools",
                        //     icon: Icons.build,
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: RaisedButton(
                        //         color: UniversalStyles.actionColor,
                        //         child: Row(
                        //           children: <Widget>[
                        //             Icon(Icons.extension, color: Colors.white),
                        //             Text("Agreement Builder",
                        //                 style: TextStyle(
                        //                     color: Colors.white,
                        //                     fontWeight: FontWeight.bold))
                        //           ],
                        //         ),
                        //         onPressed: () {
                        //           Navigator.pushNamed(
                        //               context, "/agreementbuilder",
                        //               arguments: merchant["lead"]);
                        //         },
                        //       ),
                        //     )),
                        // // CustomCard(
                        // //     key: Key("merchants4"),
                        // //     title: "Notes",
                        // //     icon: Icons.note,
                        // //     child: Notes(
                        // //         type: "merchant",
                        // //         object: merchant["merchant"])),
                      ],
                    ),
                  ),
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
              child: TextField(
                controller: controller,
              ),
            ),
          ],
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
      setState(() {
        controller.text = value;
      });
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
