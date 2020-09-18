import 'dart:async';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class OwnerInfo extends StatefulWidget {
  final Map isDirtyStatus;
  final List owners;
  final Map controllers;
  final String lead;
  final Key formKey;
  final Map validationErrors;
  final VoidCallback callback;

  OwnerInfo(
      {this.owners,
      this.controllers,
      this.lead,
      this.isDirtyStatus,
      this.formKey,
      this.validationErrors,
      this.callback});

  @override
  OwnerInfoState createState() => OwnerInfoState();
}

class OwnerInfoState extends State<OwnerInfo> with TickerProviderStateMixin {
  final ownersKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
  }

  bool guarantorSet = false;

  var titles = [
    {"value": "1", "name": "President"},
    {"value": "2", "name": "Vice President"},
    {"value": "3", "name": "Treasurer"},
    {"value": "4", "name": "Owner"},
    {"value": "5", "name": "Partner"},
    {"value": "6", "name": "CEO"},
    {"value": "7", "name": "Secretary"},
    {"value": "8", "name": "Director"},
  ];
  var yesNoOptions = [
    {"value": "0", "name": "No"},
    {"value": "1", "name": "Yes"}
  ];
  var stateDL = [
    {"value": "AL", "name": "Alabama"},
    {"value": "AK", "name": "Alaska"},
    {"value": "AZ", "name": "Arizona"},
    {"value": "AR", "name": "Arkansas"},
    {"value": "CA", "name": "California"},
    {"value": "CO", "name": "Colorado"},
    {"value": "CT", "name": "Connecticut"},
    {"value": "DE", "name": "Delaware"},
    {"value": "DC", "name": "District Of Columbia"},
    {"value": "FL", "name": "Florida"},
    {"value": "GA", "name": "Georgia"},
    {"value": "HI", "name": "Hawaii"},
    {"value": "ID", "name": "Idaho"},
    {"value": "IL", "name": "Illinois"},
    {"value": "IN", "name": "Indiana"},
    {"value": "IA", "name": "Iowa"},
    {"value": "KS", "name": "Kansas"},
    {"value": "KY", "name": "Kentucky"},
    {"value": "LA", "name": "Louisiana"},
    {"value": "ME", "name": "Maine"},
    {"value": "MD", "name": "Maryland"},
    {"value": "MA", "name": "Massachusetts"},
    {"value": "MI", "name": "Michigan"},
    {"value": "MN", "name": "Minnesota"},
    {"value": "MS", "name": "Mississippi"},
    {"value": "MO", "name": "Missouri"},
    {"value": "MT", "name": "Montana"},
    {"value": "NE", "name": "Nebraska"},
    {"value": "NV", "name": "Nevada"},
    {"value": "NH", "name": "New Hampshire"},
    {"value": "NJ", "name": "New Jersey"},
    {"value": "NM", "name": "New Mexico"},
    {"value": "NY", "name": "New York"},
    {"value": "NC", "name": "North Carolina"},
    {"value": "ND", "name": "North Dakota"},
    {"value": "OH", "name": "Ohio"},
    {"value": "OK", "name": "Oklahoma"},
    {"value": "OR", "name": "Oregon"},
    {"value": "PA", "name": "Pennsylvania"},
    {"value": "RI", "name": "Rhode Island"},
    {"value": "SC", "name": "South Carolina"},
    {"value": "SD", "name": "South Dakota"},
    {"value": "TN", "name": "Tennessee"},
    {"value": "TX", "name": "Texas"},
    {"value": "UT", "name": "Utah"},
    {"value": "VT", "name": "Vermont"},
    {"value": "VA", "name": "Virginia"},
    {"value": "WA", "name": "Washington"},
    {"value": "WV", "name": "West Virginia"},
    {"value": "WI", "name": "Wisconsin"},
    {"value": "WY", "name": "Wyoming"},
  ];

  Future<void> addOwner() async {
    if (this.widget.owners.length < 5) {
      setState(() {
        this.widget.owners.add({
          "new": true,
          "lead": this.widget.lead,
          "document": {
            "PrinDob": "",
            "PrinSsn": "",
            "PrinCity": "",
            "PrinPhone": "",
            "PrinState": "",
            "PrinTitle": "",
            "PrinAddress": "",
            "PrinLastName": "",
            "PrinFirst5Zip": "",
            "PrinFirstName": "",
            "PrinEmailAddress": "",
            "PrinGuarantorCode": "",
            "PrinOwnershipPercent": "",
            "PrinDriverLicenseState": "",
            "PrinDriverLicenseNumber": "",
          }
        });
      });
    } else {
      Fluttertoast.showToast(
          msg: "Maximum Number of Owners Added!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> setAddress(addressObj) async {
    var address = addressObj["value"];
    var index = addressObj["index"];
    print(address);
    setState(() {
      this.widget.owners[index]["document"]["PrinAddress"] = address["address"];
      this.widget.owners[index]["document"]["PrinCity"] = address["city"];
      this.widget.owners[index]["document"]["PrinState"] = address["state"];
      this.widget.owners[index]["document"]["PrinFirst5Zip"] =
          address["zipcode"];
      this.widget.isDirtyStatus["ownersIsDirty"] = true;
    });
  }

  String validateRow(newVal, errorLocation, errorName, {message}) {
    if (this.widget.validationErrors != null) {
      if (this.widget.validationErrors["$errorLocation"] != null) {
        if (this.widget.validationErrors["$errorLocation"]["$errorName"] !=
            null) {
          return this
              .widget
              .validationErrors["$errorLocation"]["$errorName"]
              .toString();
        }
      }
    }
    if (newVal.isEmpty) {
      return message != null ? message : "Required";
    } else {
      return null;
    }
  }

  String validateSsnRow(newVal, errorLocation, errorName, {message}) {
    if (this.widget.validationErrors != null) {
      if (this.widget.validationErrors["$errorLocation"] != null) {
        if (this.widget.validationErrors["$errorLocation"]["$errorName"] !=
            null) {
          return this
              .widget
              .validationErrors["$errorLocation"]["$errorName"]
              .toString();
        }
      }
    }
    if (newVal.isEmpty) {
      return message != null ? message : "Required";
    } else if (newVal.length < 9) {
      return "SSN is too Short";
    } else if (newVal.length > 9 && newVal.length < 11) {
      return "SSN is too Long";
    } else {
      return null;
    }
  }

  Future<void> deleteCheck(ownerId, index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Owner?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Owner will be permanently removed.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                deleteOwner(ownerId, index);
                Navigator.of(context).pop();
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

  Future<void> deleteOwner(ownerId, index) async {
    setState(() {
      this.widget.owners.removeAt(index);
    });
    if (ownerId != null) {
      var resp;
      //REPLACE WITH GRAPHQL
      // var resp = await this
      //     .widget
      //     .apiService
      //     .authDelete(context, "/businessowner/$ownerId", null);

      if (resp.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Owner Deleted!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Failed Delete!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Owner Deleted!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
    this.widget.isDirtyStatus["ownersIsDirty"] = true;
    this.widget.callback();
  }

  Future<void> setGuarantor(val) async {
    if (val == "1") {
      setState(() {
        guarantorSet = true;
      });
    } else if (val == "0") {
      setState(() {
        guarantorSet = false;
      });
    }
  }

  Widget buildDLGridView() {
    return Column(
        // shrinkWrap: true,
        children: List.generate(this.widget.owners.length, (index) {
      var owner = this.widget.owners[index];
      var iterateLoc = index + 1;
      var ssnMask;
      if (owner["document"]["PrinSsn"] != null) {
        if (owner["document"]["PrinSsn"].length < 11) {
          setState(() {
            ssnMask = "000000000";
          });
        } else {
          setState(() {
            ssnMask = null;
          });
        }
      }

      if (owner["document"]["PrinGuarantorCode"] == "1") {
        setState(() {
          guarantorSet = true;
        });
      }

      return Card(
          child: ExpansionTile(
              title: Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Icon(Icons.person),
                ),
                Text(owner["document"]["PrinFirstName"] +
                    " " +
                    owner["document"]["PrinLastName"])
              ]),
              initiallyExpanded: false,
              children: <Widget>[
            editObjectRow("First Name", owner["document"]["PrinFirstName"],
                this.widget.controllers["Prin${iterateLoc}FirstName"],
                object: "PrinFirstName",
                index: index,
                validator: (newValue) => validateRow(
                    newValue, "Ownership", "Prin${iterateLoc}FirstName")),
            editObjectRow("Last Name", owner["document"]["PrinLastName"],
                this.widget.controllers["Prin${iterateLoc}LastName"],
                object: "PrinLastName",
                index: index,
                validator: (newValue) => validateRow(
                    newValue, "Ownership", "Prin${iterateLoc}LastName")),
            editObjectDropdown("Title", owner["document"]["PrinTitle"], titles,
                object: "PrinTitle", index: index, validator: (newValue) {
              if (newValue == null) {
                return "Required";
              } else {
                return null;
              }
            }),
            editObjectDropdown("Guarantor? ",
                owner["document"]["PrinGuarantorCode"], yesNoOptions,
                object: "PrinGuarantorCode",
                index: index,
                disabled: guarantorSet &&
                    owner["document"]["PrinGuarantorCode"] != "1",
                guarantor: true,
                setVal: "1", validator: (newValue) {
              if (newValue == null) {
                return "Only one Guarantor Required";
              } else {
                return null;
              }
            }),
            editObjectRow("Birthdate", owner["document"]["PrinDob"],
                this.widget.controllers["Prin${iterateLoc}Dob"],
                mask: "00/00/0000",
                object: "PrinDob",
                index: index,
                validator: (newValue) =>
                    validateRow(newValue, "Ownership", "Prin${iterateLoc}Dob")),
            editObjectSsnRow(
                "Social Security Number",
                owner["document"]["PrinSsn"],
                this.widget.controllers["Prin${iterateLoc}Ssn"],
                obscure: true,
                object: "PrinSsn",
                index: index,
                mask: ssnMask,
                validator: (newValue) => validateSsnRow(
                    newValue, "Ownership", "Prin${iterateLoc}Ssn")),
            editObjectRow(
                "Ownership Percent",
                owner["document"]["PrinOwnershipPercent"],
                this.widget.controllers["Prin${iterateLoc}OwnershipPercent"],
                object: "PrinOwnershipPercent",
                index: index,
                validator: (newValue) => validateRow(newValue, "Ownership",
                    "Prin${iterateLoc}OwnershipPercent")),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Address:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: AddressSearch(
                        locationValue:
                            (owner["document"]["PrinAddress"] != null &&
                                    owner["document"]["PrinAddress"] != "")
                                ? owner["document"]["PrinAddress"] +
                                    ", " +
                                    owner["document"]["PrinCity"] +
                                    ", " +
                                    owner["document"]["PrinState"] +
                                    ", " +
                                    owner["document"]["PrinFirst5Zip"]
                                : null,
                        onAddressChange: (val) {
                          var addObj = {"value": val, "index": index};
                          setAddress(addObj);
                        },
                        lineColor: this.widget.owners[index]["document"]
                                    ["PrinAddress"] ==
                                ""
                            ? Colors.red
                            : null),
                  ),
                  this.widget.owners[index]["document"]["PrinAddress"] == ""
                      ? Icon(Icons.error, color: Colors.red)
                      : Container()
                ],
              ),
            ),
            editObjectRow("Phone", owner["document"]["PrinPhone"],
                this.widget.controllers["Prin${iterateLoc}Phone"],
                object: "PrinPhone",
                index: index,
                mask: "000-000-0000",
                validator: (newValue) => validateRow(
                    newValue, "Ownership", "Prin${iterateLoc}Phone")),
            editObjectRow("Email", owner["document"]["PrinEmailAddress"],
                this.widget.controllers["Prin${iterateLoc}EmailAddress"],
                object: "PrinEmailAddress",
                index: index,
                validator: (newValue) => validateRow(
                    newValue, "Ownership", "Prin${iterateLoc}EmailAddress")),
            editObjectRow(
                "Driver License Number",
                owner["document"]["PrinDriverLicenseNumber"],
                this.widget.controllers["Prin${iterateLoc}DriverLicenseNumber"],
                object: "PrinDriverLicenseNumber",
                index: index,
                mask: "000000000000000",
                validator: (newValue) => validateRow(newValue, "Ownership",
                    "Prin${iterateLoc}DriverLicenseNumber")),
            editObjectSearchableDropdown("Driver License State",
                owner["document"]["PrinDriverLicenseState"], stateDL,
                object: "PrinDriverLicenseState",
                index: index, validator: (newValue) {
              if (newValue == null) {
                return "Required";
              } else {
                return null;
              }
            }),
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red, size: 30),
              onPressed: () {
                deleteCheck(owner["business_owner"], index);
              },
            )
          ]));
    }));
  }

  Widget build(BuildContext context) {
    return Form(
      key: ownersKey,
      autovalidate: true,
      onChanged: () {
        setState(() {
          this.widget.isDirtyStatus["ownersIsDirty"] = true;
        });
      },
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          buildDLGridView(),
          this.widget.owners.length < 5
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: FlatButton(
                      color: Color.fromARGB(500, 1, 224, 143),
                      onPressed: () => addOwner(),
                      child: Text("Add Owner",
                          style: TextStyle(color: Colors.white))),
                )
              : Container()
        ],
      ),
    );
  }

  Widget editObjectRow(label, value, controller,
      {object, index, mask, validator, obscure}) {
    if (mask != null) {
      controller.updateMask(mask);
    }
    bool isValidating = false;
    bool isObscure = false;
    if (validator != null) {
      setState(() {
        isValidating = true;
      });
    }
    if (obscure != null) {
      setState(() {
        isObscure = obscure;
      });
    }

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
                onChanged: (newValue) {
                  setState(() {
                    this.widget.isDirtyStatus["ownersIsDirty"] = true;
                    this.widget.owners[index]["document"][object] = newValue;
                  });
                },
                controller: controller,
                validator: isValidating ? validator : null,
                obscureText: isObscure,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget editObjectSsnRow(label, value, controller,
      {object, index, mask, validator, obscure}) {
    if (mask != null) {
      controller.updateMask(mask);
    }
    if (mask == null) {
      controller.updateMask(
          "************************************************************");
    }
    bool isValidating = false;
    bool isObscure = false;
    if (validator != null) {
      setState(() {
        isValidating = true;
      });
    }
    if (obscure != null) {
      setState(() {
        isObscure = obscure;
      });
    }

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
                onChanged: (newValue) {
                  setState(() {
                    this.widget.isDirtyStatus["ownersIsDirty"] = true;
                    if (newValue.length <= 9) {
                      this.widget.owners[index]["document"][object] = newValue;
                    }
                    if (newValue.length > 9) {
                      this.widget.owners[index]["document"][object] = "";
                    }
                  });
                },
                controller: controller,
                validator: isValidating ? validator : null,
                obscureText: isObscure,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget editObjectSearchableDropdown(label, value, dropList,
      {object, index, validator}) {
    var currentVal;
    currentVal = null;

    if (value != null && value != "") {
      // controller.text = value;
      setState(() {
        this.widget.owners[index]["document"][object] = value;
        currentVal = this.widget.owners[index]["document"][object];
      });
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
              child: SearchableDropdown.single(
                validator: validator != null ? validator : null,
                value: currentVal,
                onClear: () {
                  setState(() {
                    currentVal = null;
                    value = null;
                  });
                },
                hint: "Please choose one",
                searchHint: null,
                isExpanded: true,
                // menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                items: dropList.map<DropdownMenuItem<String>>((dynamic item) {
                  var itemName = item["name"];
                  var itemValue = item["value"];
                  return DropdownMenuItem<String>(
                    value: itemValue,
                    child: Text(
                      itemName,
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    this.widget.owners[index]["document"][object] = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget editObjectDropdown(label, value, dropList,
      {object, index, setVal, validator, disabled, guarantor}) {
    var _currentVal;
    _currentVal = null;
    bool isGuarantor = false;
    bool isDisabled = false;
    if (guarantor != null && guarantor == true) {
      isGuarantor = guarantor;
    }
    if (disabled != null && disabled == true) {
      isDisabled = disabled;
    }

    if (value != null && value != "") {
      this.widget.owners[index]["document"][object] = value;
      _currentVal = this.widget.owners[index]["document"][object];
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
              child: DropdownButtonFormField<String>(
                value: _currentVal,
                validator: validator != null ? validator : null,
                isExpanded: true,
                hint: Text("Please choose one"),
                items: dropList.map<DropdownMenuItem<String>>((dynamic item) {
                  var itemName = item["name"];
                  var itemValue = item["value"];
                  return DropdownMenuItem<String>(
                    value: itemValue,
                    child: Text(
                      itemName,
                    ),
                  );
                }).toList(),
                onChanged: isDisabled
                    ? null
                    : (newValue) {
                        setState(() {
                          this.widget.isDirtyStatus["ownersIsDirty"] = true;
                          this.widget.owners[index]["document"][object] =
                              newValue;
                        });
                        if (isGuarantor) {
                          setGuarantor(newValue);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
