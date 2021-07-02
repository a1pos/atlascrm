import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/CustomCard.dart';
import 'package:round2crm/components/shared/CustomDrawer.dart';
import 'package:round2crm/components/shared/AppVersion.dart';
import 'package:round2crm/screens/dashboard/widgets/Installs.dart';
import 'package:round2crm/screens/dashboard/widgets/LeadsChart.dart';
import 'package:round2crm/screens/dashboard/widgets/SalesLeaderboardCards.dart';
import 'package:round2crm/screens/dashboard/widgets/Tasks.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<SalesLeaderboardCardsState> _salesLeaderboardCardsState =
      GlobalKey<SalesLeaderboardCardsState>();

  final GlobalKey<LeadsChartState> _leadsChartState =
      GlobalKey<LeadsChartState>();

  final GlobalKey<TasksState> _tasksState = GlobalKey<TasksState>();
  final GlobalKey<InstallsState> _installsState = GlobalKey<InstallsState>();

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output:
  );

  bool isLoading = true;

  var currentDate;

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

  getCurrentDateTime() {
    currentDate = DateFormat.yMd().add_jm().format(DateTime.now()).toString();

    return currentDate;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(
                Duration(seconds: 1),
                () {
                  _salesLeaderboardCardsState.currentState.refreshSub();
                  _leadsChartState.currentState.parentRefresh();
                  _tasksState.currentState.refreshSub();

                  if (UserService.isTech ||
                      UserService.isCorporateTech ||
                      UserService.isAdmin) {
                    _installsState.currentState.refreshSub();
                  }

                  currentDate = getCurrentDateTime();

                  logger.i("Refresh completed at " + currentDate);
                  Fluttertoast.showToast(
                    msg: "Refresh completed at " + currentDate,
                    toastLength: Toast.LENGTH_LONG,
                  );
                },
              );
            },
            child: DashboardCards(
              keys: {
                "SalesLeaderboardCards": _salesLeaderboardCardsState,
                "LeadsChart": _leadsChartState,
                "Tasks": _tasksState,
                "Installs": _installsState
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardCards extends StatelessWidget {
  final Map<String, Key> keys;

  DashboardCards({this.keys});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
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
                          child: SalesLeaderboardCards(
                            key: keys["SalesLeaderboardCards"],
                          ),
                        ),
                      )
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
                  child: Tasks(
                    key: keys["Tasks"],
                  ),
                ),
              ),
              CustomCard(
                key: Key("dashboardLeads"),
                title: "Leads",
                icon: Icons.person,
                child: Container(
                  height: 300,
                  child: LeadsChart(
                    key: keys["LeadsChart"],
                  ),
                ),
              ),
              UserService.isAdmin ||
                      UserService.isTech ||
                      UserService.isCorporateTech
                  ? CustomCard(
                      key: Key("Installs"),
                      title: "Installs",
                      icon: Icons.devices,
                      child: Container(
                        height: 200,
                        child: Installs(
                          key: keys["Installs"],
                        ),
                      ),
                    )
                  : Container(),
              Align(alignment: Alignment.center, child: AppVersion()),
            ],
          )
        ],
      ),
    );
  }
}
