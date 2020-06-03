import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';

class SalesLeaderboardChart extends StatefulWidget {
  SalesLeaderboardChart({this.data});
  final List data;
  @override
  _SalesLeaderboardChartState createState() => _SalesLeaderboardChartState();
}

class _SalesLeaderboardChartState extends State<SalesLeaderboardChart> {
  final ApiService apiService = ApiService();
  final UserService userService = UserService();

  var isLoading = true;

  var seriesList;
  var statementData = List<LeaderboardData>();
  var agreementData = List<LeaderboardData>();
  var statements;
  var agreements;

  @override
  void initState() {
    super.initState();

    isLoading = false;
  }

  int agreementTotal = 0;
  int statementTotal = 0;

  Future<void> addStatement(employeeId) async {
    try {
      var resp = await apiService.authPost(
          context,
          "/employees/$employeeId/statements",
          {"leadId": "00000000-0000-0000-0000-000000000000"});
      if (resp != null) {
        if (resp.statusCode == 200) {
          var tasksArrDecoded = resp.data;
          if (tasksArrDecoded != null) {
            Fluttertoast.showToast(
                msg: "Added statement",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
          }
        } else {
          throw new Error();
        }
      } else {
        throw new Error();
      }
    } catch (err) {
      print(err);

      Fluttertoast.showToast(
          msg: "Failed to add statement for employee!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

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
      statements = statementData;
      agreements = agreementData;
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
