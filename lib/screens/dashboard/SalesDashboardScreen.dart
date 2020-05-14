import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/Spinner.dart';
import 'package:atlascrm/screens/dashboard/widgets/SalesLeaderboardChart.dart';
import 'package:atlascrm/screens/dashboard/widgets/Tasks.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:atlascrm/screens/dashboard/widgets/StatementsChart.dart';
import 'package:atlascrm/screens/dashboard/widgets/LeadsChart.dart';

class SalesDashboardScreen extends StatefulWidget {
  @override
  _SalesDashboardScreenState createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  var isLoading = true;
  var statsData = [];
  final ApiService apiService = ApiService();

  var leaderboardData = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(0, 1, 56, 112),
      ),
    );

    initStatistics();
  }

  Future<void> initStatistics() async {
    try {
      var resp = await apiService.authGet(context, "/employee/statistics");
      if (resp != null) {
        if (resp.statusCode == 200) {
          var statsArrDecoded = resp.data;
          if (statsArrDecoded != null) {
            var statsArr = List.from(statsArrDecoded);
            setState(() {
              statsData = statsArr;
              isLoading = false;
            });
          }
        }
      }
    } catch (err) {
      print(err);
    }
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
                    key: Key("salesLeaderboard1"),
                    title: "Sales Leaderboard",
                    icon: Icons.attach_money,
                    child: Container(
                      height: 200,
                      child: SalesLeaderboardChart(data: statsData),
                    ),
                  ),
                  CustomCard(
                    key: Key("salesLeaderboard2"),
                    title: "Tasks",
                    icon: Icons.subject,
                    child: Container(
                      height: 200,
                      child: Tasks(),
                    ),
                  ),
                  // CustomCard(
                  //   key: Key("adminLeaderboard2"),
                  //   title: "Statements",
                  //   icon: Icons.subject,
                  //   child: Container(
                  //     height: 200,
                  //     child: StatementsChart(data: statsData),
                  //   ),
                  // ),
                  CustomCard(
                    key: Key("adminLeaderboard4"),
                    title: "Leads",
                    icon: Icons.person,
                    child: Container(
                      height: 200,
                      child: LeadsChart(data: statsData),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
