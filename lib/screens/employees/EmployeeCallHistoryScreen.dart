import 'dart:convert';

import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeCallHistoryScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String employeeId;

  EmployeeCallHistoryScreen(this.employeeId);

  @override
  _EmployeeCallHistoryScreenState createState() =>
      _EmployeeCallHistoryScreenState();
}

class _EmployeeCallHistoryScreenState extends State<EmployeeCallHistoryScreen> {
  var isLoading = true;
  var calls = [];

  @override
  void initState() {
    super.initState();

    initCallHistory();
  }

  Future<void> initCallHistory() async {
    var callHistoryResponse = await this.widget.apiService.authGet(
        context, "/employees/calllog/history/" + this.widget.employeeId);
    if (callHistoryResponse.statusCode == 200) {
      setState(() {
        calls = callHistoryResponse.data;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: Key("callHistoryAppBar"),
        title: Text(
          isLoading ? "Loading..." : "Call History",
        ),
      ),
      body: isLoading
          ? CenteredClearLoadingScreen()
          : calls.length == 0
              ? Empty("No calls")
              : Container(
                  child: ListView(
                    children: calls.map((call) {
                      var epoch = call["document"]["callDate"];

                      var lastCheckinTime =
                          new DateTime.fromMillisecondsSinceEpoch(
                              int.parse(epoch));

                      var dateTime = lastCheckinTime;
                      var formatter = DateFormat.yMd().add_jm();
                      String datetimeFmt = formatter.format(dateTime.toLocal());

                      var callType = call["document"]["callType"];
                      var phoneNumber = call["document"]["phoneNumber"];
                      var duration = call["document"]["duration"] ?? "N/A";
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "$callType",
                                      style: TextStyle(),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "$datetimeFmt",
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Phone Number: $phoneNumber"),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text("Duration(s): $duration"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
