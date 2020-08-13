import 'dart:developer';
import 'package:atlascrm/components/inventory/InventoryLocationDropDown.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

import '../inventory/InventoryAdd.dart';

class InstallsScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  _InstallsScreenState createState() => _InstallsScreenState();
}

class _InstallsScreenState extends State<InstallsScreen> {
  var inventory = [];
  var inventoryFull = [];
  var employees = [];
  var employeesFull = [];
  var columns = [];

  var isLoading = true;
  var isEmpty = true;

  bool isSearching = false;
  bool isFiltering = false;
  bool isLocFiltering = false;

  var currentSearch = "";
  var pageNum = 1;
  var filterEmployee = "";
  var filterLocation = "";
  var locationSearch = "Installs";

  var sortQuery =
      "sorters%5B0%5D%5Bfield%5D=employee&sorters%5B0%5D%5Bdir%5D=asc";
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    initEmployeeData();

    initInventoryData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // onScroll();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initInventoryData() async {
    try {
      var endpoint =
          "/ticket?page=$pageNum&size=10&searchString=&installView=true&closedTickets=false";
      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var inventoryArrDecoded = resp.data["data"];
          if (inventoryArrDecoded != null) {
            var inventoryArr = List.from(inventoryArrDecoded);
            if (inventoryArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                inventory += inventoryArr;
                inventoryFull += inventoryArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  inventoryArr = [];
                  inventoryFull = [];
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
      var endpoint;

      endpoint = "/ticket?page=$pageNum&size=10";
      if (isSearching) {
        endpoint =
            "/inventory?searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      }
      if (isFiltering) {
        endpoint =
            "/ticket?searchEmployee=$filterEmployee&page=$pageNum&size=10&$sortQuery";
      }
      if (isLocFiltering) {
        endpoint =
            "/inventory?searchLocation=$filterLocation&page=$pageNum&size=10&$sortQuery";
      }
      if (isSearching && isFiltering) {
        endpoint =
            "/inventory?searchEmployee=$filterEmployee&searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      }
      if (isSearching && isLocFiltering) {
        endpoint =
            "/inventory?searchLocatation=$filterLocation&searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      }
      if (isFiltering && isLocFiltering) {
        endpoint =
            "/inventory?searchLocation=$filterLocation&searchEmployee=$filterEmployee&page=$pageNum&size=10&$sortQuery";
      }
      if (isSearching && isFiltering && isLocFiltering) {
        endpoint =
            "/inventory?searchLocation=$filterLocation&searchEmployee=$filterEmployee&searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      }

      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var inventoryArrDecoded = resp.data["data"];
          if (inventoryArrDecoded != null) {
            var inventoryArr = List.from(inventoryArrDecoded);
            if (inventoryArr.length > 0) {
              if (isSearching) {
                var sendable = {"id": inventoryArr[0]["inventory"]};
                Navigator.pushNamed(context, "/viewinventory",
                    arguments: sendable);
              }
              setState(() {
                isEmpty = false;
                isLoading = false;
                inventory += inventoryArr;
                inventoryFull += inventoryArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  inventoryArr = [];
                  inventoryFull = [];
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

  Future<void> searchInventory(searchString) async {
    setState(() {
      currentSearch = searchString;
      pageNum = 1;
      isSearching = true;
      inventory = [];
      inventoryFull = [];
      onScroll();
    });
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(() {
      filterEmployee = employeeId;
      pageNum = 1;
      isFiltering = true;
      inventory = [];
      inventoryFull = [];
      onScroll();
    });
  }

  Future<void> filterByLocation(locItem) async {
    setState(() {
      locationSearch = locItem["name"];
      filterLocation = locItem["location"];
      pageNum = 1;
      isLocFiltering = true;
      inventory = [];
      inventoryFull = [];
      onScroll();
      Navigator.pop(context);
    });
  }

  Future<void> clearLocFilter() async {
    if (isLocFiltering) {
      setState(() {
        pageNum = 1;
        locationSearch = "All Inventory";
        filterLocation = "";
        isLocFiltering = false;
        inventory = [];
        inventoryFull = [];
      });
      onScroll();
    }
  }

  Future<void> clearFilter() async {
    if (isFiltering) {
      setState(() {
        filterEmployee = "";
        pageNum = 1;
        isFiltering = false;
        inventory = [];
        inventoryFull = [];
      });
      onScroll();
    }
  }

  Future<void> clearSearch() async {
    setState(() {
      pageNum = 1;
      currentSearch = "";
      isSearching = false;
      _searchController.clear();
      inventory = [];
      inventoryFull = [];
    });
    onScroll();
  }

  Future<void> initEmployeeData() async {
    try {
      var endpoint = "/employee";
      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var employeesArrDecoded = resp.data;
          if (employeesArrDecoded != null) {
            var employeesArr = List.from(employeesArrDecoded);
            if (employeesArr.length > 0) {
              setState(() {
                employees = employeesArr;
                employeesFull = employeesArr;
              });
            } else {
              setState(() {
                employeesArr = [];
                employeesFull = [];
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

  void openLocationFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by Location'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                InventoryLocationDropDown(
                    value: filterLocation,
                    callback: (newVal) {
                      if (newVal != null) {
                        filterByLocation(newVal);
                      } else {
                        clearLocFilter();
                      }
                    })
              ],
            ),
          ),
        );
      },
    );
  }

  void openInstall(ticket) {
    Map sendable = {"id": ticket["number"], "ticket": ticket};
    Navigator.pushNamed(context, "/viewinstall", arguments: sendable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("inventoryscreenappbar"),
        title: Text(isLoading ? "Loading..." : "$locationSearch"),
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
                  role: "tech")),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 200, 8, 0),
                  child: Empty("No inventory found"),
                )
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: inventory.map((item) {
                      var employeeName;

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
                                      children: <Widget>[]),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[],
                                    ),
                                  ),
                                ],
                              ),
                              employeeName != null
                                  ? Divider(thickness: 2)
                                  : Container(),
                              employeeName != null
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
