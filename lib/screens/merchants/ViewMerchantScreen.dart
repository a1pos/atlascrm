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

  var merchant;
  var merchantDocument;
  var merchantAgreement;
  var devices = [];
  var merchantLocation = "";
  var merchantPhoneNumber;
  var merchantContact;
  var merchantEmail;
  var merchantID;
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
        query GET_MERCHANT_BY_PK(\$merchant: uuid!) {
          merchant_by_pk(merchant: \$merchant) {
            merchant
            merchant_id
            merchant_status
            lead
            document
            merchantPricingTypeByMerchantPricingType {
              text
            }
            merchant_configs {
              document
            }
            leadByLead {
              rate_reviews(order_by: { created_at: desc }) {
                rate_review
              }
              agreement_builders(order_by: { created_at: desc }) {
                agreement_builder
                document
                created_at
              }
            }
            employeeByEmployee {
              employee
              document
            }
            inventories(where: { is_installed: { _eq: true } }) {
              inventoryPriceTierByInventoryPriceTier {
                model
              }
              serial
              inventory
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
          var bodyDecoded = body;

          setState(() {
            Future.delayed(Duration(seconds: 1), () {
              logger.i("Merchant data loaded");
            });

            merchant = bodyDecoded;
            merchantDocument = bodyDecoded["document"];
            merchantAgreement = merchant["leadByLead"]["agreement_builders"][0]
                ["document"]["ApplicationInformation"];

            if (merchantDocument["leadDocument"]["phoneNumber"] != null &&
                merchantDocument["leadDocument"]["phoneNumber"] != "" &&
                merchantDocument["leadDocument"]["phoneNumber"] !=
                    "0000000000") {
              merchantPhoneNumber = merchantDocument["leadDocument"]
                      ["phoneNumber"]
                  .replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'),
                      (Match m) => "(${m[1]}) ${m[2]}-${m[3]}");
            } else {
              merchantPhoneNumber = "";
            }

            merchantContact =
                merchantAgreement["CorporateInfo"]["CorporateContact"];
            merchantEmail = merchantAgreement["MpaOutletInfo"]["Outlet"]
                ["BusinessInfo"]["BusinessEmailAddress"];
            merchantID = merchant["merchant_id"];
          });

          if (merchantAgreement.length > 0) {
            if (merchantAgreement['CorporateInfo']['Address1'] != null &&
                merchantAgreement['CorporateInfo']['Address1'] != "") {
              merchantLocation = merchantAgreement['CorporateInfo']
                      ['Address1'] +
                  ", " +
                  merchantAgreement['CorporateInfo']['City'] +
                  ", " +
                  merchantAgreement['CorporateInfo']['State'] +
                  " " +
                  merchantAgreement['CorporateInfo']['First5Zip'];
            } else if (merchant['document']['MpaOutletInfo']['Outlet']
                        ['BusinessInfo']['LocationAddress1'] !=
                    null &&
                merchant['document']['MpaOutletInfo']['Outlet']['BusinessInfo']
                        ['LocationAddress1'] !=
                    "") {
              merchantLocation = merchant['document']['MpaOutletInfo']['Outlet']
                      ['BusinessInfo']['LocationAddress1'] +
                  ", " +
                  merchant['document']['MpaOutletInfo']['Outlet']
                      ['BusinessInfo']['City'] +
                  ", " +
                  merchant['document']['MpaOutletInfo']['Outlet']
                      ['BusinessInfo']['State'] +
                  " " +
                  merchant['document']['MpaOutletInfo']['Outlet']
                      ['BusinessInfo']['First5Zip'];
            }
          }
        }
      } else {
        Future.delayed(Duration(seconds: 1), () {
          logger.e("ERROR: Error getting merchant data: " +
              result.exception.toString());
        });

        Fluttertoast.showToast(
          msg: "Error getting merchant data: " + result.exception.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (err) {
      Future.delayed(Duration(seconds: 1), () {
        logger.e("ERROR: Error getting merchant data: " + err.toString());
      });

      Fluttertoast.showToast(
        msg: "Error getting merchant data: " + err.toString(),
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
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Merchant devices loaded");
        });

        setState(() {
          devices = devicesArrDecoded;
        });
      }
      isLoading = false;
      inventoryLoading = false;
    }, (error) {
      Future.delayed(Duration(seconds: 1), () {
        logger.e("ERROR: Error getting merchant devices: " + error.toString());
      });
    }, () => refreshSub());
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      loadMerchantData(this.widget.merchantId);
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Merchant data refreshed");
      });
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
              Future.delayed(Duration(seconds: 1), () {
                logger.i("Inventory opened: " +
                    device["priceTier"]['model'].toString() +
                    "-" +
                    device["serial"].toString() +
                    " (" +
                    device["inventory"].toString() +
                    ")");
              });

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

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
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
                                "Contact",
                                merchantContact,
                              ),
                              showInfoRow(
                                "Address",
                                merchantLocation,
                              ),
                              showInfoRow(
                                "Email",
                                merchantEmail,
                              ),
                              showInfoRow(
                                "Phone",
                                merchantPhoneNumber,
                              ),
                              showInfoRow(
                                "MID",
                                merchantID,
                              ),
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
                                      onPressed: () async {
                                        if (merchantEmail != null &&
                                            merchantEmail != "") {
                                          final Uri emailLaunchUri = Uri(
                                            scheme: 'mailto',
                                            path: '$merchantEmail',
                                            query: encodeQueryParameters(<
                                                String, String>{
                                              'subject':
                                                  'Followup about ${merchantDocument["leadDocument"]["businessName"]}'
                                            }),
                                          );

                                          await canLaunch(
                                                  emailLaunchUri.toString())
                                              ? launch(
                                                  emailLaunchUri.toString())
                                              : Fluttertoast.showToast(
                                                  msg:
                                                      "Could not launch email url: " +
                                                          emailLaunchUri
                                                              .toString(),
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      Colors.grey[600],
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
                                        } else {
                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            logger.e(
                                                "No email specified for email button");
                                          });

                                          Fluttertoast.showToast(
                                            msg: "No email specified!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.grey[600],
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
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
                                      onPressed: () async {
                                        if (merchantPhoneNumber != null &&
                                            merchantPhoneNumber != "") {
                                          var phoneLaunchURL =
                                              'tel:$merchantPhoneNumber';
                                          await canLaunch(
                                                  phoneLaunchURL.toString())
                                              ? launch(
                                                  phoneLaunchURL.toString())
                                              : Fluttertoast.showToast(
                                                  msg:
                                                      "Could not launch phone url: " +
                                                          phoneLaunchURL
                                                              .toString(),
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      Colors.grey[600],
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
                                        } else {
                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            logger.e(
                                                "No phone number specified for phone button");
                                          });

                                          Fluttertoast.showToast(
                                            msg: "No phone number specified!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.grey[600],
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
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
                                      onPressed: () async {
                                        if (merchantLocation != null) {
                                          try {
                                            MapsLauncher.launchQuery(
                                                merchantLocation);
                                          } catch (err) {
                                            print("Could not launch map url: " +
                                                merchantLocation.toString());

                                            Fluttertoast.showToast(
                                              msg:
                                                  "Could not launch map url: " +
                                                      merchantLocation
                                                          .toString(),
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.grey[600],
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          }
                                        } else {
                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            logger.e(
                                                "No address specified for map button");
                                          });

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
                                                                    ["document"]
                                                                [
                                                                "cashDiscountingPercent"]
                                                            .toString() +
                                                        "%",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )
                                                : Text(
                                                    "",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
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
