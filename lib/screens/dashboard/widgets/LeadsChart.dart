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

  var filterItems = [
    {"text": "Today", "value": "leadcounttoday"},
    {"text": "This Week", "value": "leadcountweek"},
    {"text": "All Time", "value": "leadcount"}
  ];

  @override
  void initState() {
    super.initState();

    isLoading = false;
  }

  String dropdownValue = "leadcounttoday";

  @override
  Widget build(BuildContext context) {
    if (this.widget.data.length > 0) {
      var temp = List<SalesPerson>();
      for (var item in this.widget.data) {
        temp.add(SalesPerson(item["fullname"], int.parse(item[dropdownValue])));
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
        child: DropdownButton<String>(
          value: dropdownValue,
          items: filterItems.map((dynamic item) {
            return DropdownMenuItem<String>(
              value: item["value"],
              child: Text(item["text"]),
            );
          }).toList(),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
        ),
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
