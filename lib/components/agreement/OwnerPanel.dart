import 'dart:async';

import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';

class OwnerPanel extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map _owner;

  OwnerPanel(this._owner);

  @override
  _OwnerPanelState createState() => _OwnerPanelState();
}

class Owner {
  Owner({
    this.business_owner,
    this.lead,
    this.document,
  });
  String business_owner;
  String lead;
  Map document;
}

//OWNER CONTROLLER FIELDS
final _ownerNameController = TextEditingController();
// final _ownerAddressController = TextEditingController();
// final _ownerPhoneController = TextEditingController();
// final _ownerEmailController = TextEditingController();

Widget getInfoRow(_label, _value, _controller) {
  if (_value != null) {
    _controller.text = _value;
  }

  var valueFmt = _value ?? "N/A";

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
              '$_label: ',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 8,
            child: TextField(controller: _controller),
          ),
        ],
      ),
    ),
  );
}

class _OwnerPanelState extends State<OwnerPanel> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map _ownerDoc = this.widget._owner["document"];
    var _name = _ownerDoc["name"];

    return Card(
        child: ExpansionTile(
            title: Text("Ownerpanel"),
            initiallyExpanded: false,
            children: <Widget>[
          getInfoRow("Name", _name, _ownerNameController),
        ]));
  }
}
