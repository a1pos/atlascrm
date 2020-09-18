import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class WeeklyCallsChart extends StatefulWidget {
  @override
  _WeeklyCallsChartState createState() => _WeeklyCallsChartState();
}

class _WeeklyCallsChartState extends State<WeeklyCallsChart> {
  var isLoading = true;

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
          OrdinalSales('Oh', 5),
          OrdinalSales('Jeez', 25),
          OrdinalSales('Aw', 100),
          OrdinalSales('Man', 75),
        ],
      )
    ];

    // getWeeklyCalls();

    isLoading = false;
  }

  Future<void> getWeeklyCalls() async {
    var resp;
    //REPLACE WITH GRAPHQL
    // var resp = await apiService.authGet(context,
    //     "/employees/statistics/weeklycalls/${UserService.employee.employee}");
    if (resp != null) {
      if (resp.statusCode == 200) {
        var employeeArrDecoded = resp.data;
        if (employeeArrDecoded != null) {
          var employeeArr = List.from(employeeArrDecoded);
          if (employeeArr.length > 0) {
            setState(() {
              seriesList = [
                charts.Series<OrdinalSales, String>(
                  id: 'Sales',
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (OrdinalSales sales, _) => sales.year,
                  measureFn: (OrdinalSales sales, _) => sales.sales,
                  data: [],
                )
              ];
            });
          } else {
            setState(() {
              seriesList = [
                charts.Series<OrdinalSales, String>(
                  id: 'Sales',
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (OrdinalSales sales, _) => sales.year,
                  measureFn: (OrdinalSales sales, _) => sales.sales,
                  data: [],
                )
              ];
            });
          }
        }
      } else {
        setState(() {
          seriesList = [
            charts.Series<OrdinalSales, String>(
              id: 'Sales',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (OrdinalSales sales, _) => sales.year,
              measureFn: (OrdinalSales sales, _) => sales.sales,
              data: [],
            )
          ];
        });
      }
    }
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
