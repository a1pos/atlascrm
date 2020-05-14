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
        domainFn: (SalesPerson path, _) => path.person,
        measureFn: (SalesPerson path, _) => path.count,
        data: statsData,
        labelAccessorFn: (SalesPerson path, _) =>
            '${path.person}: ${path.count.toString()}',
      )
    ];
    return Container(
      child: isLoading
          ? Expanded(
              child: CenteredLoadingSpinner(),
            )
          : charts.BarChart(
              seriesList,
              vertical: false,
              animate: false,
            ),
    );
  }
}

class SalesPerson {
  final String person;
  final int count;

  SalesPerson(this.person, this.count);
}
