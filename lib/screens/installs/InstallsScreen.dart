import 'dart:developer';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class InstallsScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  _InstallsScreenState createState() => _InstallsScreenState();
}

class _InstallsScreenState extends State<InstallsScreen> {
  var installs = [];
  var installsFull = [];
  var employees = [];
  var employeesFull = [];
  var columns = [];

  var isLoading = true;
  var isEmpty = true;

  bool isSearching = false;
  bool myTickets = false;
  bool isFiltering = false;
  bool isLocFiltering = false;

  var currentSearch = "";
  var pageNum = 1;
  var filterEmployee = "";
  var filterLocation = "";
  var locationSearch = "All Installs";

  var sortQuery =
      "sorters%5B0%5D%5Bfield%5D=employee&sorters%5B0%5D%5Bdir%5D=asc";
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    initEmployeeData();

    initInstallsData();

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

  Future<void> initInstallsData() async {
    try {
      var endpoint =
          "/ticket?page=$pageNum&size=10&searchString=&installView=true&closedTickets=false";
      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var installsArrDecoded = resp.data["data"];
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
                if (pageNum == 1) {
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
      var endpoint;

      endpoint =
          "/ticket?page=$pageNum&size=10&searchString=&installView=true&closedTickets=false";
      if (isSearching) {
        endpoint =
            "/ticket?searchString=$currentSearch&page=$pageNum&size=10&installView=true&closedTickets=false";
      }
      if (myTickets) {
        endpoint =
            "/ticket?page=$pageNum&size=10&searchString=&installView=true&closedTickets=false&myTickets=true";
      }
      if (isSearching && myTickets) {
        endpoint =
            "/ticket?searchString=$currentSearch&page=$pageNum&size=10&installView=true&closedTickets=false&myTickets=true";
      }
      // if (isFiltering) {
      //   endpoint =
      //       "/ticket?searchEmployee=$filterEmployee&page=$pageNum&size=10&$sortQuery";
      // }
      // if (isLocFiltering) {
      //   endpoint =
      //       "/ticket?searchLocation=$filterLocation&page=$pageNum&size=10&$sortQuery";
      // }
      // if (isSearching && isFiltering) {
      //   endpoint =
      //       "/ticket?searchEmployee=$filterEmployee&searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      // }
      // if (isSearching && isLocFiltering) {
      //   endpoint =
      //       "/ticket?searchLocatation=$filterLocation&searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      // }
      // if (isFiltering && isLocFiltering) {
      //   endpoint =
      //       "/ticket?searchLocation=$filterLocation&searchEmployee=$filterEmployee&page=$pageNum&size=10&$sortQuery";
      // }
      // if (isSearching && isFiltering && isLocFiltering) {
      //   endpoint =
      //       "/ticket?searchLocation=$filterLocation&searchEmployee=$filterEmployee&searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      // }

      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var installsArrDecoded = resp.data["data"];
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
                if (pageNum == 1) {
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

  Future<void> searchInstalls(searchString) async {
    setState(() {
      currentSearch = searchString;
      pageNum = 1;
      isSearching = true;
      installs = [];
      installsFull = [];
      onScroll();
    });
  }

  Future<void> filterMyTickets() async {
    setState(() {
      locationSearch = "My installs";
      pageNum = 1;
      myTickets = true;
      installs = [];
      installsFull = [];
      onScroll();
    });
  }

  Future<void> filterAllTickets() async {
    setState(() {
      locationSearch = "All installs";
      pageNum = 1;
      myTickets = false;
      installs = [];
      installsFull = [];
      onScroll();
    });
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(() {
      filterEmployee = employeeId;
      pageNum = 1;
      isFiltering = true;
      installs = [];
      installsFull = [];
      onScroll();
    });
  }

  Future<void> filterByLocation(locItem) async {
    setState(() {
      locationSearch = locItem["name"];
      filterLocation = locItem["location"];
      pageNum = 1;
      isLocFiltering = true;
      installs = [];
      installsFull = [];
      onScroll();
      Navigator.pop(context);
    });
  }

  Future<void> clearLocFilter() async {
    if (isLocFiltering) {
      setState(() {
        pageNum = 1;
        locationSearch = "All installs";
        filterLocation = "";
        isLocFiltering = false;
        installs = [];
        installsFull = [];
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
        installs = [];
        installsFull = [];
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
      installs = [];
      installsFull = [];
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
        key: Key("installsscreenappbar"),
        title: Text(isLoading ? "Loading..." : "$locationSearch"),
        action: [
          myTickets
              ? IconButton(icon: Icon(Icons.list), onPressed: filterAllTickets)
              : IconButton(
                  icon: Icon(Icons.account_circle), onPressed: filterMyTickets)
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
    );
  }

  Widget getDataTable() {
    return Container(
      child: Column(
        children: <Widget>[
          // Padding(
          //     padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          //     child: EmployeeDropDown(
          //         callback: (val) {
          //           if (val != null) {
          //             filterByEmployee(val);
          //           } else {
          //             clearFilter();
          //           }
          //         },
          //         role: "tech")),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _searchController,
                  onEditingComplete: () {
                    searchInstalls(_searchController.text);
                    currentSearch = _searchController.text;
                  },
                  decoration: InputDecoration(
                    labelText: "Search Installs",
                  ),
                ),
              ),
              isSearching
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        clearSearch();
                      },
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromARGB(500, 1, 224, 143),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          currentSearch = _searchController.text;
                          searchInstalls(_searchController.text);
                        },
                      ),
                    ),
            ],
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
                    children: installs.map((item) {
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
