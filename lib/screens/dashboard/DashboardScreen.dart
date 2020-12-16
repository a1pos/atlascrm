import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/screens/dashboard/widgets/LeadsChart.dart';
import 'package:atlascrm/screens/dashboard/widgets/SalesLeaderboardCards.dart';
import 'package:atlascrm/screens/dashboard/widgets/SalesLeaderboardChart.dart';
import 'package:atlascrm/screens/dashboard/widgets/Tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var leadDropdownValue = "leadcounttoday";
  var leadFilterItems = [
    {"text": "Today", "value": "leadcounttoday"},
    {"text": "This Week", "value": "leadcountweek"},
    {"text": "All Time", "value": "leadcount"}
  ];
  var statsData = [];
  bool isLoading = true;
  bool cardView = true;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(0, 1, 56, 112),
      ),
    );
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // dispose();
        print("dash trying to pop");
        return false;
      },
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          key: Key("dashboardAppBar"),
          title: Text("Dashboard"),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    cardView
                        ? Container(
                            key: Key("dashboardLeaderboardCards"),
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.attach_money,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      "Sales Leaderboard",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    // trailing: IconButton(
                                    //   icon: Icon(
                                    //     Icons.equalizer,
                                    //     color: UniversalStyles.actionColor,
                                    //   ),
                                    //   onPressed: () {
                                    //     setState(() {
                                    //       cardView = false;
                                    //     });
                                    //   },
                                    // )
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.1,
                                      ),
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(15),
                                      child: Container(
                                        height: 370,
                                        child: SalesLeaderboardCards(),
                                      ))
                                ],
                              ),
                            ),
                          )
                        : Container(
                            key: Key("dashboardLeaderboardCards"),
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.attach_money,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      "Sales Leaderboard",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.account_box,
                                      color: UniversalStyles.actionColor,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        cardView = true;
                                      });
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.1,
                                      ),
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(15),
                                      child: Container(
                                        height: 370,
                                        child: SalesLeaderboardChart(),
                                      ))
                                ],
                              ),
                            ),
                          ),

                    CustomCard(
                      key: Key("dashboardTasks"),
                      title: "Tasks",
                      icon: Icons.subject,
                      child: Container(
                        height: 200,
                        child: Tasks(),
                      ),
                    ),
                    CustomCard(
                      key: Key("dashboardCalls"),
                      title: "Leads",
                      icon: Icons.person,
                      child: Container(
                        height: 300,
                        child: LeadsChart(),
                      ),
                    ),
                    // CustomCard(
                    //   key: Key("dashboardCalls"),
                    //   title: "Calls",
                    //   icon: Icons.phone,
                    //   child: Container(
                    //     height: 200,
                    //     child: WeeklyCallsChart(),
                    //   ),
                    // ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
