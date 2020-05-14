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

  @override
  Widget build(BuildContext context) {
    if (this.widget.data.length > 0) {
      var temp1 = List<LeaderboardData>();
      var temp2 = List<LeaderboardData>();

      for (var item in this.widget.data) {
        temp1.add(LeaderboardData(
            item["fullname"], int.parse(item["statementcount"])));
        temp2.add(LeaderboardData(
            item["fullname"], int.parse(item["agreementcount"])));
      }

      setState(() {
        statementData = temp1;
        agreementData = temp2;
        isLoading = false;
      });
    }

    List<charts.Series<LeaderboardData, String>> _createSampleData() {
      final statements = statementData;
      final agreements = agreementData;

      return [
        new charts.Series<LeaderboardData, String>(
          id: 'Agreements',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: agreements,
        ),
        new charts.Series<LeaderboardData, String>(
          id: 'Statements',
          domainFn: (LeaderboardData sales, _) => sales.person,
          measureFn: (LeaderboardData sales, _) => sales.count,
          data: statements,
        ),
      ];
    }

    return Container(
      child: isLoading
          ? Expanded(
              child: CenteredLoadingSpinner(),
            )
          : GroupedBarChart(
              _createSampleData(),
              animate: true,
            ),
    );
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
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [charts.SeriesLegend()],
    );
  }
}
