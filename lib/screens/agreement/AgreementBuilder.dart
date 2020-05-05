import 'dart:async';
import 'dart:developer';

import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:atlascrm/components/agreement/OwnerPanel.dart';

class AgreementBuilder extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String leadId;

  AgreementBuilder(this.leadId);

  @override
  AgreementBuilderState createState() => AgreementBuilderState();
}

// class Owner {
//   Owner({
//     String business_owner,
//     String lead,
//     List document,
//   });
// }

class Item {
  Item(
      {this.expandedValue,
      this.headerValue,
      this.isExpanded = false,
      this.contentCard = const Text("nocontent")});

  String expandedValue;
  String headerValue;
  bool isExpanded;
  Widget contentCard;
}

List<Item> ownerList = [
  Item(
      expandedValue: "Owner 1",
      headerValue: "Owner 1 text",
      contentCard: Card(
          child: Column(children: <Widget>[
        TextField(),
        TextField(),
        TextField(),
        TextField(),
      ]))),
  Item(expandedValue: "Owner 2", headerValue: "Owner 2 text")
];

class AgreementBuilderState extends State<AgreementBuilder>
    with TickerProviderStateMixin {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddrController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final dbaController = TextEditingController();
  final businessAddressController = TextEditingController();
  final leadSourceController = TextEditingController();
  //OWNER FIELDS
  // final ownerNameController = TextEditingController();
  // final ownerAddressController = TextEditingController();
  // final ownerPhoneController = TextEditingController();
  // final ownerEmailController = TextEditingController();

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  var agreementBuilder;
  var agreementDocument;
  var lead;
  var leadDocument;
  var addressText;
  var isLoading = true;
  List owners;
  Map testOwner;

  void initState() {
    super.initState();
    loadAgreementData(this.widget.leadId);
  }

  Future<void> loadLeadData(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/lead/" + this.widget.leadId);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          lead = bodyDecoded;
          leadDocument = bodyDecoded["document"];
        });
      }
    }
  }

  Future<void> loadOwnersData(leadId) async {
    try {
      var resp = await this
          .widget
          .apiService
          .authGet(context, "/lead/" + this.widget.leadId + "/business_owner");
      print(resp);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var ownersArrDecoded = resp.data;
          if (ownersArrDecoded != null) {
            var ownersArr = List.from(ownersArrDecoded);
            if (ownersArr.length > 0) {
              setState(() {
                isLoading = false;
                owners = ownersArr;
                testOwner = ownersArr[0];
              });
            } else {
              setState(() {
                isLoading = false;
                ownersArr = [];
                owners = [];
              });
            }
          }
        }
      }
    } catch (err) {
      log(err);
    }
  }

  Future<void> loadAgreementData(leadId) async {
    loadOwnersData(this.widget.leadId);
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/lead/" + this.widget.leadId + "/agreement_builder");

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body["agreement_builder"] != null) {
        var bodyDecoded = body;
        setState(() {
          agreementBuilder = bodyDecoded;
          agreementDocument = bodyDecoded["document"];
        });
        setState(() {
          isLoading = false;
          // if (agreementDocument["address"] != null &&
          //     agreementDocument["address"] != "") {
          //   addressText = agreementDocument["address"] +
          //       ", " +
          //       agreementDocument["city"] +
          //       ", " +
          //       agreementDocument["state"] +
          //       ", " +
          //       agreementDocument["zipCode"];
          //   businessAddress["address"] = agreementDocument["address"];
          //   businessAddress["city"] = agreementDocument["city"];
          //   businessAddress["state"] = agreementDocument["state"];
          //   businessAddress["zipcode"] = agreementDocument["zipCode"];
          //   print(businessAddress);
          // }
          isLoading = false;
        });
      } else {
        generateAgreement();
      }
    }
  }

  generateAgreement() async {
    await loadLeadData(this.widget.leadId);
    print(lead);
    print(this.widget.leadId);
    agreementBuilder = {
      "employee": lead["employee"],
      "lead": lead["lead"],
      "document": lead["document"]
    };

    var resp1 = await this
        .widget
        .apiService
        .authPost(context, "/agreement_builder", agreementBuilder);
    if (resp1 != null) {
      if (resp1.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Agreement Builder Created!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      throw new Error();
    }

    setState(() {
      agreementDocument = agreementBuilder["document"];
      print(agreementDocument);
      if (agreementDocument["address"] != null &&
          agreementDocument["address"] != "") {
        addressText = agreementDocument["address"] +
            ", " +
            agreementDocument["city"] +
            ", " +
            agreementDocument["state"] +
            ", " +
            agreementDocument["zipCode"];
        businessAddress["address"] = agreementDocument["address"];
        businessAddress["city"] = agreementDocument["city"];
        businessAddress["state"] = agreementDocument["state"];
        businessAddress["zipcode"] = agreementDocument["zipCode"];
        print(businessAddress);
      }
      isLoading = false;
    });
    print("GENERATE");
  }

  Future<void> updateAgreement(agreementBuilderId) async {
    var agreementBuilderObj = {
      //Business Info Section
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "emailAddr": emailAddrController.text,
      "phoneNumber": phoneNumberController.text,
      "businessName": businessNameController.text,
      "dbaName": dbaController.text,
      "businessAddress": businessAddressController.text,
      "leadSource": leadSourceController.text,
      "address": businessAddress["address"],
      "city": businessAddress["city"],
      "state": businessAddress["state"],
      "zipCode": businessAddress["zipcode"]
    };

    var resp = await this.widget.apiService.authPut(context,
        "/agreement_builder/" + agreementBuilderId, agreementBuilderObj);

    if (resp.statusCode == 200) {
      await loadAgreementData(this.widget.leadId);

      Fluttertoast.showToast(
          msg: "Agreement Builder Saved!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to Save!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> leaveCheck() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Really Leave?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Any unsaved changes will be lost.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Leave',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                Navigator.pushNamed(context, '/leads');
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      print(_tabController.index);
      Fluttertoast.showToast(
          msg: "Scrolled to index: ${_tabController.index}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
      print(lastNameController.text);
    });

    return WillPopScope(
      onWillPop: () {
        leaveCheck();
        return Future.value(false);
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              // key: Key("contactInfoPageAppBar"),
              title: Text(isLoading ? "Loading..." : "Agreement Builder"),
              backgroundColor: Color.fromARGB(500, 1, 56, 112),
              bottom: TabBar(
                isScrollable: false,
                tabs: [
                  Tab(text: "Business Info"),
                  Tab(text: "Owner Info"),
                  Tab(text: "Rate Review")
                ],
                controller: _tabController,
              )),
          body: isLoading
              ? CenteredClearLoadingScreen()
              : TabBarView(controller: _tabController, children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCard(
                            key: Key("leads1"),
                            icon: Icons.business,
                            title: "Business Info",
                            child: Column(
                              children: <Widget>[
                                getInfoRow(
                                    "First Name",
                                    agreementDocument["firstName"],
                                    firstNameController),
                                getInfoRow(
                                    "Last Name",
                                    agreementDocument["lastName"],
                                    lastNameController),
                                getInfoRow(
                                    "Email Address",
                                    agreementDocument["emailAddr"],
                                    emailAddrController),
                                getInfoRow(
                                    "Phone Number",
                                    agreementDocument["phoneNumber"],
                                    phoneNumberController),
                                getInfoRow(
                                    "Business Name",
                                    agreementDocument["businessName"],
                                    businessNameController),
                                getInfoRow(
                                    "Doing Business As",
                                    agreementDocument["dbaName"],
                                    dbaController),
                                Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                'Business Address:',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 8,
                                                child: AddressSearch(
                                                    locationValue: (agreementDocument[
                                                                    "address"] !=
                                                                null &&
                                                            agreementDocument[
                                                                    "address"] !=
                                                                "")
                                                        ? agreementDocument["address"] +
                                                            ", " +
                                                            agreementDocument[
                                                                "city"] +
                                                            ", " +
                                                            agreementDocument[
                                                                "state"] +
                                                            ", " +
                                                            agreementDocument[
                                                                "zipCode"]
                                                        : null,
                                                    onAddressChange: (val) =>
                                                        businessAddress = val)),
                                          ],
                                        ))),
                                getInfoRow(
                                    "Lead Source",
                                    agreementDocument["leadSource"],
                                    leadSourceController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView(
                            children: owners.map((owner) {
                          return OwnerPanel(owner);
                        }).toList()),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCard(
                            key: Key("rates1"),
                            icon: Icons.attach_money,
                            title: "Rate Review",
                            child: Column(
                              children: <Widget>[
                                //PUT GET INFO ROWS HERE
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              updateAgreement(agreementBuilder["agreement_builder"]);
            },
            backgroundColor: Color.fromARGB(500, 1, 224, 143),
            child: Icon(Icons.save),
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
              child: TextField(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
