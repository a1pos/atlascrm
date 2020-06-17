import 'dart:developer';

import 'package:intl/intl.dart';

import '';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/models/Lead.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';

import 'InventoryAdd.dart';

class InventoryScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  var inventory = [];
  var inventoryFull = [];
  var employees = [];
  var employeesFull = [];
  var columns = [];

  var isLoading = true;
  var isEmpty = true;

  bool isSearching = false;
  bool isFiltering = false;

  var currentSearch = "";
  var pageNum = 1;
  var filterEmployee = "";

  var sortQuery =
      "sorters%5B0%5D%5Bfield%5D=employee&sorters%5B0%5D%5Bdir%5D=asc";
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (UserService.isAdmin) {
      initEmployeeData();
    }
    initInventoryData();

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

  Future<void> initInventoryData() async {
    try {
      var endpoint = UserService.isAdmin || UserService.isTech
          ? "/inventory?page=$pageNum&size=10&$sortQuery"
          : "/employee/${UserService.employee.employee}/inventory?page=$pageNum&size=10&$sortQuery";
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
      if (UserService.isAdmin) {
        endpoint = "/inventory?page=$pageNum&size=10&$sortQuery";
        if (isSearching) {
          endpoint =
              "/inventory?searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
        }
        if (isFiltering) {
          endpoint =
              "/employee/$filterEmployee/inventory?page=$pageNum&size=10&$sortQuery";
        }
        if (isSearching && isFiltering) {
          endpoint =
              "/employee/$filterEmployee/inventory?searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
        }
      } else if (isSearching) {
        endpoint =
            "/employee/${UserService.employee.employee}/inventory?searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      } else {
        endpoint =
            "/employee/${UserService.employee.employee}/inventory?page=$pageNum&size=10&$sortQuery";
      }

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

  void openAddInventoryForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Devices'),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: InventoryAdd(),
          ),
        );
      },
    );
  }

  void openLead(inventory) {
    Navigator.pushNamed(context, "/viewinventory",
        arguments: inventory["inventory"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("inventoryScreenAppBar"),
        title: Text("Inventory"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: openAddInventoryForm,
        backgroundColor: Color.fromARGB(500, 1, 224, 143),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        splashColor: Colors.white,
      ),
    );
  }

  Widget getDataTable() {
    return Container(
      child: Column(
        children: <Widget>[
          // Expanded(
          //   flex: 1,
          //   child: TextField(
          //     decoration: InputDecoration(
          //       labelText: "Search Leads",
          //     ),
          //     onChanged: (value) {
          //       var filtered = leadsFull.where((e) {
          //         String firstName = e["document"]["firstName"];
          //         String lastName = e["document"]["lastName"];
          //         String businessName = e["document"]["businessName"];
          //         return firstName
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             lastName
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             businessName
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase());
          //       }).toList();

          //       setState(() {
          //         leads = filtered.toList();
          //       });
          //     },
          //   ),
          // ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _searchController,
                  onEditingComplete: () {
                    searchInventory(_searchController.text);
                    currentSearch = _searchController.text;
                  },
                  decoration: InputDecoration(
                    labelText: "Search Inventory",
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
                  : IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        currentSearch = _searchController.text;
                        searchInventory(_searchController.text);
                      },
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: UserService.isAdmin
                ? EmployeeDropDown(callback: (val) {
                    filterByEmployee(val);
                  })
                : Container(),
          ),
          isEmpty
              ? Empty("No inventory found")
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: inventory.map((item) {
                      var employeeName;
                      var nameIndex;
                      var merchantName;
                      var itemName;
                      var location;

                      if (UserService.isAdmin) {
                        nameIndex = employees.indexWhere(
                            (e) => e["employee"] == item["employee"]);
                        if (nameIndex != -1) {
                          employeeName = employees[nameIndex]["title"];
                        } else {
                          employeeName = "Not assigned";
                        }
                      }
                      var invDate = DateFormat("EEE, MMM d, ''yy")
                          .add_jm()
                          .format(DateTime.parse(item['created_at']));
                      if (item["model"]?.isEmpty ?? true) {
                        itemName = "";
                      } else {
                        itemName = item["model"];
                      }
                      if (item["locationname"]?.isEmpty ?? true) {
                        location = "";
                      } else {
                        location = item["locationname"];
                      }
                      if (item["merchantname"]?.isEmpty ?? true) {
                        merchantName = "Not yet assigned";
                      } else {
                        merchantName = item["merchantname"];
                      }

                      return GestureDetector(
                        onTap: () {
                          openLead(item);
                        },
                        child: CustomCard(
                          title: invDate,
                          icon: Icons.arrow_forward_ios,
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
                                          'Model:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Serial Number:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Merchant:',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Location:',
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
                                            itemName,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            item["serial"],
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            merchantName,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            location,
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
                              UserService.isAdmin
                                  ? Divider(thickness: 2)
                                  : Container(),
                              UserService.isAdmin
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
