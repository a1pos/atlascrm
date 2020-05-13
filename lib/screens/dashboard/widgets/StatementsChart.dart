import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class StatementsChart extends StatefulWidget {
  StatementsChart({this.data});
  final List data;
  @override
  _StatementsChartState createState() => _StatementsChartState();
}

class _StatementsChartState extends State<StatementsChart> {
  var isLoading = true;
  final ApiService apiService = ApiService();

  var seriesList;
  var statsData = List<SalesPerson>();

  @override
  void initState() {
    super.initState();

    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (this.widget.data.length > 0) {
      var temp = List<SalesPerson>();
      for (var item in this.widget.data) {
        temp.add(
            SalesPerson(item["fullname"], int.parse(item["statementcount"])));
      }
      setState(() {
        statsData = temp;
        isLoading = false;
      });
    }

    seriesList = [
      charts.Series<SalesPerson, String>(
        id: 'Statements',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (SalesPerson path, _) => path.person,
        measureFn: (SalesPerson path, _) => path.statements,
        data: statsData,
      )
    ];

    return Container(
      child: isLoading
          ? Expanded(
              child: CenteredLoadingSpinner(),
            )
          : charts.BarChart(
              seriesList,
              animate: false,
            ),
    );
  }
}

class SalesPerson {
  final String person;
  final int statements;

  SalesPerson(this.person, this.statements);
}
