import 'dart:developer';

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

class MerchantsScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  _MerchantsScreenState createState() => _MerchantsScreenState();
}

class _MerchantsScreenState extends State<MerchantsScreen> {
  var merchants = [];
  var merchantsFull = [];
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
      "sorters%5B0%5D%5Bfield%5D=document.businessName&sorters%5B0%5D%5Bdir%5D=asc";
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (UserService.isAdmin) {
      initEmployeeData();
    }
    initMerchantsData();

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

  Future<void> initMerchantsData() async {
    try {
      var endpoint = "/merchant?page=$pageNum&size=10";
      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var merchantsArrDecoded = resp.data["data"];
          if (merchantsArrDecoded != null) {
            var merchantsArr = List.from(merchantsArrDecoded);
            if (merchantsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                merchants += merchantsArr;
                merchantsFull += merchantsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  merchantsArr = [];
                  merchantsFull = [];
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
      if (isSearching) {
        endpoint =
            "/merchant?searchString=$currentSearch&page=$pageNum&size=10";
      } else {
        endpoint = "/merchant?page=$pageNum&size=10";
      }

      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var merchantsArrDecoded = resp.data["data"];
          if (merchantsArrDecoded != null) {
            var merchantsArr = List.from(merchantsArrDecoded);
            if (merchantsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                merchants += merchantsArr;
                merchantsFull += merchantsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  merchantsArr = [];
                  merchantsFull = [];
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

  Future<void> searchLeads(searchString) async {
    setState(() {
      currentSearch = searchString;
      pageNum = 1;
      isSearching = true;
      merchants = [];
      merchantsFull = [];
      onScroll();
    });
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(() {
      filterEmployee = employeeId;
      pageNum = 1;
      isFiltering = true;
      merchants = [];
      merchantsFull = [];
      onScroll();
    });
  }

  Future<void> clearSearch() async {
    setState(() {
      pageNum = 1;
      currentSearch = "";
      isSearching = false;
      _searchController.clear();
      merchants = [];
      merchantsFull = [];
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

  void openMerchant(merchant) {
    Navigator.pushNamed(context, "/viewmerchant",
        arguments: merchant["merchant"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),

      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("merchantsScreenAppBar"),
        title: Text("Merchants"),
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
      //   onPressed: openAddLeadForm,
      //   backgroundColor: Color.fromARGB(500, 1, 224, 143),
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
                    searchLeads(_searchController.text);
                    currentSearch = _searchController.text;
                  },
                  decoration: InputDecoration(
                    labelText: "Search Merchants",
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
                        searchLeads(_searchController.text);
                      },
                    ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          //   child: UserService.isAdmin
          //       ? EmployeeDropDown(callback: (val) {
          //           filterByEmployee(val);
          //         })
          //       : Container(),
          // ),
          isEmpty
              ? Empty("No merchants found")
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: merchants.map((merchant) {
                      var employeeName;
                      var nameIndex;

                      if (UserService.isAdmin) {
                        nameIndex = employees.indexWhere(
                            (e) => e["employee"] == merchant["employee"]);
                        if (nameIndex != -1) {
                          employeeName = employees[nameIndex]["title"];
                        } else {
                          employeeName = "Not Found";
                        }
                      }
                      var merchantDbaName;
                      var fullName;

                      if (merchant["document"]["dbaName"]?.isEmpty ?? true) {
                        merchantDbaName = "";
                      } else {
                        merchantDbaName = merchant["document"]["dbaName"];
                      }
                      if (merchant["document"]["firstName"]?.isEmpty ?? true) {
                        fullName = "";
                      } else {
                        fullName = merchant["document"]["firstName"] +
                            " " +
                            merchant["document"]["lastName"];
                      }

                      return GestureDetector(
                        onTap: () {
                          openMerchant(merchant);
                        },
                        child: CustomCard(
                          title: merchantDbaName,
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
                                          'Business Name:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Full Name:',
                                          style: TextStyle(
                                            fontSize: 15,
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
                                            merchantDbaName,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            fullName,
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
