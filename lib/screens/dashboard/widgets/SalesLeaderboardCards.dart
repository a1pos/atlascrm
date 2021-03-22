import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
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
  final _pageController = PageController(viewportFraction: .8);
  final currencyFmt = new NumberFormat("#,##0", "en_US");

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

  bool isLoading = true;

  List starColors = [Colors.yellow[600], Colors.grey[500], Colors.orange[600]];

  var currentPage = 1;

  var seriesList;

  var items;
  var statements;
  var agreements;
  var label = "items";
  var timeDropdownValue = "week";

  var graphList;
  var graphFinal = [];

  var dateFrom;
  var dateTo;

  var subscription;

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
    initSub();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    subscription.cancel();
    subscription = null;
    super.dispose();
  }

  Future initSub() async {
    Operation options = Operation(
        operationName: "GET_CARD_LEADERBOARD_COUNT", documentNode: gql("""
          subscription GET_CARD_LEADERBOARD_COUNT {
            v_leaderboard {
              employee
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

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) {
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
      (error) {
        print("found error: " + error.toString() + " in front end");
      },
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initSub();
    }
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
    bool ranked = false;
    Color borderColor = Colors.grey[100];
    Widget trailingWidget = Text("");

    if (employee["agreements"] != 0 ||
        employee["statements"] != 0 ||
        employee["volume"] != 0) {
      if (index < 3) {
        ranked = true;
      }
    }
    if (employee["tied"] == true) {
      tied = true;
    }

    if (ranked == true) {
      if (tied == true) {
        borderColor = UniversalStyles.themeColor;
        trailingWidget =
            Text("Tied!", style: TextStyle(color: UniversalStyles.themeColor));
      } else {
        borderColor = starColors[index];
        trailingWidget = IconButton(
          icon: Icon(Icons.stars, color: starColors[index]),
          onPressed: null,
        );
      }
    } else {
      if (tied == true) {
        borderColor = UniversalStyles.themeColor;
        trailingWidget =
            Text("Tied!", style: TextStyle(color: UniversalStyles.themeColor));
      }
    }

    return Card(
      elevation: 3,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 3.0),
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
              trailing: trailingWidget),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Stack(
              alignment: Alignment.center,
              overflow: Overflow.visible,
              children: <Widget>[
                Center(
                  child: Container(
                    child: CircleAvatar(
                      backgroundImage: employeeImage.image,
                      maxRadius: 50,
                    ),
                  ),
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
                        Text(
                          "Agreements (MTD): ",
                          style:
                              TextStyle(color: Color.fromRGBO(144, 97, 249, 1)),
                        ),
                        Text(
                          graphFinal[index]["agreements"].toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(144, 97, 249, 1)),
                        ),
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
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Text(
                          " Statements (WTD): ",
                          style: TextStyle(
                            color: Color.fromRGBO(144, 97, 249, 1),
                          ),
                        ),
                        Text(
                          graphFinal[index]["statements"].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(144, 97, 249, 1),
                          ),
                        ),
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
                      ),
                    ),
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
                    Text(
                      "Volume (MTD): ",
                      style: TextStyle(
                        color: Color.fromRGBO(144, 97, 249, 1),
                      ),
                    ),
                    Text(
                      "\$" +
                          currencyFmt
                              .format(graphFinal[index]["volume"])
                              .toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(144, 97, 249, 1),
                      ),
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
                    Text(
                      " Stops (Today): ",
                      style: TextStyle(
                        color: Color.fromRGBO(144, 97, 249, 1),
                      ),
                    ),
                    Text(
                      graphFinal[index]["stops"].toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(144, 97, 249, 1),
                      ),
                    )
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
                    Text(
                      " Leads (Today): ",
                      style: TextStyle(
                        color: Color.fromRGBO(144, 97, 249, 1),
                      ),
                    ),
                    Text(
                      graphFinal[index]["leads"].toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(144, 97, 249, 1),
                      ),
                    )
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
            ),
          );
        });
      },
    );
  }

  Widget buildDLGridView() {
    return ListView(
      shrinkWrap: true,
      children: List.generate(
        graphFinal.length,
        (index) {
          var employee = graphFinal[index];

          bool tied = false;
          bool ranked = false;
          Color borderColor = Colors.grey[100];
          Widget trailingWidget = Text("");

          if (employee["agreements"] != 0 ||
              employee["statements"] != 0 ||
              employee["volume"] != 0) {
            if (index < 3) {
              ranked = true;
            }
          }
          if (employee["tied"] == true) {
            tied = true;
          }

          if (ranked == true) {
            if (tied == true) {
              borderColor = UniversalStyles.themeColor;
              trailingWidget = Text(
                "Tied!",
                style: TextStyle(color: UniversalStyles.themeColor),
              );
            } else {
              borderColor = starColors[index];
              trailingWidget = IconButton(
                icon: Icon(Icons.stars, color: starColors[index]),
                onPressed: null,
              );
            }
          } else {
            if (tied == true) {
              borderColor = UniversalStyles.themeColor;
              trailingWidget = Text(
                "Tied!",
                style: TextStyle(color: UniversalStyles.themeColor),
              );
            }
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
                  side: BorderSide(color: borderColor, width: 2.0),
                  borderRadius: BorderRadius.circular(4.0)),
              child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: employeeImage.image,
                    maxRadius: 20,
                  ),
                  title: Text(employee["name"]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: <Widget>[
                          Text(
                            "Agreements: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(employee["agreements"].toString()),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "\$" +
                                currencyFmt
                                    .format(employee["volume"])
                                    .toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: trailingWidget),
            ),
          );
        },
      ),
    );
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
        if (graphTemp.length > 1) {
          graphTemp.sort((a, b) => b["statements"].compareTo(a["statements"]));
          graphTemp.sort((a, b) => b["volume"].compareTo(a["volume"]));
          graphTemp.sort((a, b) => b["agreements"].compareTo(a["agreements"]));
          bool checkTies = true;
          for (var i = 0; i < graphTemp.length; i++) {
            if (graphTemp[i]["agreements"] != 0 ||
                graphTemp[i]["statements"] != 0 ||
                graphTemp[i]["volume"] != 0) {
              if (i < 3) {
                if (i == 0) {
                  if (graphTemp[i]["agreements"] ==
                          graphTemp[i + 1]["agreements"] &&
                      graphTemp[i]["statements"] ==
                          graphTemp[i + 1]["statements"] &&
                      graphTemp[i]["volume"] == graphTemp[i + 1]["volume"]) {
                    graphTemp[i]["tied"] = true;
                  }
                } else if (i == graphTemp.length - 1) {
                  if (graphTemp.length != 1) {
                    if (graphTemp[i]["agreements"] ==
                            graphTemp[i - 1]["agreements"] &&
                        graphTemp[i]["statements"] ==
                            graphTemp[i - 1]["statements"] &&
                        graphTemp[i]["volume"] == graphTemp[i - 1]["volume"]) {
                      graphTemp[i]["tied"] = true;
                    }
                  }
                } else {
                  if (graphTemp[i]["agreements"] ==
                          graphTemp[i - 1]["agreements"] &&
                      graphTemp[i]["statements"] ==
                          graphTemp[i - 1]["statements"] &&
                      graphTemp[i]["volume"] == graphTemp[i - 1]["volume"]) {
                    graphTemp[i]["tied"] = true;
                  }
                  if (graphTemp[i]["agreements"] ==
                          graphTemp[i + 1]["agreements"] &&
                      graphTemp[i]["statements"] ==
                          graphTemp[i + 1]["statements"] &&
                      graphTemp[i]["volume"] == graphTemp[i + 1]["volume"]) {
                    graphTemp[i]["tied"] = true;
                  }
                }
              } else if (i > 2 && checkTies) {
                if (graphTemp[i]["agreements"] ==
                        graphTemp[i - 1]["agreements"] &&
                    graphTemp[i]["statements"] ==
                        graphTemp[i - 1]["statements"] &&
                    graphTemp[i]["volume"] == graphTemp[i - 1]["volume"]) {
                  graphTemp[i]["tied"] = true;
                } else {
                  checkTies = false;
                }
              }
            }
          }
        }

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
