import 'dart:async';

import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';

class OwnerPanel extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String leadId;

  OwnerPanel(this.leadId);

  @override
  OwnerPanelState createState() => OwnerPanelState();
}

class Owner {
  Owner(
      {String name,
      String address,
      String city,
      String state,
      String phone,
      String email});
}

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
    this.contentCard,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
  Widget contentCard;
}

//OWNER CONTROLLER FIELDS
final _ownerNameController = TextEditingController();
final _ownerAddressController = TextEditingController();
final _ownerPhoneController = TextEditingController();
final _ownerEmailController = TextEditingController();

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

List<Item> ownerList = [
  Item(
      expandedValue: "Owner 1",
      headerValue: "Owner 1 text",
      contentCard: Card(
          child: Column(children: <Widget>[
        getInfoRow("Name", "owner", _ownerNameController),
      ]))),
  Item(expandedValue: "Owner 2", headerValue: "Owner 2 text")
];

class OwnerPanelState extends State<OwnerPanel> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ExpansionTile(
      title: Text("Ownerpanel"),
      initiallyExpanded: false,
    ));
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
