import 'dart:developer';

import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/models/Lead.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';

import 'LeadStepper.dart';

class LeadsScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  _LeadsScreenState createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  var leads = [];
  var leadsFull = [];

  var columns = [];

  var isLoading = true;
  var isEmpty = true;

  @override
  void initState() {
    super.initState();

    initLeadsData();
  }

  Future<void> initLeadsData() async {
    try {
      var endpoint = UserService.isAdmin
          ? "/lead"
          : "/employee/${UserService.employee.employee}/lead";
      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var leadsArrDecoded = resp.data;
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                leads = leadsArr;
                leadsFull = leadsArr;
              });
            } else {
              setState(() {
                isEmpty = true;
                isLoading = false;
                leadsArr = [];
                leadsFull = [];
              });
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      log(err);
    }
  }

  void openAddLeadForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Lead'),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: LeadStepper(
              successCallback: initLeadsData,
            ),
          ),
        );
      },
    );
  }

  void openLead(lead) {
    Navigator.pushNamed(context, "/viewlead", arguments: lead["lead"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("leadsScreenAppBar"),
        title: Text("Leads"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            isLoading
                ? CenteredLoadingSpinner()
                : Container(
                    child: Expanded(
                      child: getDataTable(),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddLeadForm,
        backgroundColor: Color.fromARGB(500, 1, 224, 143),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        splashColor: Colors.white,
      ),
    );
  }

  Widget getDataTable() {
    return isEmpty
        ? Empty("No leads found")
        : Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Search Leads",
                    ),
                    onChanged: (value) {
                      var filtered = leadsFull.where((e) {
                        String firstName = e["document"]["firstName"];
                        String lastName = e["document"]["lastName"];
                        String businessName = e["document"]["businessName"];
                        return firstName
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            lastName
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            businessName
                                .toLowerCase()
                                .contains(value.toLowerCase());
                      }).toList();

                      setState(() {
                        leads = filtered.toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: ListView(
                    children: leads.map((lead) {
                      var fullName = lead["document"]["firstName"] +
                          " " +
                          lead["document"]["lastName"];
                      return GestureDetector(
                        onTap: () {
                          openLead(lead);
                        },
                        child: CustomCard(
                          title: lead["document"]["businessName"],
                          icon: Icons.arrow_forward_ios,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      'Business:',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      'Full Name:',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        lead["document"]["businessName"],
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        '$fullName',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }
}
