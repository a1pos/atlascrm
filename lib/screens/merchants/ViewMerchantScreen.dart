import 'dart:async';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/CustomCard.dart';
import 'package:round2crm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
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

  bool isChanged = false;
  bool inventoryLoading = true;
  bool isLoading = true;

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  String addressText;

  List merchantInfoEntries = [];

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailAddrController = TextEditingController();
  var phoneNumberController = MaskedTextController(mask: '000-000-0000');
  var businessNameController = TextEditingController();
  var dbaController = TextEditingController();
  var businessAddressController = TextEditingController();
  var notesController = TextEditingController();
  var merchantSourceController = TextEditingController();

  var merchant;
  var merchantDocument;
  var displayPhone;
  var devices = [];
  var merchantLocation = "";
  var subscription;

  @override
  void initState() {
    super.initState();
    loadMerchantData(this.widget.merchantId);
  }

  @override
  void dispose() async {
    super.dispose();
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
  }

  Future<void> loadMerchantData(merchantId) async {
    try {
      QueryOptions options = QueryOptions(
        document: gql("""
      query GET_MERCHANT(\$merchant: uuid!){
        merchant_by_pk(merchant: \$merchant){
          merchant
          merchant_configs {
            document
          }
          document
          employee: employeeByEmployee{
            employee
            displayName:document(path:"displayName")
          }
          leadByLead {
            agreement_builders {
              document
            }
          }
		    }
      }
    """),
        variables: {"merchant": merchantId},
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result.hasException == false) {
        var body = result.data["merchant_by_pk"];

        if (body != null) {
          logger.i("Merchant data loaded");
          var bodyDecoded = body;

          setState(() {
            merchant = bodyDecoded;
            merchantDocument = bodyDecoded["document"];
            firstNameController.text = merchantDocument["firstName"];
          });

          if (merchantDocument["leadDocument"]["address"] != null &&
              merchantDocument["leadDocument"]["address"] != "" &&
              merchantDocument["leadDocument"]["city"] != null &&
              merchantDocument["leadDocument"]["city"] != "" &&
              merchantDocument["leadDocument"]["state"] != null &&
              merchantDocument["leadDocument"]["state"] != "" &&
              merchantDocument["leadDocument"]["zipCode"] != null &&
              merchantDocument["leadDocument"]["zipCode"] != "") {
            merchantLocation = merchantDocument["leadDocument"]["address"] +
                ", " +
                merchantDocument["leadDocument"]["city"] +
                ", " +
                merchantDocument["leadDocument"]["state"] +
                " " +
                merchantDocument["leadDocument"]["zipCode"];
          } else {
            //come back to this with a loop or query for to only get address of active agreement builder
            if (merchant['leadByLead']['agreement_builders'][0]['document']
                            ['ApplicationInformation']['CorporateInfo']
                        ['Address1'] !=
                    null &&
                merchant['leadByLead']['agreement_builders'][0]['document']
                            ['ApplicationInformation']['CorporateInfo']
                        ['Address1'] !=
                    "") {
              merchantLocation = merchant['leadByLead']['agreement_builders'][0]
                          ['document']['ApplicationInformation']
                      ['CorporateInfo']['Address1'] +
                  ", " +
                  merchant['leadByLead']['agreement_builders'][0]['document']
                      ['ApplicationInformation']['CorporateInfo']['City'] +
                  ", " +
                  merchant['leadByLead']['agreement_builders'][0]['document']
                      ['ApplicationInformation']['CorporateInfo']['State'] +
                  " " +
                  merchant['leadByLead']['agreement_builders'][0]['document']
                      ['ApplicationInformation']['CorporateInfo']['First5Zip'];
            } else if (merchant['document']['ApplicationInformation']
                            ['MpaOutletInfo']['Outlet']['BusinessInfo']
                        ['LocationAddress1'] !=
                    null &&
                merchant['document']['ApplicationInformation']['MpaOutletInfo']
                        ['Outlet']['BusinessInfo']['LocationAddress1'] !=
                    "") {
              merchantLocation = merchant['document']['ApplicationInformation']
                          ['MpaOutletInfo']['Outlet']['BusinessInfo']
                      ['LocationAddress1'] +
                  ", " +
                  merchant['document']['ApplicationInformation']
                      ['MpaOutletInfo']['Outlet']['BusinessInfo']['City'] +
                  ", " +
                  merchant['document']['ApplicationInformation']
                      ['MpaOutletInfo']['Outlet']['BusinessInfo']['State'] +
                  " " +
                  merchant['document']['ApplicationInformation']
                      ['MpaOutletInfo']['Outlet']['BusinessInfo']['First5Zip'];
            } else if (merchant['document']['ApplicationInformation']
                    ["CorporateInfo"]['Address1'] !=
                null) {
              merchantLocation = merchant['document']['ApplicationInformation']
                      ["CorporateInfo"]['Address1'] +
                  ", " +
                  merchant['document']['ApplicationInformation']
                      ["CorporateInfo"]['City'] +
                  ", " +
                  merchant['document']['ApplicationInformation']
                      ["CorporateInfo"]['State'] +
                  " " +
                  merchant['document']['ApplicationInformation']
                      ["CorporateInfo"]['First5Zip'];
            }
          }
        }
      } else {
        print("Error getting merchant data: " + result.exception.toString());
        logger.e("Error getting merchant data: " + result.exception.toString());
        Fluttertoast.showToast(
          msg: "Error getting merchant data: " + result.exception.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      setState(() {
        isLoading = false;
      });

      SubscriptionOptions deviceOptions = SubscriptionOptions(
          operationName: "GET_MERCHANT_DEVICES",
          document: gql("""
          subscription GET_MERCHANT_DEVICES(\$merchant: uuid!) {
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
            """),
          fetchPolicy: FetchPolicy.noCache,
          variables: {"merchant": "${this.widget.merchantId}"});

      subscription =
          await GqlClientFactory().authGqlsubscribe(deviceOptions, (data) {
        var devicesArrDecoded = data.data["inventory"];
        if (devicesArrDecoded != null && this.mounted) {
          logger.i("Merchant devices loaded");
          setState(() {
            devices = devicesArrDecoded;
          });
        }
        isLoading = false;
        inventoryLoading = false;
      }, (error) {
        print("Error getting merchant devices: " + error.toString());
        logger.e("Error getting merchant devices: " + error.toString());
      }, () => refreshSub());
    } catch (err) {
      print("Error getting merchant data and merchant device data: " +
          err.toString());
      logger.e("Error getting merchant data and merchant device data: " +
          err.toString());
    }
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      loadMerchantData(this.widget.merchantId);
      logger.i("Merchant data refreshed");
    }
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
              logger.i("Inventory opened: " + sendable["id"]);
              Navigator.pushNamed(context, "/viewinventory",
                  arguments: sendable);
            },
            child: Card(
              child: ListTile(
                title: Text(device["priceTier"]["model"]),
                subtitle: Text(device["serial"]),
                trailing: Icon(deviceIcon),
              ),
            ),
          );
        },
      ),
    );
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
          title: Text(
            isLoading
                ? "Loading..."
                : merchantDocument["leadDocument"]["businessName"],
          ),
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
                                merchantLocation,
                              ),
                              showInfoRow(
                                  "Email",
                                  merchantDocument["leadDocument"]
                                      ["emailAddr"]),
                              showInfoRow(
                                  "Phone",
                                  merchantDocument["leadDocument"]
                                      ["phoneNumber"]),
                              Divider(),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 20.0,
                                runSpacing: 1.0,
                                children: <Widget>[
                                  SizedBox(
                                    width: 95,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: UniversalStyles.actionColor,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.mail, color: Colors.white),
                                          Text(
                                            "Email",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        if (merchantDocument["leadDocument"]
                                                    ["emailAddr"] !=
                                                null &&
                                            merchantDocument["leadDocument"]
                                                    ["emailAddr"] !=
                                                "") {
                                          var launchURL1 =
                                              'mailto:${merchantDocument["leadDocument"]["emailAddr"]}?subject=Followup about ${merchantDocument["leadDocument"]["businessName"]}';
                                          logger.i("Email client opened for: " +
                                              merchantDocument["leadDocument"]
                                                  ["emailAddr"]);
                                          launch(launchURL1);
                                        } else {
                                          logger.e(
                                              "No email specified for email button");
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
                                  SizedBox(
                                    width: 95,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: UniversalStyles.actionColor,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.call, color: Colors.white),
                                          Text(
                                            "Call",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        if (merchantDocument["leadDocument"]
                                                    ["phoneNumber"] !=
                                                null &&
                                            merchantDocument["leadDocument"]
                                                    ["phoneNumber"] !=
                                                "") {
                                          var launchURL2 =
                                              'tel:${merchantDocument["leadDocument"]["phoneNumber"]}';
                                          logger.i(
                                              "Phone client opening to call: " +
                                                  merchantDocument[
                                                          "leadDocument"]
                                                      ["phoneNumber"]);
                                          launch(launchURL2);
                                        } else {
                                          logger.e(
                                              "No phone number specified for phone button");
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
                                  ),
                                  SizedBox(
                                    width: 95,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: UniversalStyles.actionColor,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.map, color: Colors.white),
                                          Text(
                                            "Map",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        if (merchantLocation != null) {
                                          logger.i("Opening map client for: " +
                                              merchantLocation);
                                          MapsLauncher.launchQuery(
                                              merchantLocation);
                                        } else {
                                          logger.e(
                                              "No address specified for map button");
                                          Fluttertoast.showToast(
                                              msg: "No address specified!",
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
                          key: Key("merchantsSettings"),
                          icon: Icons.settings,
                          title: "Settings",
                          child: merchant["merchant_configs"].length != 0
                              ? Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Gift Card:",
                                              style: TextStyle(fontSize: 16)),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 0, 0, 0),
                                            child: merchant["merchant_configs"]
                                                                [0]["document"]
                                                            ["giftcards"]
                                                        .toString() ==
                                                    "true"
                                                ? Icon(
                                                    Icons.done,
                                                    size: 26,
                                                    color: Colors.green[600],
                                                  )
                                                : Icon(Icons.clear,
                                                    color: Colors.red[600],
                                                    size: 26),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Cash Discounting:",
                                              style: TextStyle(fontSize: 16)),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 0, 0, 0),
                                            child: merchant["merchant_configs"]
                                                                [0]["document"]
                                                            ["cashDiscounting"]
                                                        .toString() ==
                                                    "true"
                                                ? Icon(
                                                    Icons.done,
                                                    size: 26,
                                                    color: Colors.green[600],
                                                  )
                                                : Icon(Icons.clear,
                                                    color: Colors.red[600],
                                                    size: 26),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Cash Discounting Percent:",
                                              style: TextStyle(fontSize: 16)),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 0, 0, 0),
                                            child: merchant["merchant_configs"]
                                                                [0]["document"][
                                                            "cashDiscountingPercent"]
                                                        .toString() !=
                                                    "null"
                                                ? Text(
                                                    merchant["merchant_configs"]
                                                                        [0]
                                                                    ["document"][
                                                                "cashDiscountingPercent"]
                                                            .toString() +
                                                        "%",
                                                    style:
                                                        TextStyle(fontSize: 16))
                                                : Text("",
                                                    style: TextStyle(fontSize: 16)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Empty("No Device Settings Found"),
                        ),
                        CustomCard(
                          key: Key("merchants3"),
                          icon: Icons.devices,
                          title: "Devices",
                          child: Column(
                            children: <Widget>[
                              inventoryLoading
                                  ? CenteredLoadingSpinner()
                                  : devices.length > 0
                                      ? buildList()
                                      : Empty("No Devices Found")
                            ],
                          ),
                        ),
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

  Widget showInfoRow(label, value, {color}) {
    if (value == null) {
      value = "";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: color != null
                    ? TextStyle(fontSize: 16, color: color)
                    : TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 8,
              child: Text(
                value,
                style: color != null
                    ? TextStyle(fontSize: 14, color: color)
                    : TextStyle(fontSize: 14),
              ),
            ),
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
