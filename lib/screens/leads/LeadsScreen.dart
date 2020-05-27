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

import 'LeadStepper.dart';

class LeadsScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  _LeadsScreenState createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  var leads = [];
  var leadsFull = [];
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
    initLeadsData();

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

  Future<void> initLeadsData() async {
    try {
      var endpoint = UserService.isAdmin
          ? "/lead?page=$pageNum&size=10&$sortQuery"
          : "/employee/${UserService.employee.employee}/lead?page=$pageNum&size=10&$sortQuery";
      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var leadsArrDecoded = resp.data["data"];
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                leads += leadsArr;
                leadsFull += leadsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  leadsArr = [];
                  leadsFull = [];
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
        endpoint = "/lead?page=$pageNum&size=10&$sortQuery";
        if (isSearching) {
          endpoint =
              "/lead?searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
        }
        if (isFiltering) {
          endpoint =
              "/employee/$filterEmployee/lead?page=$pageNum&size=10&$sortQuery";
        }
        if (isSearching && isFiltering) {
          endpoint =
              "/employee/$filterEmployee/lead?searchString=$currentSearch&page=$pageNum&size=10&$sortQuery";
        }
      } else {
        endpoint =
            "/employee/${UserService.employee.employee}/lead?page=$pageNum&size=10&$sortQuery";
      }

      var resp = await this.widget.apiService.authGet(context, endpoint);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var leadsArrDecoded = resp.data["data"];
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                leads += leadsArr;
                leadsFull += leadsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  leadsArr = [];
                  leadsFull = [];
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
      leads = [];
      leadsFull = [];
      onScroll();
    });
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(() {
      filterEmployee = employeeId;
      pageNum = 1;
      isFiltering = true;
      leads = [];
      leadsFull = [];
      onScroll();
    });
  }

  Future<void> clearSearch() async {
    setState(() {
      pageNum = 1;
      currentSearch = "";
      isSearching = false;
      _searchController.clear();
      leads = [];
      leadsFull = [];
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

  void openAddLeadForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Lead'),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: LeadStepper(
              successCallback: initLeadsData,
            ),
          ),
        );
      },
    );
  }

  void openLead(lead) {
    Navigator.pushNamed(context, "/viewlead", arguments: lead["lead"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("leadsScreenAppBar"),
        title: Text("Leads"),
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
        onPressed: openAddLeadForm,
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
                    searchLeads(_searchController.text);
                    currentSearch = _searchController.text;
                  },
                  decoration: InputDecoration(
                    labelText: "Search Leads",
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: UserService.isAdmin
                ? EmployeeDropDown(callback: (val) {
                    filterByEmployee(val);
                  })
                : Container(),
          ),
          isEmpty
              ? Empty("No leads found")
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: leads.map((lead) {
                      var employeeName;
                      var nameIndex;

                      if (UserService.isAdmin) {
                        nameIndex = employees.indexWhere(
                            (e) => e["employee"] == lead["employee"]);
                        if (nameIndex != -1) {
                          employeeName = employees[nameIndex]["title"];
                        } else {
                          employeeName = "Not Found";
                        }
                      }
                      var fullName;
                      var businessName;
                      if (lead["document"]?.isEmpty ?? true) {
                        fullName = "";
                        businessName = "";
                      } else {
                        fullName = lead["document"]["firstName"] +
                            " " +
                            lead["document"]["lastName"];
                        businessName = lead["document"]["businessName"];
                      }

                      return GestureDetector(
                        onTap: () {
                          openLead(lead);
                        },
                        child: CustomCard(
                          title: businessName,
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
                                          'Business:',
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
                                            businessName,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            '$fullName',
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
