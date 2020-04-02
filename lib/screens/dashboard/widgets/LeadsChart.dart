import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LeadsChart extends StatefulWidget {
  final dynamic data;

  LeadsChart({this.data});

  @override
  _LeadsChartState createState() => _LeadsChartState();
}

class _LeadsChartState extends State<LeadsChart> {
  var isLoading = true;
  final ApiService apiService = ApiService();

  var seriesList;

  @override
  void initState() {
    super.initState();

    seriesList = [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: [
          OrdinalSales('2014', 5),
          OrdinalSales('2015', 25),
          OrdinalSales('2016', 100),
          OrdinalSales('2017', 75),
        ],
      )
    ];

    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
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

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
