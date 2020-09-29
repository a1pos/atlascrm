import 'package:atlascrm/services/api.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class SalesLeaderboardChart extends StatefulWidget {
  SalesLeaderboardChart({this.data});
  final List data;
  @override
  _SalesLeaderboardChartState createState() => _SalesLeaderboardChartState();
}

class _SalesLeaderboardChartState extends State<SalesLeaderboardChart> {
  final UserService userService = UserService();

  var isLoading = true;

  var seriesList;
  var statementData = List<LeaderboardData>();
  var agreementData = List<LeaderboardData>();
  var statements;
  var agreements;

  @override
  void initState() {
    super.initState();
    initSub(null, yearStart, null);

    isLoading = false;
  }

  int agreementTotal = 0;
  int statementTotal = 0;

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
        Operation(operationName: "GET_STATEMENT_COUNT", documentNode: gql("""
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

  refreshSubscription(type, from, to) {
    subscription.cancel();
    initSub(type, from, to);
  }

  @override
  Widget build(BuildContext context) {
    agreementTotal = 0;
    statementTotal = 0;
    if (graphList.length > 0) {
      var temp1 = List<LeaderboardData>();
      // var temp2 = List<LeaderboardData>();

      for (var item in graphList) {
        var count = item["statements_aggregate"]["aggregate"]["count"];
        temp1.add(LeaderboardData(item["displayName"], count));
        // temp2.add(LeaderboardData(
        //     item["fullname"], int.parse(item["agreementcount"])));
        // agreementTotal += int.parse(item["agreementcount"]);
        statementTotal += count;
      }

      setState(() {
        statementData = temp1;
        // agreementData = temp2;
        isLoading = false;
      });
    }

    List<charts.Series<LeaderboardData, String>> _displayData() {
      statements = statementData;
      agreements = agreementData;
      return [
        // new charts.Series<LeaderboardData, String>(
        //   id: 'Agreements: $agreementTotal',
        //   domainFn: (LeaderboardData sales, _) => sales.person,
        //   measureFn: (LeaderboardData sales, _) => sales.count,
        //   data: agreements,
        //   labelAccessorFn: (LeaderboardData path, _) =>
        //       path.count > 0 ? '${path.count.toString()}' : '',
        // ),
        new charts.Series<LeaderboardData, String>(
          id: 'Statements: $statementTotal',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: statements,
          labelAccessorFn: (LeaderboardData path, _) =>
              path.count > 0 ? '${path.count.toString()}' : '',
        ),
      ];
    }

    return Column(children: <Widget>[
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
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      behaviors: [
        charts.SeriesLegend(horizontalFirst: deviceWidth < 370 ? false : true)
      ],
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
    );
  }
}
