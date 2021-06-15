import 'dart:async';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

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

bool pulseVisibility;

class ViewLeadScreenState extends State<ViewLeadScreen>
    with SingleTickerProviderStateMixin {
  final _leadFormKey = GlobalKey<FormState>();
  final scrollController = ScrollController();

  MaskedTextController phoneNumberController =
      MaskedTextController(mask: '000-000-0000');
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailAddrController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController dbaController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController leadSourceController = TextEditingController();

  AnimationController pulseController;
  Animation pulse;

  Map businessAddress = {"address": "", "city": "", "state": "", "zipcode": ""};

  String addressText;

  bool isChanged = false;
  bool isLoading = true;
  bool isBoarded;
  bool statementDirty = false;
  bool statementComplete = false;
  bool isStale = false;
  List<LeadInfoEntry> leadInfoEntries = [];

  var lead;
  var leadStatus;
  var leadDocument;
  var displayPhone;
  var repeats = 2;
  var leadEmployee;

  void initState() {
    super.initState();
    isBoarded = false;
    pulseVisibility = true;
    loadLeadData(this.widget.leadId);
    loadStatement();

    pulseController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    pulse = Tween(begin: 2.0, end: 15.0).animate(pulseController)
      ..addStatusListener((status) {
        if (repeats > 0 && statementDirty) {
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

  void openLead(lead) {
    Navigator.popAndPushNamed(context, "/viewlead", arguments: {
      lead["lead"],
    });
  }

  Future<void> checkIfBoarded(status) async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query LEAD_STATUS {
        lead_status {
          lead_status
          text
        }
      }

    """),
      fetchPolicy: FetchPolicy.noCache,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    );

    final result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        result.data["lead_status"].forEach((item) {
          if (item["text"] == "Boarded") {
            leadStatus = item["lead_status"];
          }
        });

        if (leadStatus == status) {
          setState(() {
            isBoarded = true;
          });
        } else {
          setState(() {
            isBoarded = false;
          });
        }
      } else {
        print(new Error());
      }
    }
  }

  Future<void> openStaleModal(lead) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stale Lead'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This lead is stale, would you like to claim it?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                openLead(lead);
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 17, color: Colors.green),
              ),
              onPressed: () async {
                Map data = {
                  "employee": UserService.employee.employee,
                  "is_stale": false
                };

                MutationOptions mutateOptions = MutationOptions(
                  document: gql("""
                      mutation UPDATE_LEAD (\$data: lead_set_input){
                        update_lead_by_pk(pk_columns: {lead: "${lead["lead"]}"}, _set: \$data){
                          lead
                        }
                      }
                  """),
                  fetchPolicy: FetchPolicy.noCache,
                  variables: {"data": data},
                );
                final QueryResult result =
                    await GqlClientFactory().authGqlmutate(mutateOptions);

                if (result.hasException == false) {
                  Fluttertoast.showToast(
                      msg: "Lead Claimed!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.of(context).pop();
                  openLead(lead);
                } else {
                  Fluttertoast.showToast(
                      msg: "Failed to claim lead!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadStatement() async {
    lead = this.widget.leadId;

    try {
      QueryOptions options = QueryOptions(
        document: gql("""
        query GET_STATEMENT {
          statement(where: {lead: {_eq: "${this.widget.leadId}"}, is_active: {_eq: true}}) {
            statement
            document
            is_active
            leadByLead{
              document
            }
          }
        }
      """),
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result.hasException == false) {
        if (result.data != null) {
          if (result.data["statement"][0]["document"] != null) {
            if (result.data["statement"][0]["document"]["emailSent"] != null) {
              setState(
                () {
                  statementComplete = true;
                },
              );
            } else {
              setState(
                () {
                  statementDirty = true;
                },
              );
            }
          } else {
            setState(
              () {
                statementDirty = true;
              },
            );
          }
        }
      }
    } catch (err) {
      print(err);
    }
    if (statementDirty) {
      pulseController.forward();
    }
  }

  Future<void> loadLeadData(leadId) async {
    QueryOptions options = QueryOptions(
      document: gql("""
        query GET_LEAD(\$lead: uuid!) {
          lead_by_pk(lead: \$lead) {
            lead
            document
            is_stale
            lead_status
            employee: employeeByEmployee {
              employee
              fullName: document(path: "fullName")
            }
          }
        }
    """),
      variables: {"lead": this.widget.leadId},
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result.hasException == false) {
      var body = result.data["lead_by_pk"];
      isStale = result.data["lead_by_pk"]["is_stale"];
      if (body != null) {
        var bodyDecoded = body;
        checkIfBoarded(bodyDecoded["lead_status"]);

        setState(
          () {
            lead = bodyDecoded;
            leadEmployee = bodyDecoded["employee"]["employee"];
            leadDocument = bodyDecoded["document"];
            firstNameController.text = leadDocument["firstName"];
          },
        );
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
        "address2": "",
        "city": "",
        "state": "",
        "zipCode": "",
      };
    }
    if (leadDocument["address"] != null && leadDocument["address"] != "") {
      if (leadDocument["address2"] != null && leadDocument["address2"] != "") {
        addressText = leadDocument["address"] +
            " " +
            leadDocument["address2"] +
            ", " +
            leadDocument["city"] +
            ", " +
            leadDocument["state"] +
            " " +
            leadDocument["zipCode"];
      } else {
        addressText = leadDocument["address"] +
                ", " +
                leadDocument["city"] +
                ", " +
                leadDocument["state"] +
                " " +
                leadDocument["zipCode"] ??
            " ";
      }
      businessAddress["address"] = leadDocument["address"];
      businessAddress["city"] = leadDocument["city"];
      businessAddress["state"] = leadDocument["state"];
      businessAddress["zipcode"] = leadDocument["zipCode"];
    }
    if (leadDocument["phoneNumber"] != null ||
        leadDocument["phoneNumber"] != "") {
      setState(
        () {
          phoneNumberController.updateText(leadDocument["phoneNumber"]);
        },
      );
    }
  }

  Future<void> updateLead(leadId) async {
    String rawNumber = phoneNumberController.text;
    var filteredNumber = rawNumber.replaceAll(RegExp("[^0-9]"), "");

    Map data = {
      "employee": leadEmployee,
      "is_stale": false,
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

    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
        mutation UPDATE_LEAD (\$data: lead_set_input){
          update_lead_by_pk(pk_columns: {lead: "$leadId"}, _set: \$data){
            lead
          }
        }
      """),
      fetchPolicy: FetchPolicy.noCache,
      variables: {"data": data},
    );

    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);

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
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 17),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
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
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: Text('Lead Actions'),
          content: SingleChildScrollView(
            child: Container(
              child: ListBody(
                children: <Widget>[
                  Card(
                    shape: RoundedRectangleBorder(
                      side: new BorderSide(color: Colors.red[200], width: 2.0),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Colors.red),
              ),
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
    if (statementDirty) {
      setState(
        () {
          button = CircleAvatar(
            radius: 25,
            backgroundColor: Colors.red,
            child: IconButton(
              icon: Icon(Icons.priority_high, color: Colors.white),
              onPressed: () {},
            ),
          );
        },
      );
    } else {
      setState(
        () {
          button = IconButton(
            icon: Icon(Icons.done, color: Colors.white),
            onPressed: () {},
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, "/leads");

        return Future.value(false);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          key: Key("viewTasksAppBar"),
          title: Text(isLoading ? "Loading..." : leadDocument["businessName"]),
          action: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
              child: statementDirty
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
                            icon:
                                Icon(Icons.priority_high, color: Colors.white),
                            onPressed: () {
                              popCheck();
                            },
                          ),
                        ),
                      ),
                    )
                  : Container(),
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
                        isStale
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange[400],
                                    ),
                                    UserService.isAdmin ||
                                            UserService.isSalesManager
                                        ? Text(
                                            "This is a stale lead! Assign it to edit",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.orange[400],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            "This is a stale lead! Claim it to edit",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.orange[400],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ],
                                ),
                              )
                            : isBoarded
                                ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.green[400],
                                        ),
                                        Text(
                                          "This lead is already a merchant!",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green[400],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                        UserService.isAdmin || UserService.isSalesManager
                            ? CustomCard(
                                key: Key("leadEmployee"),
                                title: 'Employee',
                                icon: Icons.person,
                                child: EmployeeDropDown(
                                  value: leadEmployee,
                                  callback: ((val) {
                                    setState(
                                      () {
                                        if (val != null) {
                                          leadEmployee = val;
                                        }
                                      },
                                    );
                                  }),
                                ),
                              )
                            : Container(),
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
                                businessNameController,
                                (val) {
                                  if (val.isEmpty) {
                                    return 'Please enter a business name';
                                  }
                                  return null;
                                },
                                editable: !isStale && !isBoarded,
                              ),
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
                                        child: addressText == null
                                            ? Text("")
                                            : Text(addressText),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                firstNameController,
                                (val) {
                                  if (val.isEmpty) {
                                    return 'Please enter a contact first name';
                                  }
                                  return null;
                                },
                                editable: !isStale && !isBoarded,
                              ),
                              getInfoRow(
                                "Last Name",
                                leadDocument["lastName"],
                                lastNameController,
                                editable: !isStale && !isBoarded,
                              ),
                              validatorRow(
                                "Email Address",
                                leadDocument["emailAddr"],
                                emailAddrController,
                                (value) {
                                  if (value.isNotEmpty &&
                                      !value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                editable: !isStale && !isBoarded,
                              ),
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
                                          child: !isStale && !isBoarded
                                              ? TextField(
                                                  controller:
                                                      phoneNumberController,
                                                )
                                              : Text(
                                                  phoneNumberController.text)),
                                    ],
                                  ),
                                ),
                              ),
                              isStale ? Container() : Divider(),
                              isStale
                                  ? Container()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: UniversalStyles
                                                    .actionColor),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.mail,
                                                    color: Colors.white),
                                                Text(
                                                  "Email",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            onPressed: () {
                                              if (emailAddrController.text !=
                                                      null &&
                                                  emailAddrController.text !=
                                                      "") {
                                                var launchURL1 =
                                                    'mailto:${emailAddrController.text}?subject=Followup about ${businessNameController.text}';
                                                launch(launchURL1);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: "No email specified!",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[600],
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: UniversalStyles
                                                    .actionColor),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.call,
                                                    color: Colors.white),
                                                Text(
                                                  "Call",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            onPressed: () {
                                              if (phoneNumberController.text !=
                                                      null &&
                                                  phoneNumberController.text !=
                                                      "") {
                                                var launchURL2 =
                                                    'tel:${phoneNumberController.text}';
                                                launch(launchURL2);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "No phone number specified!",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[600],
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: UniversalStyles
                                                    .actionColor),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.map,
                                                    color: Colors.white),
                                                Text(
                                                  "Map",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            onPressed: () {
                                              if (businessAddress["address"] !=
                                                  null) {
                                                addressText = businessAddress[
                                                        "address"] +
                                                    ", " +
                                                    businessAddress["city"] +
                                                    ", " +
                                                    businessAddress["state"] +
                                                    ", " +
                                                    businessAddress["zipcode"];
                                                MapsLauncher.launchQuery(
                                                    addressText);
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg: "No address specified!",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      Colors.grey[600],
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
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
                                leadSourceController,
                                editable: !isStale && !isBoarded,
                              ),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("leadTasks"),
                          title: 'Tasks',
                          icon: Icons.playlist_add_check,
                          child: Column(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      if (!isStale) {
                                        Navigator.pushNamed(
                                          context,
                                          "/leadtasks",
                                          arguments: lead,
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Claim this lead to see tasks!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.grey[600],
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Tasks'),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("leadNotes"),
                          title: 'Notes',
                          icon: Icons.note,
                          child: Column(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      if (!isStale) {
                                        Navigator.pushNamed(
                                            context, "/leadnotes",
                                            arguments: lead);
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Claim this lead to see notes!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.grey[600],
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Notes'),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CustomCard(
                          key: Key("leadUploads"),
                          title: 'Uploads',
                          icon: Icons.file_upload,
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  if (!isStale) {
                                    Navigator.pushNamed(
                                      context,
                                      "/statementuploads",
                                      arguments: lead,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Claim this lead to see statements!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[600],
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          statementComplete
                                              ? Icon(
                                                  Icons.done,
                                                  color: Colors.green,
                                                )
                                              : Text(""),
                                          statementDirty
                                              ? Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                )
                                              : Text(""),
                                          Text('Statements'),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          child: Container(),
                          padding: EdgeInsets.only(bottom: 80),
                        )
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: isBoarded
            ? Container()
            : isStale && !UserService.isSalesManager && !UserService.isAdmin
                ? FloatingActionButton(
                    onPressed: () async {
                      if (_leadFormKey.currentState.validate()) {
                        openStaleModal(lead);
                      }
                    },
                    child: Icon(Icons.how_to_reg),
                  )
                : FloatingActionButton(
                    onPressed: () async {
                      if (_leadFormKey.currentState.validate()) {
                        updateLead(this.widget.leadId);
                      }
                    },
                    child: Icon(Icons.save),
                  ),
      ),
    );
  }

  Widget getInfoRow(label, value, controller, {editable = true}) {
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
              child: !editable
                  ? Text(controller.text)
                  : TextField(
                      onChanged: (s) {},
                      controller: controller,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget validatorRow(label, value, controller, validator, {editable = true}) {
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
              child: !editable
                  ? Text(controller.text)
                  : TextFormField(
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
