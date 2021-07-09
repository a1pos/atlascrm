import 'package:round2crm/components/inventory/InventoryLocationDropDown.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/CustomCard.dart';
import 'package:round2crm/components/shared/CustomDrawer.dart';
import 'package:round2crm/components/shared/EmployeeDropDown.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:flutter/material.dart';
import 'package:dan_barcode_scan/dan_barcode_scan.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:unicorndial/unicorndial.dart';

import 'InventoryAdd.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool isSearching = false;
  bool isFiltering = false;
  bool isLocFiltering = false;
  bool isLoading = true;
  bool isEmpty = true;

  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  List<UnicornButton> childButtons = [];

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  var inventory = [];
  var inventoryFull = [];
  var employees = [];
  var employeesFull = [];
  var columns = [];

  var currentSearch = "";
  var pageNum = 0;
  var filterEmployee = "";
  var filterLocation = "";
  var locationSearch = "All Inventory";
  var sortQueries = [
    "updated_at: desc",
    "updated_at: asc",
  ];
  var initParams = "offset: 0, limit: 10, order_by: {updated_at: asc}";
  var sortQuery = "updated_at: asc";

  @override
  void initState() {
    super.initState();

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
    logger.i("Parameters for inventory query: " + initParams);
    try {
      QueryOptions options = QueryOptions(
        document: gql("""
        query INVENTORY {
          inventory($initParams) {
            inventory
            merchantByMerchant {
              merchant
              document
            }
            is_installed
            employee: employeeByEmployee {
              employee
              document
            }
            serial
            locationName: inventoryLocationByInventoryLocation {
              name
            }
            model: inventoryPriceTierByInventoryPriceTier {
              model
            }
            document
            created_at
          }
        }
      """),
        pollInterval: Duration(seconds: 5),
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        logger.i("Inventory data initialized");
        if (result.hasException == false) {
          var inventoryArrDecoded = result.data["inventory"];
          if (inventoryArrDecoded != null) {
            var inventoryArr = List.from(inventoryArrDecoded);
            if (inventoryArr.length > 0) {
              setState(
                () {
                  isEmpty = false;
                  isLoading = false;
                  inventory += inventoryArr;
                  inventoryFull += inventoryArr;
                  pageNum++;
                },
              );
            } else {
              setState(
                () {
                  if (pageNum == 1) {
                    isEmpty = true;
                    inventoryArr = [];
                    inventoryFull = [];
                  }
                  isLoading = false;
                },
              );
            }
          }
        } else {
          logger.e("Error getting Inventory: " + result.exception.toString());
          Fluttertoast.showToast(
            msg: result.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }

      setState(
        () {
          isLoading = false;
        },
      );
    } catch (err) {
      debugPrint("Error getting Inventory: " + err.toString());
      logger.e("Error getting Inventory: " + err.toString());
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
      if (isSearching) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {serial: {_eq: "$currentSearch"}}';
      }
      if (isLocFiltering) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {inventory_location: {_eq: "$filterLocation"}}';
      }

      if (isLocFiltering && isFiltering) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}, _and: {inventory_location: {_eq: "$filterLocation"}}}';
      }

      QueryOptions options = QueryOptions(
        document: gql("""
        query INVENTORY {
          inventory($params) {
            inventory
            merchantByMerchant {
              merchant
              document
            }
            is_installed
            employee: employeeByEmployee {
              employee
              document
            }
            serial
            locationName: inventoryLocationByInventoryLocation {
              name
            }
            model: inventoryPriceTierByInventoryPriceTier {
              model
            }
            document
            created_at
          }
        }
      """),
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        logger.i("Inventory onScroll parameters: " + params);

        if (result.hasException == false) {
          var inventoryArrDecoded = result.data["inventory"];
          if (inventoryArrDecoded != null) {
            var inventoryArr = List.from(inventoryArrDecoded);
            if (inventoryArr.length > 0) {
              if (isSearching) {
                var sendable = {"id": inventoryArr[0]["inventory"]};
                Navigator.pushNamed(
                  context,
                  "/viewinventory",
                  arguments: sendable,
                );
              }
              setState(
                () {
                  isEmpty = false;
                  isLoading = false;
                  inventory += inventoryArr;
                  inventoryFull += inventoryArr;
                  pageNum++;
                },
              );
            } else {
              setState(
                () {
                  if (pageNum == 1) {
                    isEmpty = true;
                    inventoryArr = [];
                    inventoryFull = [];
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
      debugPrint("Error refreshing inventory onScroll" + err.toString());
      logger.e("Error refreshing inventory onScroll" + err.toString());
    }
  }

  Future<void> scanBarcode() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    RegExp searchPat = RegExp(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$");
    try {
      var options = ScanOptions(strings: {
        "cancel": "done",
        "flash_on": "flash on",
        "flash_off": "flash off",
      });
      var result = await BarcodeScanner.scan(options: options);
      logger.i("BarcodeScanner opened");

      if (result.type != ResultType.Cancelled) {
        logger.i(
          "Inventory searched by BarCode: " + result.rawContent.toString(),
        );

        bool isMac = searchPat.hasMatch(result.rawContent.toString());
        if (!isMac) {
          logger.i(
            "Inventory searched by BarCode: " + result.rawContent.toString(),
          );
          searchInventory(result.rawContent.toString());
          _searchController.text = result.rawContent.toString();
        } else {
          logger.i("MAC address scanned on Inventory Barcode search");
          Fluttertoast.showToast(
            msg: "That's the MAC address!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        logger.i("BarcodeScanner closed");
      }
    } catch (err) {
      debugPrint("Error searching Inventory by barcode: " + err.toString());
      logger.e("Error searching Inventory by barcode: " + err.toString());
    }
  }

  Future<void> searchInventory(searchString) async {
    logger.i("Inventory search filtered: " + searchString);
    setState(() {
      currentSearch = searchString;
      pageNum = 0;
      isSearching = true;
      inventory = [];
      inventoryFull = [];
      onScroll();
    });
  }

  Future<void> filterByEmployee(employeeId) async {
    logger.i("Search filtered by employee: " + employeeId);
    setState(() {
      filterEmployee = employeeId;
      pageNum = 0;
      isFiltering = true;
      inventory = [];
      inventoryFull = [];
      onScroll();
    });
  }

  Future<void> filterByLocation(locItem) async {
    logger.i("Search filtered by location: " + locItem.toString());

    setState(() {
      locationSearch = locItem["name"];
      filterLocation = locItem["location"];
      pageNum = 0;
      isLocFiltering = true;
      inventory = [];
      inventoryFull = [];
      onScroll();
      Navigator.pop(context);
    });
  }

  Future<void> clearLocFilter() async {
    logger.i("Search filter by location cleared");
    if (isLocFiltering) {
      setState(() {
        pageNum = 0;
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
    logger.i("Search filters cleared");

    if (isFiltering) {
      setState(() {
        filterEmployee = "";
        pageNum = 0;
        isFiltering = false;
        inventory = [];
        inventoryFull = [];
      });
      onScroll();
    }
  }

  Future<void> clearSearch() async {
    logger.i("Search bar cleared");
    setState(() {
      pageNum = 0;
      currentSearch = "";
      isSearching = false;
      _searchController.clear();
      inventory = [];
      inventoryFull = [];
    });
    onScroll();

    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Future<void> initEmployeeData() async {
    try {
      var resp;
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
      debugPrint("Error getting employee data: " + err.toString());
      logger.e("Error getting employee data: " + err.toString());
    }
  }

  void openAddInventoryForm() {
    logger.i("Add device form opened");
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 7.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Add New Devices'),
                GestureDetector(
                  onTap: () {
                    logger.i("Add device form closed");
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[750],
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ),
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
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void openDevice(inventory) {
    Map sendable = {"id": inventory["inventory"]};
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pushNamed(context, "/viewinventory", arguments: sendable);
    logger.i("Inventory device opened: " + sendable.toString());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/dashboard");
        return false;
      },
      child: Scaffold(
        backgroundColor: UniversalStyles.backgroundColor,
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          key: Key("inventoryscreenappbar"),
          title: Text(isLoading ? "Loading..." : "$locationSearch"),
          action: <Widget>[
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
        ),
        body: isLoading
            ? CenteredLoadingSpinner()
            : Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Expanded(
                        child: getDataTable(),
                      ),
                    ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: openAddInventoryForm,
          backgroundColor: UniversalStyles.actionColor,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          splashColor: Colors.white,
        ),
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
                    if (_searchController.text.trim() != "" &&
                        _searchController.text.trim() != null) {
                      searchInventory(_searchController.text);
                      currentSearch = _searchController.text;
                    } else {
                      clearSearch();
                    }
                  },
                  onChanged: (value) {
                    if (value == "" || value == null) {
                      clearSearch();
                    }
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
                  : CircleAvatar(
                      radius: 25,
                      backgroundColor: UniversalStyles.actionColor,
                      child: IconButton(
                        icon:
                            Icon(Icons.center_focus_weak, color: Colors.white),
                        onPressed: () {
                          currentSearch = _searchController.text;
                          scanBarcode();
                        },
                      ),
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
              roles: ["tech", "corporate_tech"],
            ),
          ),
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
                      var employeeName = item["employee"] == null
                          ? ""
                          : item["employee"]["document"]["displayName"];
                      var merchantName = "";
                      var itemName;
                      var location;
                      var setIcon;
                      var invDate;
                      if (item['created_at'] != null) {
                        invDate = DateFormat("EEE, MMM d, ''yy")
                            .add_jm()
                            .format(DateTime.parse(item['created_at']));
                      } else {
                        invDate = "";
                      }
                      if (item["model"]?.isEmpty ?? true) {
                        itemName = "";
                      } else {
                        itemName = item["model"]["model"];
                      }
                      if (item["locationName"] == null ?? true) {
                        location = "";
                      } else {
                        location = item["locationName"]["name"];
                      }
                      if (item["merchantByMerchant"] == null) {
                        merchantName = "Not yet assigned";
                      } else {
                        if (item["merchantByMerchant"]["document"]
                                ["leadDocument"]["businessName"] !=
                            null) {
                          merchantName = item["merchantByMerchant"]["document"]
                              ["leadDocument"]["businessName"];
                        } else {
                          merchantName = item["merchantByMerchant"]["document"]
                                  ["ApplicationInformation"]["MpaOutletInfo"]
                              ["Outlet"]["BusinessInfo"]["IrsName"];
                          if (merchantName == null) {
                            merchantName = item["merchantByMerchant"]
                                    ["document"]["ApplicationInformation"]
                                ["CorporateInfo"]["LegalName"];
                          }
                        }

                        if (merchantName == null) {
                          merchantName = "null";
                        }
                      }

                      if (item["is_installed"] == true) {
                        setIcon = Icons.done;
                      }
                      if (item["merchantByMerchant"] != null &&
                          item["is_installed"] != true) {
                        setIcon = Icons.directions_car;
                      }
                      if (item["merchantByMerchant"] == null &&
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
