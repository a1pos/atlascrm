import 'dart:developer';

import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'LeadStepper.dart';

class LeadsScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  _LeadsScreenState createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  var leads = [];
  var employees = [];
  var employeesFull = [];
  var columns = [];

  var isLoading = true;
  var isEmpty = true;

  bool isSearching = false;
  bool isFiltering = false;

  var dropdownVal = "2";

  var currentSearch = "";
  var pageNum = 0;
  var filterEmployee = "";
  var sortQueries = [
    "updated_at: desc",
    "updated_at: asc",
    "leadbusinessname: asc"
  ];
  var sortQuery = "leadbusinessname: asc";
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (UserService.isAdmin) {
      // initEmployeeData();
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

  var initParams = "offset: 0, limit: 10, order_by: {leadbusinessname: asc}";
  Future<void> initLeadsData() async {
    try {
      if (!UserService.isAdmin) {
        initParams =
            'offset: 0, limit: 10, order_by: {leadbusinessname: asc}, where: {employee: {_eq: "${UserService.employee.employee}"}}';
      }
      print(initParams);
// Maybe add subs in eventually? --------
      // Operation options =
      //     Operation(operationName: "GetAllLeads", documentNode: gql("""
      //     subscription GetAllLeads {
      //       v_lead($initParams) {
      //         lead
      //         updated_at
      //         employee
      //         employeefullname
      //         leadbusinessname
      //         leadfirstname
      //         leadlastname
      //       }
      //     }
      //       """));

      // var result = wsClient.subscribe(options);
      // result.listen(
      //   (data) async {
      //     var leadsArrDecoded = data.data["v_lead"];
      //     if (leadsArrDecoded != null) {
      //       var leadsArr = List.from(leadsArrDecoded);
      //       if (leadsArr.length > 0) {
      //         setState(() {
      //           isEmpty = false;
      //           isLoading = false;
      //           leads += leadsArr;
      //           pageNum++;
      //         });
      //       }
      //     } else {
      //       setState(() {
      //         if (pageNum == 1) {
      //           isEmpty = true;
      //           // leadsArr = [];
      //         }
      //       });
      //     }
      //   },
      //   onError: (error) {
      //     print("STREAM LISTEN ERROR: " + error);
      //     setState(() {
      //       isLoading = false;
      //     });

      //     Fluttertoast.showToast(
      //         msg: "Failed to load leads for employee!",
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         backgroundColor: Colors.grey[600],
      //         textColor: Colors.white,
      //         fontSize: 16.0);
      //   },
      // );

      QueryOptions options = QueryOptions(documentNode: gql("""
          query GetAllLeads {
            v_lead($initParams) {
              lead
              updated_at
              employee
              employeefullname
              leadbusinessname
              leadfirstname
              leadlastname
            }
          }
      """), fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await client.query(options);

      if (result != null) {
        if (result.hasException == false) {
          var leadsArrDecoded = result.data["v_lead"];
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                leads += leadsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  leadsArr = [];
                }
                isLoading = false;
              });
            }
          }
        } else {
          Fluttertoast.showToast(
              msg: result.exception.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      log(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> onScroll() async {
    try {
      var offsetAmount = pageNum * 10;
      var limitAmount = 10;
      var params;
      var searchParams =
          '	_or: [{leadbusinessname: {_ilike: "%$currentSearch%"}}, {employeefullname: {_ilike: "%$currentSearch%"}}, {leademailaddress: {_ilike: "%$currentSearch%"}}, {leadfirstname: {_ilike: "%$currentSearch%"}}, {leadlastname: {_ilike: "%$currentSearch%"}}, {leaddbaname: {_ilike: "%$currentSearch%"}}, {leadphonenumber: {_ilike: "%$currentSearch%"}},]';
      if (UserService.isAdmin) {
        params =
            "offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}";
        if (isSearching) {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {$searchParams}';
        }
        if (isFiltering) {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}}';
        }
        if (isSearching && isFiltering) {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}, $searchParams}';
        }
      } else if (isSearching) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "${UserService.employee.employee}"}, $searchParams}';
      } else {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "${UserService.employee.employee}"}';
      }

      // Operation options =
      //     Operation(operationName: "GetAllLeads", documentNode: gql("""
      //     subscription GetAllLeads {
      //       v_lead($params) {
      //         lead
      //         updated_at
      //         employee
      //         employeefullname
      //         leadbusinessname
      //         leadfirstname
      //         leadlastname
      //       }
      //     }
      //       """));

      // var result = wsClient.subscribe(options);

      // result.listen(
      //   (data) async {
      //     var leadsArrDecoded = data.data["v_lead"];
      //     if (leadsArrDecoded != null) {
      //       var leadsArr = List.from(leadsArrDecoded);
      //       if (leadsArr.length > 0) {
      //         setState(() {
      //           for (var incLead in leadsArr) {
      //             for (var currentLead in leads) {
      //               if (incLead["lead"] == currentLead["lead"]) {
      //                 var oldIndex = leads.indexOf(currentLead);
      //                 leads[oldIndex] = incLead;
      //                 var newIndex = leadsArr.indexOf(incLead);
      //                 leadsArr.removeAt(newIndex);
      //               }
      //             }
      //           }
      //           isEmpty = false;
      //           isLoading = false;
      //           leads += leadsArr;
      //           pageNum++;
      //         });
      //       }
      //       isLoading = false;
      //     } else {
      //       setState(() {
      //         if (pageNum == 1) {
      //           isEmpty = true;
      //           // leadsArr = [];
      //         }
      //         isLoading = false;
      //       });
      //     }
      //   },
      //   onError: (error) {
      //     print("STREAM LISTEN ERROR: " + error);
      //     setState(() {
      //       isLoading = false;
      //     });

      //     Fluttertoast.showToast(
      //         msg: "Failed to load leads for employee!",
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         backgroundColor: Colors.grey[600],
      //         textColor: Colors.white,
      //         fontSize: 16.0);
      //   },
      // );

      QueryOptions options = QueryOptions(documentNode: gql("""
          query GetAllLeads {
            v_lead($params) {
              lead
              updated_at
              employee
              employeefullname
              leadbusinessname
              leadfirstname
              leadlastname
            }
          }
      """), fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await client.query(options);

      if (result != null) {
        if (result.hasException == false) {
          var leadsArrDecoded = result.data["v_lead"];
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                leads += leadsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  leadsArr = [];
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
      pageNum = 0;
      isSearching = true;
      leads = [];
      onScroll();
    });
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(() {
      filterEmployee = employeeId;
      pageNum = 0;
      isFiltering = true;
      leads = [];
      onScroll();
    });
  }

  Future<void> clearFilter() async {
    if (isFiltering) {
      setState(() {
        filterEmployee = "";
        pageNum = 0;
        isFiltering = false;
        leads = [];
      });
      onScroll();
    }
  }

  Future<void> clearSearch() async {
    if (isSearching) {
      setState(() {
        pageNum = 0;
        currentSearch = "";
        isSearching = false;
        _searchController.clear();
        leads = [];
      });
      onScroll();
    }
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
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
          key: Key("leadsScreenAppBar"),
          title: Text("Leads"),
          action: <Widget>[
            Row(
              children: <Widget>[
                // Icon(Icons.sort),
                Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.grey.shade900,
                    ),
                    child: DropdownButton(
                        value: dropdownVal,
                        items: [
                          {'value': '0', 'text': 'Newest'},
                          {'value': '1', 'text': 'Oldest'},
                          {'value': '2', 'text': 'Alphabetical'}
                        ].map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['value'],
                            child: Text(item['text'],
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          setState(() {
                            dropdownVal = newVal;
                            sortQuery = sortQueries[int.parse(dropdownVal)];
                            clearSearch();
                            pageNum = 0;
                            leads = [];
                            onScroll();
                          });
                        })),
              ],
            )
          ]),
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
                  : CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromARGB(500, 1, 224, 143),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          currentSearch = _searchController.text;
                          searchLeads(_searchController.text);
                        },
                      ),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: UserService.isAdmin
                ? EmployeeDropDown(callback: (val) {
                    if (val != null) {
                      filterByEmployee(val);
                    } else {
                      clearFilter();
                    }
                  })
                : Container(),
          ),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                  child: Empty("No leads found"),
                )
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: leads.map((lead) {
                      var employeeName;

                      if (UserService.isAdmin) {
                        if (lead["employeefullname"] != null) {
                          employeeName = lead["employeefullname"];
                        } else {
                          employeeName = "Not Found";
                        }
                      }
                      var fullName = "";
                      var businessName = "";

                      if (lead["leadfirstname"] != null &&
                          lead["leadlastname"] != null) {
                        fullName =
                            lead["leadfirstname"] + " " + lead["leadlastname"];
                      } else if (lead["leadfirstname"] != null) {
                        fullName = lead["leadfirstname"];
                      }
                      if (lead["leadbusinessname"] != null) {
                        businessName = lead["leadbusinessname"];
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
