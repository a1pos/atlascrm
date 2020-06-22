import 'dart:developer';
import 'package:atlascrm/components/inventory/InventoryLocationDropDown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';

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
  bool isLocFiltering = false;

  var currentSearch = "";
  var pageNum = 1;
  var filterEmployee = "";
  var filterLocation = "";
  var locationSearch = "All Inventory";

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
      var endpoint = "/inventory?page=$pageNum&size=10&$sortQuery";
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

      endpoint = "/inventory?page=$pageNum&size=10&$sortQuery";
      if (isSearching) {
        endpoint =
            "/inventory?searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
      }
      if (isFiltering) {
        endpoint =
            "/inventory?searchEmployee=$filterEmployee&page=$pageNum&size=10&$sortQuery";
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

  Future<void> scanBarcode() async {
    try {
      var options = ScanOptions(strings: {
        "cancel": "done",
        "flash_on": "flash on",
        "flash_off": "flash off",
      });
      var result = await BarcodeScanner.scan(options: options);

      print(result.rawContent);

      if (result.type != ResultType.Cancelled) {
        searchInventory(result.rawContent.toString());
        _searchController.text = result.rawContent.toString();
      }
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

  void openDevice(inventory) {
    Map sendable = {"id": inventory["inventory"]};
    Navigator.pushNamed(context, "/viewinventory", arguments: sendable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        key: Key("inventoryscreenappbar"),
        title: Text(isLoading ? "Loading..." : "$locationSearch"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
            child: IconButton(
              onPressed: () {
                openLocationFilter();
              },
              icon: Icon(Icons.business, color: Colors.white),
            ),
          )
        ],
        backgroundColor: Color.fromARGB(500, 1, 56, 112),
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
                    labelText: "Search Inventory (Serial)",
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
                      icon: Icon(Icons.center_focus_weak),
                      onPressed: () {
                        currentSearch = _searchController.text;
                        scanBarcode();
                      },
                    ),
            ],
          ),
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
                      var setIcon;
                      nameIndex = employees
                          .indexWhere((e) => e["employee"] == item["employee"]);
                      if (nameIndex != -1) {
                        employeeName = employees[nameIndex]["title"];
                      } else {
                        employeeName = "Not assigned";
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

                      if (item["is_installed"] == true) {
                        setIcon = Icons.done;
                      }
                      if (item["merchant"] != null &&
                          item["is_installed"] != true) {
                        setIcon = Icons.directions_car;
                      }
                      if (item["merchant"] == null &&
                          item["employee"] == null) {
                        setIcon = Icons.business;
                      }

                      return GestureDetector(
                        onTap: () {
                          openDevice(item);
                        },
                        child: CustomCard(
                          title: invDate,
                          icon: setIcon,
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
                              Divider(thickness: 2),
                              Text("Employee: " + employeeName,
                                  style: TextStyle(),
                                  textAlign: TextAlign.right),
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
