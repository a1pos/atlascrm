import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SalesLeaderboardChart extends StatefulWidget {
  final dynamic data;

  SalesLeaderboardChart({this.data});

  @override
  _SalesLeaderboardChartState createState() => _SalesLeaderboardChartState();
}

class _SalesLeaderboardChartState extends State<SalesLeaderboardChart> {
  var isLoading = true;

  var seriesList;

  @override
  void initState() {
    super.initState();

    var leaderboardPathData = List<LeaderBoardPath>();

    for (var item in this.widget.data) {
      leaderboardPathData.add(
          LeaderBoardPath(item["fullName"], int.parse(item["agreementcount"])));
    }

    seriesList = [
      charts.Series<LeaderBoardPath, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LeaderBoardPath path, _) => path.person,
        measureFn: (LeaderBoardPath path, _) => path.count,
        data: leaderboardPathData,
        labelAccessorFn: (LeaderBoardPath path, _) =>
            '${path.person}: ${path.count.toString()}',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      vertical: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      animate: false,
    );
  }
}

class LeaderBoardPath {
  final String person;
  final int count;

  LeaderBoardPath(this.person, this.count);
}
