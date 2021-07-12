import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class LeadsChart extends StatefulWidget {
  LeadsChart({Key key}) : super(key: key);

  @override
  LeadsChartState createState() => LeadsChartState();
}

class LeadsChartState extends State<LeadsChart> {
  final UserService userService = UserService();

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output: CustomOuput(),
  );

  bool isLoading = true;

  List<LeaderboardData> statementData = [];
  List<LeaderboardData> agreementData = [];

  var seriesList;
  var statements;
  var label = "Leads";

  var timeDropdownValue = "week";
  var timeFilterItems = [
    {"text": "Today", "value": "today"},
    {"text": "Week to Date", "value": "week"},
    {"text": "Month to Date", "value": "month"},
    {"text": "Year to Date", "value": "year"}
  ];

  @override
  void initState() {
    super.initState();

    initSub(weekStart, null);
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

  Future initSub(from, to) async {
    if (from == null) from = weekStart;
    if (to == null) to = today;

    logger.i("Leads chart parameters set to: " + from + " to " + to);
    SubscriptionOptions leadOptions = SubscriptionOptions(
      operationName: "GET_LEAD_COUNT",
      document: gql("""
    subscription GET_LEAD_COUNT(\$from: timestamptz) {
      employee(
        where: {
          _and: [
            { document: { _has_key: "shortName" } }
            { roleByRole: { title: { _eq: "sales" } } }
            { is_active: { _eq: true } }
          ]
        }
      ) {
        displayName: document(path: "shortName")
        leads_aggregate (where: {_and: [{created_at: {_gte: \$from}}]}){
          aggregate {
            count
          }
        }
      }
    }

    """),
      fetchPolicy: FetchPolicy.noCache,
      variables: {"from": from},
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      leadOptions,
      (data) {
        var incomingData = data.data["employee"];
        if (incomingData != null) {
          if (this.mounted) {
            logger.i("Leads chart widget initialized");
            setState(() {
              graphList = incomingData;
              isLoading = false;
            });
          }
        }
      },
      (error) {},
      () => refreshSub(),
    );
  }

  void parentRefresh() async {
    setState(() {
      timeDropdownValue = "week";
    });

    refreshSub();
  }

  refreshSub() async {
    var from = timeDropdownValue;
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
      logger.i("Leads chart subscription refreshed. Params set to: " +
          from +
          " " +
          fromVal +
          " to " +
          toVal);
      initSub(fromVal, toVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    itemTotal = 0;
    if (graphList != null) {
      if (graphList.length > 0) {
        List<LeaderboardData> temp1 = [];

        for (var item in graphList) {
          var count = 0;

          if (item["leads_aggregate"] != null) {
            count = item["leads_aggregate"]["aggregate"]["count"];
          }

          temp1.add(LeaderboardData(item["displayName"], count));
          itemTotal += count;
        }
        temp1.sort((a, b) => b.count.compareTo(a.count));

        setState(() {
          statementData = temp1;
          isLoading = false;
        });
      }
    }

    List<charts.Series<LeaderboardData, String>> _displayData() {
      statements = statementData;
      return [
        new charts.Series<LeaderboardData, String>(
          id: '$label: $itemTotal',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: statements,
          seriesColor: charts.MaterialPalette.indigo.makeShades(2)[1],
          labelAccessorFn: (LeaderboardData path, _) =>
              path.count > 0 ? '${path.count.toString()}' : '',
        ),
      ];
    }

    return Column(
      children: <Widget>[
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
                    logger.i("Leads chart parameters changed: " + newValue);
                    isLoading = true;
                    timeDropdownValue = newValue;
                    refreshSub();
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
      ],
    );
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
            horizontalFirst: deviceWidth < 370 ? false : true,
          )
        ],
        barRendererDecorator: new charts.BarLabelDecorator<String>(),
      ),
    );
  }
}
