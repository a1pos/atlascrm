import 'dart:async';

import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';

class OwnerPanel extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map _owner;
  final Key key;
  OwnerPanel(this._owner, this.key);

  @override
  _OwnerPanelState createState() => _OwnerPanelState(owner: _owner, key: key);
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
  Map ownerAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  final Map owner;
  final Key key;
  Map _ownerDoc;
  var _name;
//OWNER CONTROLLER FIELDS
// final _ownerAddressController = TextEditingController();
// final _ownerPhoneController = TextEditingController();
// final _ownerEmailController = TextEditingController();
  final _ownerNameController = TextEditingController();

  _OwnerPanelState({this.owner, this.key});
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _ownerDoc = this.widget._owner["document"];
      _name = _ownerDoc["name"];
      print("SETTING STATE " + _name);
    });
    return Card(
        child: ExpansionTile(
            title: Text(_name),
            initiallyExpanded: false,
            children: <Widget>[
          getInfoRow("Name", _name, _ownerNameController),
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
                              locationValue: (_ownerDoc["address"] != null &&
                                      _ownerDoc["address"] != "")
                                  ? _ownerDoc["address"] +
                                      ", " +
                                      _ownerDoc["city"] +
                                      ", " +
                                      _ownerDoc["state"] +
                                      ", " +
                                      _ownerDoc["zipCode"]
                                  : null,
                              onAddressChange: (val) => ownerAddress = val)),
                    ],
                  ))),
        ]));
  }
}
