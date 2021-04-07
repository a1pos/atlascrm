import 'dart:developer';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:flutter/material.dart';

class InstallsScreen extends StatefulWidget {
  @override
  _InstallsScreenState createState() => _InstallsScreenState();
}

class _InstallsScreenState extends State<InstallsScreen> {
  bool isSearching = false;
  bool isFiltering = false;
  bool isLocFiltering = false;
  bool isLoading = true;
  bool isEmpty = true;
  bool myTickets = false;

  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  var installs = [];
  var installsFull = [];
  var columns = [];

  var currentSearch = "";
  var pageNum = 0;
  var filterEmployee = "";
  var filterLocation = "";
  var locationSearch = "Installs";
  var sortQueries = [
    "updated_at: desc",
    "updated_at: asc",
  ];
  var initParams = "offset: 0, limit: 10, order_by: {updated_at: asc}";
  var sortQuery = "updated_at: asc";

  @override
  void initState() {
    super.initState();

    initTicketData();

    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          onScroll();
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initTicketData() async {
    try {
      QueryOptions options = QueryOptions(
        document: gql("""
        query GET_INSTALL_TICKETS {
          ticket_category(where: {title: {_eq: "Installation"}}) {
            tickets ($initParams){
              ticket
              document
              due_date
              employeeByEmployee{
                employee
                displayName:document(path:"displayName")
              }
            }
          }
        }
      """),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          var installsArrDecoded = result.data["ticket_category"][0]["tickets"];
          if (installsArrDecoded != null) {
            var installsArr = List.from(installsArrDecoded);
            if (installsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                installs += installsArr;
                installsFull += installsArr;
                pageNum++;
              });
            } else {
              setState(
                () {
                  if (pageNum == 0) {
                    isEmpty = true;
                    installsArr = [];
                    installsFull = [];
                  }
                  isLoading = false;
                },
              );
            }
          }
        }
      }

      setState(
        () {
          isLoading = false;
        },
      );
    } catch (err) {
      log(err);
    }
  }

  Future<void> onScroll() async {
    try {
      var offsetAmount = pageNum * 10;
      var limitAmount = 10;
      var params =
          'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}';

      if (isFiltering) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}}';
      }

      QueryOptions options = QueryOptions(
        document: gql("""
        query GET_INSTALL_TICKETS {
          ticket_category(where: {title: {_eq: "Installation"}}) {
            tickets ($params){
              ticket
              document
              due_date
              employeeByEmployee{
                employee
                displayName:document(path:"displayName")
              }
            }
          }
        }
      """),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          var installsArrDecoded = result.data["ticket_category"][0]["tickets"];
          if (installsArrDecoded != null) {
            var installsArr = List.from(installsArrDecoded);
            if (installsArr.length > 0) {
              setState(
                () {
                  isEmpty = false;
                  isLoading = false;
                  installs += installsArr;
                  installsFull += installsArr;
                  pageNum++;
                },
              );
            } else {
              setState(
                () {
                  if (pageNum == 0) {
                    isEmpty = true;
                    installsArr = [];
                    installsFull = [];
                  }
                  isLoading = false;
                },
              );
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      log(err);
    }
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(
      () {
        filterEmployee = employeeId;
        pageNum = 0;
        isFiltering = true;
        installs = [];
        installsFull = [];
        onScroll();
      },
    );
  }

  Future<void> clearFilter() async {
    if (isFiltering) {
      setState(
        () {
          filterEmployee = "";
          pageNum = 0;
          isFiltering = false;
          installs = [];
          installsFull = [];
        },
      );
      onScroll();
    }
  }

  void openInstall(inventory) {
    Map sendable = {"id": inventory["inventory"]};
    Navigator.pushNamed(
      context,
      "/viewinventory",
      arguments: sendable,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalStyles.backgroundColor,
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("inventoryscreenappbar"),
        title: Text(isLoading ? "Loading..." : "$locationSearch"),
        action: <Widget>[],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            isLoading
                ? CenteredLoadingSpinner()
                : Container(
                    child: Expanded(
                      child:
                          isLoading ? CenteredLoadingSpinner() : getDataTable(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget getDataTable() {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: EmployeeDropDown(
                callback: (val) {
                  if (val != null) {
                    filterByEmployee(val);
                  } else {
                    clearFilter();
                  }
                },
                role: "tech"),
          ),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 200, 8, 0),
                  child: Empty("No installs found"),
                )
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: installs.map(
                      (item) {
                        var employeeName = item["employeeByEmployee"] == null ||
                                item["employeeByEmployee"]["displayName"] ==
                                    null
                            ? ""
                            : item["employeeByEmployee"]["displayName"];

                        return GestureDetector(
                          onTap: () {
                            openInstall(item);
                          },
                          child: CustomCard(
                            title: item["document"]["title"],
                            icon: Icons.build,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            'Employee:',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              employeeName,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                employeeName != null && employeeName != ""
                                    ? Divider(thickness: 2)
                                    : Container(),
                                employeeName != null && employeeName != ""
                                    ? Text("Employee: " + employeeName,
                                        style: TextStyle(),
                                        textAlign: TextAlign.right)
                                    : Container(),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
