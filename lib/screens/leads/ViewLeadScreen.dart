import 'dart:async';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/shared/AddressSearch.dart';
import 'package:atlascrm/components/shared/Notes.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:atlascrm/components/shared/ImageUploader.dart';

class LeadInfoEntry {
  final TextEditingController controller;
  final Key key;
  LeadInfoEntry(this.controller, this.key);
}

class ViewLeadScreen extends StatefulWidget {
  final String leadId;

  ViewLeadScreen(this.leadId);

  @override
  ViewLeadScreenState createState() => ViewLeadScreenState();
}

class LeadSaveController {
  void Function() methodA;
}

bool pulseVisibility;

class ViewLeadScreenState extends State<ViewLeadScreen>
    with SingleTickerProviderStateMixin {
  final _leadFormKey = GlobalKey<FormState>();
  AnimationController pulseController;
  Animation pulse;

  var leadSaveController = LeadSaveController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailAddrController = TextEditingController();
  var phoneNumberController = MaskedTextController(mask: '000-000-0000');
  var businessNameController = TextEditingController();
  var dbaController = TextEditingController();
  var businessAddressController = TextEditingController();
  var notesController = TextEditingController();
  var leadSourceController = TextEditingController();

  var leadInfoEntries = List<LeadInfoEntry>();

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};
  String addressText;
  bool isChanged = false;
  var lead;
  var leadDocument;
  bool isLoading = true;
  var displayPhone;
  var statementDirty = TextEditingController();
  final scrollController = ScrollController();
  var repeats = 2;

  void initState() {
    super.initState();
    pulseVisibility = true;
    loadLeadData(this.widget.leadId);
    statementDirty.addListener(() {
      setState(() {});
      if (statementDirty.text == "true") {
        pulseController.forward();
      }
    });
    pulseController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    // pulseController.repeat(reverse: true);

    pulse = Tween(begin: 2.0, end: 15.0).animate(pulseController)
      ..addStatusListener((status) {
        if (repeats > 0 && statementDirty.text == "true") {
          if (status == AnimationStatus.completed) {
            pulseController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            pulseController.forward();
          }
          repeats--;
        } else {
          pulseController.stop();
          setState(() {
            pulseVisibility = false;
          });
        }
      })
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  Future<void> loadLeadData(leadId) async {
    QueryOptions options =
        QueryOptions(fetchPolicy: FetchPolicy.networkOnly, documentNode: gql("""
        query Lead(\$lead: uuid!) {
          lead_by_pk(lead: \$lead) {
            lead
            document
            employee: employeeByEmployee {
              fullName: document(path: "fullName")
            }
          }
        }
    """), variables: {"lead": this.widget.leadId});

    final QueryResult result = await client.query(options);

    if (result.hasException == false) {
      var body = result.data["lead_by_pk"];
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          lead = bodyDecoded;
          leadDocument = bodyDecoded["document"];
          firstNameController.text = leadDocument["firstName"];
        });
      }
    }

    setState(() {
      isLoading = false;
    });
    if (leadDocument?.isEmpty ?? true) {
      leadDocument = {
        "businessName": "",
        "businessType": "",
        "firstName": "",
        "lastName": "",
        "emailAddr": "",
        "phoneNumber": "",
        "dbaName": "",
        "address": "",
        "city": "",
        "state": "",
        "zipCode": "",
      };
    }
    if (leadDocument["address"] != null && leadDocument["address"] != "") {
      addressText = leadDocument["address"] +
          ", " +
          leadDocument["city"] +
          ", " +
          leadDocument["state"] +
          ", " +
          leadDocument["zipCode"];
      businessAddress["address"] = leadDocument["address"];
      businessAddress["city"] = leadDocument["city"];
      businessAddress["state"] = leadDocument["state"];
      businessAddress["zipcode"] = leadDocument["zipCode"];
    }
    if (leadDocument["phoneNumber"] != null ||
        leadDocument["phoneNumber"] != "") {
      setState(() {
        phoneNumberController.updateText(leadDocument["phoneNumber"]);
      });
    }
  }

  Future<void> updateLead(leadId) async {
    String rawNumber = phoneNumberController.text;
    var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");
    var updated = DateFormat('yyyy-MM-dd HH:mm:ss.mmm').format(DateTime.now());

    Map data = {
      "updated_at": updated,
      "updated_by": UserService.employee.employee,
      "document": {
        "dbaName": "${dbaController.text}",
        "city": "${businessAddress["city"]}",
        "state": "${businessAddress["state"]}",
        "address": "${businessAddress["address"]}",
        "zipCode": "${businessAddress["zipcode"]}",
        "emailAddr": "${emailAddrController.text}",
        "firstName": "${firstNameController.text}",
        "lastName": "${lastNameController.text}",
        "phoneNumber": "$filteredNumber",
        "businessName": "${businessNameController.text}",
        "leadSource": "${leadSourceController.text}"
      }
    };

    MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
        mutation UpdateLead (\$data: lead_set_input){
          update_lead_by_pk(pk_columns: {lead: "$leadId"}, _set: \$data){
            lead
          }
        }
      """), variables: {"data": data});
    final QueryResult result = await client.mutate(mutateOptions);

    if (result.hasException == false) {
      await loadLeadData(this.widget.leadId);

      Fluttertoast.showToast(
          msg: "Lead Updated!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to udpate lead!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> deleteCheck(leadId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete this Lead?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this lead?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel', style: TextStyle(fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Delete',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> popCheck() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text('Lead Actions'),
          content: SingleChildScrollView(
            child: Container(
              child: ListBody(
                children: <Widget>[
                  Card(
                      shape: RoundedRectangleBorder(
                          side: new BorderSide(
                              color: Colors.red[200], width: 2.0),
                          borderRadius: BorderRadius.circular(4.0)),
                      child: ListTile(
                          leading: Icon(Icons.priority_high, color: Colors.red),
                          title: Text("Unsent Statement"),
                          subtitle:
                              Text("Please submit your statement for review."),
                          onTap: () {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: Duration(seconds: 1),
                              curve: Curves.fastOutSlowIn,
                            );
                            Navigator.pop(context);
                          })),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget button;
  actionButton() {
    if (statementDirty.text == "true") {
      setState(() {
        button = CircleAvatar(
          radius: 25,
          backgroundColor: Colors.red,
          child: IconButton(
            icon: Icon(Icons.priority_high, color: Colors.white),
            onPressed: () {},
          ),
        );
      });
    } else {
      setState(() {
        button = IconButton(
          icon: Icon(Icons.done, color: Colors.green),
          onPressed: () {},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 242, 242, 242),
        appBar: CustomAppBar(
          key: Key("viewTasksAppBar"),
          title: Text(isLoading ? "Loading..." : leadDocument["businessName"]),
          action: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
              child: statementDirty.text == "true"
                  ? Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pulseVisibility
                              ? Colors.red[600]
                              : Color.fromRGBO(0, 0, 0, 0),
                          boxShadow: [
                            BoxShadow(
                                color: pulseVisibility
                                    ? Colors.red[600]
                                    : Color.fromRGBO(0, 0, 0, 0),
                                blurRadius: pulse.value,
                                spreadRadius: pulse.value)
                          ]),
                      child: SizedBox(
                          width: 55.0,
                          height: 55.0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: Icon(Icons.priority_high,
                                  color: Colors.white),
                              onPressed: () {
                                popCheck();
                              },
                            ),
                          )),
                    )
                  : IconButton(
                      icon: Icon(Icons.done, color: Colors.green),
                      onPressed: () {},
                    ),
            )
          ],
        ),
        body: isLoading
            ? CenteredClearLoadingScreen()
            : Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _leadFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomCard(
                          key: Key("leads2"),
                          icon: Icons.business,
                          title: "Business Information",
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              validatorRow(
                                  "Business Name",
                                  leadDocument["businessName"],
                                  businessNameController, (val) {
                                if (val.isEmpty) {
                                  return 'Please enter a business name';
                                }
                                return null;
                              }),
                              getInfoRow("Doing Business As",
                                  leadDocument["dbaName"], dbaController),
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
                                                  locationValue: addressText,
                                                  onAddressChange: (val) =>
                                                      businessAddress = val)),
                                        ],
                                      ))),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("leads1"),
                          icon: Icons.person,
                          title: "Contact Information",
                          child: Column(
                            children: <Widget>[
                              validatorRow(
                                  "First Name",
                                  leadDocument["firstName"],
                                  firstNameController, (val) {
                                if (val.isEmpty) {
                                  return 'Please enter a contact first name';
                                }
                                return null;
                              }),
                              getInfoRow("Last Name", leadDocument["lastName"],
                                  lastNameController),
                              validatorRow(
                                  "Email Address",
                                  leadDocument["emailAddr"],
                                  emailAddrController, (value) {
                                if (value.isNotEmpty && !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              }),
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Phone Number',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: TextField(
                                          controller: phoneNumberController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      color: Color.fromARGB(500, 1, 224, 143),
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
                                        if (emailAddrController.text != null &&
                                            emailAddrController.text != "") {
                                          var launchURL1 =
                                              'mailto:${emailAddrController.text}?subject=Followup about ${businessNameController.text}';
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
                                      color: Color.fromARGB(500, 1, 224, 143),
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
                                        if (phoneNumberController.text !=
                                                null &&
                                            phoneNumberController.text != "") {
                                          var launchURL2 =
                                              'tel:${phoneNumberController.text}';
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
                          key: Key("leads3"),
                          icon: Icons.question_answer,
                          title: "Misc Information",
                          child: Column(
                            children: <Widget>[
                              getInfoRow(
                                  "Lead Source",
                                  leadDocument["leadSource"],
                                  leadSourceController),
                            ],
                          ),
                        ),
                        CustomCard(
                            key: Key("leads4"),
                            title: "Notes",
                            icon: Icons.note,
                            child: Notes(type: "lead", object: lead["lead"])),
                        CustomCard(
                          key: Key("leads5"),
                          title: "Tools",
                          icon: Icons.build,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: MaterialButton(
                                  padding: EdgeInsets.all(5),
                                  color: Color.fromARGB(500, 1, 224, 143),
                                  // color: Colors.grey[300],
                                  onPressed: () {
                                    // return null;
                                    Navigator.pushNamed(
                                        context, "/agreementbuilder",
                                        arguments: lead["lead"]);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.extension,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Agreement Builder',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ImageUploader(
                        //     type: "statement",
                        //     objectId: lead["lead"],
                        //     loading: {"loading": isLoading},
                        //     controller: leadSaveController,
                        //     dirtyFlag: {"flag": statementDirty}),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // leadSaveController.methodA();
            if (_leadFormKey.currentState.validate()) {
              updateLead(this.widget.leadId);
            }
          },
          backgroundColor: Color.fromARGB(500, 1, 224, 143),
          child: Icon(Icons.save),
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
                onChanged: (s) {},
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget validatorRow(label, value, controller, validator) {
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
                validator: validator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
