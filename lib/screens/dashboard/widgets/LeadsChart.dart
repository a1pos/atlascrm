import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LeadsChart extends StatefulWidget {
  LeadsChart({this.data});
  final List data;
  @override
  _LeadsChartState createState() => _LeadsChartState();
}

class _LeadsChartState extends State<LeadsChart> {
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
        temp.add(SalesPerson(item["fullname"], int.parse(item["leadcount"])));
      }
      setState(() {
        statsData = temp;
        isLoading = false;
      });
    }
    seriesList = [
      charts.Series<SalesPerson, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (SalesPerson sales, _) => sales.year,
        measureFn: (SalesPerson sales, _) => sales.sales,
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
  final String year;
  final int sales;

  SalesPerson(this.year, this.sales);
}
