import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/api.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class SalesLeaderboardCards extends StatefulWidget {
  SalesLeaderboardCards();
  @override
  _SalesLeaderboardCardsState createState() => _SalesLeaderboardCardsState();
}

class _SalesLeaderboardCardsState extends State<SalesLeaderboardCards> {
  final UserService userService = UserService();
  var currentPage = 1;
  final _pageController = PageController(viewportFraction: .8);
  var isLoading = true;
  var seriesList;

  var items;
  var statements;
  var agreements;
  var label = "items";
  final currencyFmt = new NumberFormat("#,##0", "en_US");
  List starColors = [Colors.yellow[600], Colors.grey[500], Colors.orange[600]];
  var timeDropdownValue = "week";
  var timeFilterItems = [
    {"text": "Today", "value": "today"},
    {"text": "Week to Date", "value": "week"},
    {"text": "Month to Date", "value": "month"},
    {"text": "Year to Date", "value": "year"}
  ];

  var typeDropdownValue = "statement";
  var typeFilterItems = [
    {"text": "Statements", "value": "statement"},
    {"text": "Agreements", "value": "agreement"}
  ];
  @override
  void initState() {
    super.initState();
    initSub();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  var graphList;
  var graphFinal = [];

  var dateFrom;
  var dateTo;

  final today =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + " 11:00";
  final todayEnd =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + " 23:00";
  final weekStart = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: DateTime.now().weekday)))
      .toString();
  final monthStart = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1))
      .toString();
  final yearStart = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, 1, 1))
      .toString();

  var subscription;

  Future initSub() async {
    Operation options = Operation(
        operationName: "GET_CARD_LEADERBOARD_COUNT", documentNode: gql("""
          subscription GET_CARD_LEADERBOARD_COUNT {
            v_leaderboard {
              agreements
              leads
              name
              statements
              stops
              volume
              photourl
            }
          }
        """));

    var result = await authGqlSubscribe(options);
    subscription = result.listen(
      (data) async {
        var incomingData = data.data["v_leaderboard"];
        if (incomingData != null) {
          if (this.mounted) {
            setState(() {
              graphList = incomingData;
              isLoading = false;
            });
          }
        }
      },
      onError: (error) {
        print(error);

        Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  _builder(int index) {
    var employeeImage;
    try {
      employeeImage = Image.network(graphFinal[index]["photoURL"]);
    } catch (err) {
      employeeImage = Image.asset("assets/google_logo.png");
    }
    var employee = graphFinal[index];
    bool tied = false;
    if (index == 0) {
      if (employee["agreements"] == graphFinal[index + 1]["agreements"] &&
          employee["statements"] == graphFinal[index + 1]["statements"] &&
          employee["volume"] == graphFinal[index + 1]["volume"]) {
        tied = true;
      }
    } else if (index == graphFinal.length - 1) {
      if (employee["agreements"] == graphFinal[index - 1]["agreements"] &&
          employee["statements"] == graphFinal[index - 1]["statements"]) {
        tied = true;
      }
    } else if (employee["agreements"] == graphFinal[index - 1]["agreements"] &&
        employee["statements"] == graphFinal[index - 1]["statements"] &&
        employee["volume"] == graphFinal[index + 1]["volume"]) {
      tied = true;
    }

    return Card(
      elevation: 3,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        side: index < 3
            ? tied
                ? BorderSide(color: UniversalStyles.themeColor, width: 3.0)
                : BorderSide(color: starColors[index], width: 3.0)
            : BorderSide(width: 0),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
              title: Text(
                graphFinal[index]["name"],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color.fromRGBO(144, 97, 249, 1)),
              ),
              trailing: index < 3
                  ? tied
                      ? Icon(Icons.swap_vert, color: UniversalStyles.themeColor)
                      : Icon(
                          Icons.star,
                          size: 25,
                          color: starColors[index],
                        )
                  : Text("")),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Stack(
              alignment: Alignment.center,
              overflow: Overflow.visible,
              children: <Widget>[
                // Container(
                //     width: 115,
                //     height: 115,
                //     child: CircularProgressIndicator(
                //       valueColor:
                //           AlwaysStoppedAnimation(Colors.deepPurple[400]),
                //       strokeWidth: 8,
                //       value: graphFinal[index]["agreements"] / 6,
                //     )),
                // Container(
                //     width: 135,
                //     height: 135,
                //     child: CircularProgressIndicator(
                //       valueColor:
                //           AlwaysStoppedAnimation(Colors.deepPurpleAccent[100]),
                //       strokeWidth: 8,
                //       value: graphFinal[index]["statements"] / 10,
                //     )),
                Center(
                  child: Container(
                      child: CircleAvatar(
                    backgroundImage: employeeImage.image,
                    maxRadius: 50,
                  )),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Card(
              elevation: 0,
              color: Color.fromRGBO(237, 235, 254, 1),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Text("Agreements (MTD): ",
                            style: TextStyle(
                                color: Color.fromRGBO(144, 97, 249, 1))),
                        Text(graphFinal[index]["agreements"].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(144, 97, 249, 1))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Container(
                        width: 250,
                        height: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: LinearProgressIndicator(
                            value: graphFinal[index]["agreements"] / 6,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.deepPurple[400]),
                            backgroundColor: Colors.deepPurple[100],
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Text(" Statements (WTD): ",
                            style: TextStyle(
                                color: Color.fromRGBO(144, 97, 249, 1))),
                        Text(graphFinal[index]["statements"].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(144, 97, 249, 1))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                    child: Container(
                        width: 250,
                        height: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: LinearProgressIndicator(
                            value: graphFinal[index]["statements"] / 10,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.deepPurple[400]),
                            backgroundColor: Colors.deepPurple[100],
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Card(
              elevation: 0,
              color: Color.fromRGBO(237, 235, 254, 1),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Text("Volume (MTD): ",
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(144, 97, 249, 1))),
                    Text(
                      "\$" +
                          currencyFmt
                              .format(graphFinal[index]["volume"])
                              .toString(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(144, 97, 249, 1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Card(
              elevation: 0,
              color: Color.fromRGBO(237, 235, 254, 1),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Text(" Stops (Today): ",
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(144, 97, 249, 1))),
                    Text(graphFinal[index]["stops"].toString(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(144, 97, 249, 1)))
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Card(
              elevation: 0,
              color: Color.fromRGBO(237, 235, 254, 1),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Text(" Leads (Today): ",
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(144, 97, 249, 1))),
                    Text(graphFinal[index]["leads"].toString(),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(144, 97, 249, 1)))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> openCard() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Center(
              child: Container(
            height: 550,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: graphFinal.length,
              itemBuilder: (context, index) => _builder(index),
            ),
          ));
        });
      },
    );
  }

  Widget buildDLGridView() {
    return ListView(
        shrinkWrap: true,
        children: List.generate(graphFinal.length, (index) {
          var employee = graphFinal[index];
          bool tied = false;

          if (index == 0) {
            if (employee["agreements"] == graphFinal[index + 1]["agreements"] &&
                employee["statements"] == graphFinal[index + 1]["statements"] &&
                employee["volume"] == graphFinal[index + 1]["volume"]) {
              tied = true;
            }
          } else if (index == graphFinal.length - 1) {
            if (employee["agreements"] == graphFinal[index - 1]["agreements"] &&
                employee["statements"] == graphFinal[index - 1]["statements"]) {
              tied = true;
            }
          } else if (employee["agreements"] ==
                  graphFinal[index - 1]["agreements"] &&
              employee["statements"] == graphFinal[index - 1]["statements"] &&
              employee["volume"] == graphFinal[index + 1]["volume"]) {
            tied = true;
          }

          var employeeImage;
          try {
            employeeImage = Image.network(employee["photoURL"]);
          } catch (err) {
            employeeImage = Image.asset("assets/google_logo.png");
          }
          return GestureDetector(
              onTap: () async {
                openCard();
                return new Future.delayed(const Duration(milliseconds: 50),
                    () => _pageController.jumpToPage(index));
              },
              child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: index < 3
                              ? tied
                                  ? UniversalStyles.themeColor
                                  : starColors[index]
                              : Colors.grey[100],
                          width: 2.0),
                      borderRadius: BorderRadius.circular(4.0)),
                  child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: employeeImage.image,
                        maxRadius: 20,
                      ),
                      title: Text(employee["name"]),
                      // isThreeLine: true,
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              Text("Agreements: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(employee["agreements"].toString()),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              // Text("Vol : ",
                              //     style:
                              //         TextStyle(fontWeight: FontWeight.bold)),
                              Text("\$" +
                                  currencyFmt
                                      .format(employee["volume"])
                                      .toString()),
                            ],
                          ),
                          // Row(
                          //   children: <Widget>[
                          //     Text(" Statements: "),
                          //     Text(employee["statementCount"].toString())
                          //   ],
                          // ),
                          // Text(" Stops(TD): " +
                          //     employee["stopCount"].toString()),
                        ],
                      ),
                      trailing: index < 3
                          ? tied
                              ? IconButton(
                                  icon: Icon(Icons.swap_vert,
                                      color: UniversalStyles.themeColor),
                                  onPressed: null,
                                )
                              : IconButton(
                                  icon: Icon(Icons.stars,
                                      color: index == 0
                                          ? Colors.yellow[600]
                                          : index == 1
                                              ? Colors.grey[500]
                                              : Colors.orange[600]),
                                  onPressed: null,
                                )
                          : Text(""))));
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (graphList != null) {
      if (graphList.length > 0) {
        var graphTemp = [];
        graphFinal = [];

        for (var employee in graphList) {
          if (employee["volume"] == null) employee["volume"] = 0;
          if (employee["statements"] == null) employee["statements"] = 0;
          if (employee["agreements"] == null) employee["agreements"] = 0;
          if (employee["stops"] == null) employee["stops"] = 0;
          if (employee["leads"] == null) employee["leads"] = 0;

          graphTemp.add({
            "volume": employee["volume"] / 12,
            "name": employee["name"],
            "photoURL": employee["photourl"],
            "statements": employee["statements"],
            "agreements": employee["agreements"],
            "stops": employee["stops"],
            "leads": employee["leads"]
          });
        }

        graphTemp.sort((a, b) => b["statements"].compareTo(a["statements"]));
        graphTemp.sort((a, b) => b["volume"].compareTo(a["volume"]));
        graphTemp.sort((a, b) => b["agreements"].compareTo(a["agreements"]));

        graphFinal = graphTemp;

        setState(() {
          isLoading = false;
        });
      }
    }

    return Column(children: <Widget>[
      isLoading
          ? Expanded(
              child: CenteredLoadingSpinner(),
            )
          : Expanded(child: buildDLGridView()),
    ]);
  }
}
