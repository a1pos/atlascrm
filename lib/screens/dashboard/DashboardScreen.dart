import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/screens/dashboard/widgets/LeadsChart.dart';
import 'package:atlascrm/screens/dashboard/widgets/SalesLeaderboardChart.dart';
import 'package:atlascrm/screens/dashboard/widgets/StatementsChart.dart';
import 'package:atlascrm/screens/dashboard/widgets/Tasks.dart';
import 'package:atlascrm/screens/dashboard/widgets/WeeklyCallsChart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';

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
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(0, 1, 56, 112),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  CustomCard(
                    key: Key("dashboardLeaderboard"),
                    title: "Sales Leaderboard",
                    icon: Icons.attach_money,
                    child: Container(
                      height: 300,
                      child: SalesLeaderboardChart(),
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
    );
  }
}
