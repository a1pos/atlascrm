import 'dart:developer';
import 'package:atlascrm/components/inventory/InventoryLocationDropDown.dart';
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
import 'package:barcode_scan/barcode_scan.dart';

class InstallsScreen extends StatefulWidget {
  @override
  _InstallsScreenState createState() => _InstallsScreenState();
}

class _InstallsScreenState extends State<InstallsScreen> {
  var installs = [];
  var installsFull = [];

  var columns = [];

  var isLoading = true;
  var isEmpty = true;
  var myTickets = false;

  bool isSearching = false;
  bool isFiltering = false;
  bool isLocFiltering = false;

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

  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // initEmployeeData();

    initTicketData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        onScroll();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initTicketData() async {
    try {
      QueryOptions options = QueryOptions(documentNode: gql("""
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
      """));

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
              setState(() {
                if (pageNum == 0) {
                  isEmpty = true;
                  installsArr = [];
                  installsFull = [];
                }
                isLoading = false;
              });
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

  Future<void> onScroll() async {
    try {
      var offsetAmount = pageNum * 10;
      var limitAmount = 10;
      var params =
          'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}';
      // var searchParams = '	_or: [{serial: {_eq: "%$currentSearch%"}},]';

      // if (isSearching) {
      //   params =
      //       'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {serial: {_eq: "$currentSearch"}}';
      // }
      if (isFiltering) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}}';
      }
      // if (isLocFiltering) {
      //   params =
      //       'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {inventory_location: {_eq: "$filterLocation"}}';
      // }

      // if (isLocFiltering && isFiltering) {
      //   params =
      //       'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}, _and: {inventory_location: {_eq: "$filterLocation"}}}';
      // }

      QueryOptions options = QueryOptions(documentNode: gql("""
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
      """), fetchPolicy: FetchPolicy.networkOnly);

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
              setState(() {
                if (pageNum == 0) {
                  isEmpty = true;
                  installsArr = [];
                  installsFull = [];
                }
                isLoading = false;
              });
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

  // Future<void> searchInstalls(searchString) async {
  //   setState(() {
  //     currentSearch = searchString;
  //     pageNum = 0;
  //     isSearching = true;
  //     installs = [];
  //     installsFull = [];
  //     onScroll();
  //   });
  // }

  Future<void> filterByEmployee(employeeId) async {
    setState(() {
      filterEmployee = employeeId;
      pageNum = 0;
      isFiltering = true;
      installs = [];
      installsFull = [];
      onScroll();
    });
  }

  // Future<void> filterByLocation(locItem) async {
  //   setState(() {
  //     locationSearch = locItem["name"];
  //     filterLocation = locItem["location"];
  //     pageNum = 0;
  //     isLocFiltering = true;
  //     installs = [];
  //     installsFull = [];
  //     onScroll();
  //     Navigator.pop(context);
  //   });
  // }

  // Future<void> clearLocFilter() async {
  //   if (isLocFiltering) {
  //     setState(() {
  //       pageNum = 0;
  //       locationSearch = "Installs";
  //       filterLocation = "";
  //       isLocFiltering = false;
  //       installs = [];
  //       installsFull = [];
  //     });
  //     onScroll();
  //   }
  // }

  Future<void> clearFilter() async {
    if (isFiltering) {
      setState(() {
        filterEmployee = "";
        pageNum = 0;
        isFiltering = false;
        installs = [];
        installsFull = [];
      });
      onScroll();
    }
  }

  // Future<void> clearSearch() async {
  //   setState(() {
  //     pageNum = 0;
  //     currentSearch = "";
  //     isSearching = false;
  //     _searchController.clear();
  //     installs = [];
  //     installsFull = [];
  //   });
  //   onScroll();
  // }

  void openInstall(inventory) {
    Map sendable = {"id": inventory["inventory"]};
    Navigator.pushNamed(context, "/viewinventory", arguments: sendable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalStyles.backgroundColor,
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("inventoryscreenappbar"),
        title: Text(isLoading ? "Loading..." : "$locationSearch"),
        action: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
          //   child: IconButton(
          //     onPressed: () {
          //       openLocationFilter();
          //     },
          //     icon: Icon(Icons.business, color: Colors.white),
          //   ),
          // )
        ],
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: openAddInventoryForm,
      //   backgroundColor: UniversalStyles.actionColor,
      //   foregroundColor: Colors.white,
      //   child: Icon(Icons.add),
      //   splashColor: Colors.white,
      // ),
    );
  }

  Widget getDataTable() {
    return Container(
      child: Column(
        children: <Widget>[
          // Row(
          //   children: <Widget>[
          //     Expanded(
          //       flex: 1,
          //       child: TextField(
          //         controller: _searchController,
          //         onEditingComplete: () {
          //           searchInstalls(_searchController.text);
          //           currentSearch = _searchController.text;
          //         },
          //         decoration: InputDecoration(
          //           labelText: "Search Installs",
          //         ),
          //       ),
          //     ),
          //     isSearching
          //         ? IconButton(
          //             icon: Icon(Icons.clear),
          //             onPressed: () {
          //               clearSearch();
          //             },
          //           )
          //         : CircleAvatar(
          //             radius: 25,
          //             backgroundColor: UniversalStyles.actionColor,
          //             child: IconButton(
          //               icon: Icon(Icons.search, color: Colors.white),
          //               onPressed: () {
          //                 currentSearch = _searchController.text;
          //                 searchInstalls(_searchController.text);
          //               },
          //             ),
          //           ),
          //   ],
          // ),
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
                  role: "tech")),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 200, 8, 0),
                  child: Empty("No installs found"),
                )
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: installs.map((item) {
                      var employeeName = item["employeeByEmployee"] == null ||
                              item["employeeByEmployee"]["displayName"] == null
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
