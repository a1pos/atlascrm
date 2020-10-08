import 'package:atlascrm/services/api.dart';
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
  var items;
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
    // this.widget.controller.addListener(
    //     refreshSubscription("statement", this.widget.controller.text, null));
    initSub(typeDropdownValue, weekStart, null);
  }

  int itemTotal = 0;

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

  Future initSub(type, from, to) async {
    var options;
    if (type == null) type = "statement";
    if (from == null) from = weekStart;
    if (to == null) to = today;

    Operation statementOptions =
        Operation(operationName: "GET_STATEMENT_COUNT", documentNode: gql("""
            subscription GET_STATEMENT_COUNT(\$from: timestamptz, \$to: timestamptz) {
      employee(
        where: {
          _and: [
            { document: { _has_key: "displayName" } }
            { roleByRole: { title: { _eq: "sales" } } }
          ]
        }
      ) {
        displayName: document(path: "displayName")
        statements_aggregate(
          where: {
            _and: [
              { created_at: { _gte: \$from } }
              { created_at: { _lte: \$to } }
            ]
          }
        ) {
          aggregate {
            count
          }
        }
      }
    }
    """), variables: {"from": from, "to": to});
    Operation agreementOptions =
        Operation(operationName: "GET_AGREEMENT_COUNT", documentNode: gql("""
       subscription GET_AGREEMENT_COUNT(\$from: timestamptz, \$to: timestamptz) {
      employee(
        where: {
          _and: [
            { document: { _has_key: "displayName" } }
            { roleByRole: { title: { _eq: "sales" } } }
          ]
        }
      ) {
        displayName: document(path: "displayName")
        agreements_aggregate(
          where: {
            _and: [
              { created_at: { _gte: \$from } }
              { created_at: { _lte: \$to } }
            ]
          }
        ) {
          aggregate {
            count
          }
        }
      }
    }
    """), variables: {"from": from, "to": to});

    if (type == "statement") {
      options = statementOptions;
    } else if (type == "agreement") {
      options = agreementOptions;
    }

    var result = client.subscribe(options);
    subscription = result.listen(
      (data) async {
        var incomingData = data.data["employee"];
        if (incomingData != null) {
          if (this.mounted) {
            setState(() {
              graphList = incomingData;
              isLoading = false;
            });
          }
        }
      },
      onError: (error) {
        print(error);

        Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  refreshSubscription() async {
    var from = timeDropdownValue;
    var type = typeDropdownValue;
    var fromVal = today;
    var toVal = today;
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
      initSub(type, fromVal, toVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    itemTotal = 0;
    if (graphList != null) {
      if (graphList.length > 0) {
        var temp1 = List<LeaderboardData>();
        if (typeDropdownValue == "statement") {
          label = "Statements";
        } else if (typeDropdownValue == "agreement") {
          label = "Agreements";
        }
        for (var item in graphList) {
          var count = 0;
          if (typeDropdownValue == "statement") {
            if (item["statements_aggregate"] != null) {
              count = item["statements_aggregate"]["aggregate"]["count"];
            }
          } else if (typeDropdownValue == "agreement") {
            if (item["agreements_aggregate"] != null) {
              count = item["agreements_aggregate"]["aggregate"]["count"];
            }
          }
          temp1.add(LeaderboardData(item["displayName"], count));
          itemTotal += count;
        }
        temp1.sort((a, b) => b.count.compareTo(a.count));

        setState(() {
          leaderboardData = temp1;
          isLoading = false;
        });
      }
    }

    List<charts.Series<LeaderboardData, String>> _displayData() {
      items = leaderboardData;
      return [
        new charts.Series<LeaderboardData, String>(
          id: '$label: $itemTotal',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: items,
          seriesColor: charts.MaterialPalette.indigo.makeShades(2)[1],
          labelAccessorFn: (LeaderboardData path, _) =>
              path.count > 0 ? '${path.count.toString()}' : '',
        ),
      ];
    }

    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: DropdownButton<String>(
              value: typeDropdownValue,
              items: typeFilterItems.map((dynamic item) {
                return DropdownMenuItem<String>(
                  value: item["value"],
                  child: Text(item["text"]),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  isLoading = true;
                  typeDropdownValue = newValue;
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
              child: BarChart(
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

class BarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  BarChart(this.seriesList, {this.animate});

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
        behaviors: [
          charts.SeriesLegend(
              position: charts.BehaviorPosition.bottom,
              horizontalFirst: deviceWidth < 370 ? false : true)
        ],
        barRendererDecorator: new charts.BarLabelDecorator<String>(),
      ),
    );
  }
}
