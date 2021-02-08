import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class SalesLeaderboardChart extends StatefulWidget {
  SalesLeaderboardChart();
  @override
  _SalesLeaderboardChartState createState() => _SalesLeaderboardChartState();
}

class _SalesLeaderboardChartState extends State<SalesLeaderboardChart> {
  final UserService userService = UserService();

  var isLoading = true;
  var seriesList;
  var leaderboardData = List<LeaderboardData>();
  var statementData = List<LeaderboardData>();
  var agreementData = List<LeaderboardData>();

  var items;
  var statements;
  var agreements;
  var label = "items";

  var timeDropdownValue = "week";
  var timeFilterItems = [
    {"text": "Today", "value": "today"},
    {"text": "Week to Date", "value": "week"},
    {"text": "Month to Date", "value": "month"},
    {"text": "Year to Date", "value": "year"}
  ];

  var typeDropdownValue = "statement";
  var typeFilterItems = [
    {"text": "Statements", "value": "statement"},
    {"text": "Agreements", "value": "agreement"}
  ];
  @override
  void initState() {
    super.initState();
    initSub(weekStart);
  }

  @override
  void dispose() async {
    super.dispose();
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
  }

  int itemTotal = 0;
  int statementTotal = 0;
  int agreementTotal = 0;

  var graphList;

  var dateFrom;
  var dateTo;

  final today = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  final weekStart = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: DateTime.now().weekday)))
      .toString();
  final monthStart = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1))
      .toString();
  final yearStart = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, 1, 1))
      .toString();

  var subscription;

  Future initSub(from) async {
    if (from == null) from = weekStart;

    Operation options =
        Operation(operationName: "GET_LEADERBOARD_COUNT", documentNode: gql("""
  subscription GET_LEADERBOARD_COUNT(\$from: timestamptz) {
  employee(where: {_and: [{document: {_has_key: "displayName"}}, {roleByRole: {title: {_eq: "sales"}}}]}) {
    displayName: document(path: "displayName")
    role
    agreements_aggregate(where: {_and: [{created_at: {_gte: \$from}}]}) {
      aggregate {
        count
      }
    }
    statements_aggregate(where: {_and: [{created_at: {_gte: \$from}}]}) {
      aggregate {
        count
      }
    }
  }
}
    """), variables: {"from": from});

    subscription = await GqlClientFactory().authGqlsubscribe(options, (data) {
      var incomingData = data.data["employee"];
      if (incomingData != null) {
        if (this.mounted) {
          setState(() {
            statementTotal = 0;
            agreementTotal = 0;
            graphList = incomingData;
            isLoading = false;
          });
        }
      }
    }, (error) {}, () => refreshSubscription());

    // subscription = result.listen(
    //   (data) async {
    //     var incomingData = data.data["employee"];
    //     if (incomingData != null) {
    //       if (this.mounted) {
    //         setState(() {
    //           statementTotal = 0;
    //           agreementTotal = 0;
    //           graphList = incomingData;
    //           isLoading = false;
    //         });
    //       }
    //     }
    //   },
    //   onError: (error) async {
    //     var errMsg = error.payload["message"];
    //     print(errMsg);
    //     if (errMsg.contains("JWTExpired")) {
    //       await refreshSubscription();
    //     } else {
    //       Fluttertoast.showToast(
    //           msg: errMsg,
    //           toastLength: Toast.LENGTH_LONG,
    //           gravity: ToastGravity.BOTTOM,
    //           backgroundColor: Colors.grey[600],
    //           textColor: Colors.white,
    //           fontSize: 16.0);
    //     }
    //   },
    // );
  }

  refreshSubscription() async {
    var from = timeDropdownValue;
    var fromVal = today;
    switch (from) {
      case "today":
        {
          fromVal = today;
        }
        break;

      case "week":
        {
          fromVal = weekStart;
        }
        break;
      case "month":
        {
          fromVal = monthStart;
        }
        break;
      case "year":
        {
          fromVal = yearStart;
        }
        break;
    }
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initSub(fromVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    itemTotal = 0;

    if (graphList != null) {
      if (graphList.length > 0) {
        var graphTemp = [];
        var graphFinal = [];
        bool userIncluded = false;

        for (var employee in graphList) {
          graphTemp.add({
            "displayName": employee["displayName"],
            "statementCount": employee["statements_aggregate"]["aggregate"]
                ["count"],
            "agreementCount": employee["agreements_aggregate"]["aggregate"]
                ["count"]
          });
        }

        var temp1 = List<LeaderboardData>();
        var temp2 = List<LeaderboardData>();

        // if (typeDropdownValue == "statement") {
        //   label = "Statements";
        // } else if (typeDropdownValue == "agreement") {
        //   label = "Agreements";
        // }
        graphTemp
            .sort((a, b) => b["statementCount"].compareTo(a["statementCount"]));
        graphTemp
            .sort((a, b) => b["agreementCount"].compareTo(a["agreementCount"]));

        for (var i = 0; i < 5; i++) {
          if (UserService.employee.role == "sales") {
            if (graphTemp[i]["displayName"] ==
                UserService.employee.document["displayName"]) {
              setState(() {
                userIncluded = true;
              });
            }
          }
          graphFinal.add(graphTemp[i]);
        }
        if (UserService.employee.role == "sales" && !userIncluded) {
          graphFinal.removeLast();
          var userIndex = graphTemp.indexWhere((item) =>
              item["displayName"] ==
              UserService.employee.document["displayName"]);
          graphFinal.add(graphTemp[userIndex]);
        }

        for (var item in graphFinal) {
          var count1 = 0;
          var count2 = 0;

          count1 = item["statementCount"];
          count2 = item["agreementCount"];

          temp1.add(LeaderboardData(item["displayName"], count1));
          statementTotal += count1;
          temp2.add(LeaderboardData(item["displayName"], count2));
          agreementTotal += count2;
        }
        // temp1.sort((a, b) => b.count.compareTo(a.count));

        setState(() {
          statementData = temp1;
          agreementData = temp2;
          isLoading = false;
        });
      }
    }

    List<charts.Series<LeaderboardData, String>> _displayData() {
      statements = statementData;
      agreements = agreementData;
      items = leaderboardData;
      return [
        new charts.Series<LeaderboardData, String>(
          id: 'Statements: $statementTotal',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: statements,
          seriesColor: charts.MaterialPalette.indigo.makeShades(2)[1],
          labelAccessorFn: (LeaderboardData path, _) =>
              path.count > 0 ? '${path.count.toString()}' : '',
        ),
        new charts.Series<LeaderboardData, String>(
          id: 'Agreements: $agreementTotal',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: agreements,
          seriesColor: charts.MaterialPalette.purple.makeShades(7)[1],
          labelAccessorFn: (LeaderboardData path, _) =>
              path.count > 0 ? '${path.count.toString()}' : '',
        ),
      ];
    }

    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: DropdownButton<String>(
              value: timeDropdownValue,
              items: timeFilterItems.map((dynamic item) {
                return DropdownMenuItem<String>(
                  value: item["value"],
                  child: Text(item["text"]),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  isLoading = true;
                  timeDropdownValue = newValue;
                  refreshSubscription();
                });
              },
            ),
          ),
        ],
      ),
      isLoading
          ? Expanded(
              child: CenteredLoadingSpinner(),
            )
          : Expanded(
              child: GroupedBarChart(
                _displayData(),
                animate: true,
              ),
            ),
    ]);
  }
}

class LeaderboardData {
  final String person;
  final int count;

  LeaderboardData(this.person, this.count);
}

class GroupedBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GroupedBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;

    queryData = MediaQuery.of(context);
    var deviceWidth = queryData.size.width;
    return SizedBox(
      height: 250,
      child: charts.BarChart(
        seriesList,
        animate: animate,
        vertical: false,
        barGroupingType: charts.BarGroupingType.grouped,
        behaviors: [
          charts.SeriesLegend(
              outsideJustification: charts.OutsideJustification.start,
              position: charts.BehaviorPosition.bottom,
              horizontalFirst: deviceWidth < 370 ? false : true)
        ],
        barRendererDecorator: new charts.BarLabelDecorator<String>(),
      ),
    );
  }
}
