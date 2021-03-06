import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class SalesLeaderboardCards extends StatefulWidget {
  SalesLeaderboardCards({Key key}) : super(key: key);

  @override
  SalesLeaderboardCardsState createState() => SalesLeaderboardCardsState();
}

class SalesLeaderboardCardsState extends State<SalesLeaderboardCards> {
  final UserService userService = UserService();

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

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

  List starColors = [
    UniversalStyles.gold,
    UniversalStyles.silver,
    UniversalStyles.bronze
  ];

  ScrollController _scrollController = ScrollController();

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
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "GET_CARD_LEADERBOARD_COUNT",
      document: gql("""
          subscription GET_CARD_LEADERBOARD_COUNT {
            v_leaderboard {
              employee
              name
              agreements
              statements
              leads
              stops
              volume
              photourl
            }
          }
        """),
      fetchPolicy: FetchPolicy.noCache,
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) {
        var incomingData = data.data["v_leaderboard"];
        if (incomingData != null) {
          if (this.mounted) {
            Future.delayed(Duration(seconds: 1), () {
              logger.i("Sales Leaderboard Cards widget initialized");
            });
            setState(() {
              graphList = incomingData;
              isLoading = false;
            });
          }
        }
      },
      (error) {
        Future.delayed(Duration(seconds: 1), () {
          logger.e(
              "ERROR: Error in Sales Leaderboard Cards: " + error.toString());
        });
      },
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      _scrollController.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Sales leaderboard cards refreshed");
      });

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
                color: Color.fromRGBO(144, 97, 249, 1),
              ),
            ),
            trailing: trailingWidget,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
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
      controller: _scrollController,
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
              return new Future.delayed(
                const Duration(milliseconds: 50),
                () => _pageController.jumpToPage(index),
              );
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: borderColor, width: 2.0),
                borderRadius: BorderRadius.circular(4.0),
              ),
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
                              currencyFmt.format(employee["volume"]).toString(),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: trailingWidget,
              ),
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
          if (employee["agreements"] == null) employee["agreements"] = 0;
          if (employee["volume"] == null) employee["volume"] = 0;
          if (employee["statements"] == null) employee["statements"] = 0;
          if (employee["leads"] == null) employee["leads"] = 0;
          if (employee["stops"] == null) employee["stops"] = 0;

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
          graphTemp.sort((a, b) =>
              a["name"].toLowerCase().compareTo(b["name"].toLowerCase()));
          graphTemp.sort((a, b) => b["stops"].compareTo(a["stops"]));
          graphTemp.sort((a, b) => b["leads"].compareTo(a["leads"]));
          graphTemp.sort((a, b) => b["statements"].compareTo(a["statements"]));
          graphTemp.sort((a, b) => b["volume"].compareTo(a["volume"]));
          graphTemp.sort((a, b) => b["agreements"].compareTo(a["agreements"]));

          bool checkTies = true;

          for (var i = 0; i < graphTemp.length; i++) {
            if (graphTemp[i]["agreements"] != 0 ||
                graphTemp[i]["volume"] != 0 ||
                graphTemp[i]["statements"] != 0 ||
                graphTemp[i]["leads"] != 0 ||
                graphTemp[i]["stops"] != 0) {
              if (i < 3) {
                if (i == 0) {
                  if (graphTemp[i]["agreements"] ==
                          graphTemp[i + 1]["agreements"] &&
                      graphTemp[i]["volume"] == graphTemp[i + 1]["volume"] &&
                      graphTemp[i]["statements"] ==
                          graphTemp[i + 1]["statements"] &&
                      graphTemp[i]["leads"] == graphTemp[i + 1]["leads"] &&
                      graphTemp[i]["stops"] == graphTemp[i + 1]["stops"]) {
                    if (graphTemp[i]["name"]
                            .compareTo(graphTemp[i + 1]["name"]) ==
                        -1) {
                      graphTemp[i]["tied"] = false;
                    }
                    if (graphTemp[i]["name"]
                            .compareTo(graphTemp[i + 1]["name"]) ==
                        1) {
                      graphTemp[i]["tied"] = false;
                    }
                    graphTemp[i]["tied"] = true;
                  }
                } else if (i == graphTemp.length - 1) {
                  if (graphTemp.length != 1) {
                    if (graphTemp[i]["agreements"] ==
                            graphTemp[i - 1]["agreements"] &&
                        graphTemp[i]["volume"] == graphTemp[i - 1]["volume"] &&
                        graphTemp[i]["statements"] ==
                            graphTemp[i - 1]["statements"] &&
                        graphTemp[i]["leads"] == graphTemp[i - 1]["leads"] &&
                        graphTemp[i]["stops"] == graphTemp[i - 1]["stops"]) {
                      if (graphTemp[i]["name"]
                              .compareTo(graphTemp[i - 1]["name"]) ==
                          -1) {
                        graphTemp[i]["tied"] = false;
                      }
                      if (graphTemp[i]["name"]
                              .compareTo(graphTemp[i - 1]["name"]) ==
                          1) {
                        graphTemp[i]["tied"] = false;
                      }
                      graphTemp[i]["tied"] = true;
                    }
                  }
                } else {
                  if (graphTemp[i]["agreements"] ==
                          graphTemp[i - 1]["agreements"] &&
                      graphTemp[i]["volume"] == graphTemp[i - 1]["volume"] &&
                      graphTemp[i]["statements"] ==
                          graphTemp[i - 1]["statements"] &&
                      graphTemp[i]["leads"] == graphTemp[i - 1]["leads"] &&
                      graphTemp[i]["stops"] == graphTemp[i - 1]["stops"]) {
                    if (graphTemp[i]["name"]
                            .compareTo(graphTemp[i - 1]["name"]) ==
                        -1) {
                      graphTemp[i]["tied"] = false;
                    }
                    if (graphTemp[i]["name"]
                            .compareTo(graphTemp[i - 1]["name"]) ==
                        1) {
                      graphTemp[i]["tied"] = false;
                    }
                    graphTemp[i]["tied"] = true;
                  }
                  if (graphTemp[i]["agreements"] ==
                          graphTemp[i + 1]["agreements"] &&
                      graphTemp[i]["volume"] == graphTemp[i + 1]["volume"] &&
                      graphTemp[i]["statements"] ==
                          graphTemp[i + 1]["statements"] &&
                      graphTemp[i]["leads"] == graphTemp[i + 1]["leads"] &&
                      graphTemp[i]["stops"] == graphTemp[i + 1]["stops"]) {
                    if (graphTemp[i]["name"]
                            .compareTo(graphTemp[i + 1]["name"]) ==
                        -1) {
                      graphTemp[i]["tied"] = false;
                    }
                    if (graphTemp[i]["name"]
                            .compareTo(graphTemp[i + 1]["name"]) ==
                        1) {
                      graphTemp[i]["tied"] = false;
                    }

                    graphTemp[i]["tied"] = true;
                  }
                }
              } else if (i > 2 && checkTies) {
                if (graphTemp[i]["agreements"] ==
                        graphTemp[i - 1]["agreements"] &&
                    graphTemp[i]["volume"] == graphTemp[i - 1]["volume"] &&
                    graphTemp[i]["statements"] ==
                        graphTemp[i - 1]["statements"] &&
                    graphTemp[i]["leads"] == graphTemp[i - 1]["leads"] &&
                    graphTemp[i]["stops"] == graphTemp[i - 1]["stops"]) {
                  if (graphTemp[i]["name"]
                          .compareTo(graphTemp[i - 1]["name"]) ==
                      -1) {
                    graphTemp[i]["tied"] = false;
                  }
                  if (graphTemp[i]["name"]
                          .compareTo(graphTemp[i - 1]["name"]) ==
                      1) {
                    graphTemp[i]["tied"] = false;
                  }
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

    return Column(
      children: <Widget>[
        isLoading
            ? Expanded(
                child: CenteredLoadingSpinner(),
              )
            : Expanded(child: buildDLGridView()),
      ],
    );
  }
}
