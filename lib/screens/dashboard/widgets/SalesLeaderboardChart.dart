import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';

class SalesLeaderboardChart extends StatefulWidget {
  SalesLeaderboardChart({this.data});
  final List data;
  @override
  _SalesLeaderboardChartState createState() => _SalesLeaderboardChartState();
}

class _SalesLeaderboardChartState extends State<SalesLeaderboardChart> {
  var isLoading = true;

  var seriesList;
  var statementData = List<LeaderboardData>();
  var agreementData = List<LeaderboardData>();

  @override
  void initState() {
    super.initState();

    isLoading = false;
  }

  int agreementTotal = 0;
  int statementTotal = 0;

  @override
  Widget build(BuildContext context) {
    agreementTotal = 0;
    statementTotal = 0;
    if (this.widget.data.length > 0) {
      var temp1 = List<LeaderboardData>();
      var temp2 = List<LeaderboardData>();

      for (var item in this.widget.data) {
        temp1.add(LeaderboardData(
            item["fullname"], int.parse(item["statementcount"])));
        temp2.add(LeaderboardData(
            item["fullname"], int.parse(item["agreementcount"])));
        agreementTotal += int.parse(item["agreementcount"]);
        statementTotal += int.parse(item["statementcount"]);
      }

      setState(() {
        statementData = temp1;
        agreementData = temp2;
        isLoading = false;
      });
    }

    List<charts.Series<LeaderboardData, String>> _displayData() {
      final statements = statementData;
      final agreements = agreementData;

      return [
        new charts.Series<LeaderboardData, String>(
          id: 'Agreements: $agreementTotal',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: agreements,
          labelAccessorFn: (LeaderboardData path, _) =>
              path.count > 0 ? '${path.count.toString()}' : '',
        ),
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
              child: GroupedBarChart(
                _displayData(),
                animate: true,
              ),
            ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Text("agreements: $agreementTotal"),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Text("statements: $statementTotal"),
      //     )
      //   ],
      // )
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
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [
        charts.SeriesLegend(horizontalFirst: deviceWidth < 370 ? false : true)
      ],
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
    );
  }
}
