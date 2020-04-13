import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/Spinner.dart';
import 'package:atlascrm/screens/dashboard/widgets/SalesLeaderboardChart.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SalesDashboardScreen extends StatefulWidget {
  @override
  _SalesDashboardScreenState createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  var isLoading = true;

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

    // initStatistics();
  }

  // Future<void> initStatistics() async {
  //   try {
  //     var resp = await apiService.authGet(context, "/employees/statistics");
  //     if (resp != null) {
  //       if (resp.statusCode == 200) {
  //         var statsArrDecoded = resp.data;
  //         if (statsArrDecoded != null) {
  //           var statsArr = List.from(statsArrDecoded);
  //           if (statsArr.length > 0) {
  //             var temp = [];
  //             for (var item in statsArr) {
  //               temp.add({
  //                 "fullName": item["fullname"],
  //                 "agreementcount": item["agreementcount"]
  //               });
  //             }
  //             setState(() {
  //               leaderboardData = temp;
  //               isLoading = false;
  //             });
  //           }
  //         }
  //       }
  //     }
  //   } catch (err) {
  //     print(err);
  //   }
  // }

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
                      child: isLoading ? Spinner() : SalesLeaderboardChart(),
                    ),
                  ),
                  CustomCard(
                    key: Key("salesLeaderboard2"),
                    title: "Tasks",
                    icon: Icons.track_changes,
                    child: Container(
                      height: 200,
                      child: Spinner(),
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
