import 'dart:async';

import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OwnerPanel extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final Map owner;
  final Key key;
  final Function onOwnerChange;
  OwnerPanel({this.owner, this.key, this.onOwnerChange});

  @override
  _OwnerPanelState createState() => _OwnerPanelState(owner: owner, key: key);
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

class _OwnerPanelState extends State<OwnerPanel> {
  Map ownerAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  final Map owner;
  final Key key;
  final Function onOwnerChange;

  _OwnerPanelState({this.owner, this.key, this.onOwnerChange});
  void initState() {
    super.initState();
  }

  Map _ownerDoc;
  var _name;
  var _email;
  var addressText;
//OWNER CONTROLLER FIELDS
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerNameController = TextEditingController();

  Future<Null> initOwner() async {
    if (_ownerDoc["address"] != null && _ownerDoc["address"] != "") {
      setState(() {
        addressText = _ownerDoc["address"] +
            ", " +
            _ownerDoc["city"] +
            ", " +
            _ownerDoc["state"] +
            ", " +
            _ownerDoc["zipCode"];
      });
    }
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
              child: TextField(
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> updateOwner() async {
    var ownerObj;

    if (owner["new"] != null) {
      ownerObj = {
        "new": owner["new"],
        "lead": owner["lead"],
        "document": {
          "name": _ownerNameController.text,
          "phoneNumber": _ownerPhoneController.text,
          "email": _ownerEmailController.text,
          "address": ownerAddress["address"],
          "city": ownerAddress["city"],
          "state": ownerAddress["state"],
          "zipCode": ownerAddress["zipcode"]
        }
      };
    } else {
      ownerObj = {
        "business_owner": owner["business_owner"],
        "lead": owner["lead"],
        "document": {
          "name": _ownerNameController.text,
          "phoneNumber": _ownerPhoneController.text,
          "email": _ownerEmailController.text,
          "address": ownerAddress["address"],
          "city": ownerAddress["city"],
          "state": ownerAddress["state"],
          "zipCode": ownerAddress["zipcode"]
        }
      };
    }

    this.widget.onOwnerChange(ownerObj);
  }

  @override
  Widget build(BuildContext context) {
    _ownerDoc = this.widget.owner["document"];

    // _ownerNameController.addListener(() {
    //   updateOwner();
    // });

    setState(() {
      _ownerNameController.text = this.owner["document"]["name"];
      _ownerEmailController.text = this.owner["document"]["email"];
    });
    return Card(
        child: ExpansionTile(
            title: Row(children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Icon(Icons.person),
              ),
              Text(_ownerNameController.text)
            ]),
            initiallyExpanded: false,
            children: <Widget>[
          getInfoRow("Name", _name, _ownerNameController),
          getInfoRow("Email", _email, _ownerEmailController),
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
          FlatButton(
              color: Colors.blue,
              onPressed: () => updateOwner(),
              child: Text("Save", style: TextStyle(color: Colors.white)))
        ]));
  }
}
