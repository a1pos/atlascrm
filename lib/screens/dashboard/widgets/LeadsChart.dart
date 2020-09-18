import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LeadsChart extends StatefulWidget {
  LeadsChart({this.data, this.time});
  final List data;
  final String time;
  @override
  _LeadsChartState createState() => _LeadsChartState();
}

class _LeadsChartState extends State<LeadsChart> {
  var isLoading = true;

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
            SalesPerson(item["fullname"], int.parse(item[this.widget.time])));
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
            path.count > 0 ? '${path.count.toString()}' : '',
      )
    ];
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(0),
      ),
      isLoading
          ? Expanded(
              child: CenteredLoadingSpinner(),
            )
          : Expanded(
              child: charts.BarChart(
                seriesList,
                vertical: false,
                animate: false,
                barRendererDecorator: new charts.BarLabelDecorator<String>(),
              ),
            ),
    ]);
  }
}

class SalesPerson {
  final String person;
  final int count;

  SalesPerson(this.person, this.count);
}
