import 'dart:developer';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MerchantsScreen extends StatefulWidget {
  @override
  _MerchantsScreenState createState() => _MerchantsScreenState();
}

class _MerchantsScreenState extends State<MerchantsScreen> {
  var merchants = [];
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
    "merchantbusinessname: asc"
  ];
  var sortQuery = "merchantbusinessname: asc";
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (UserService.isAdmin) {
      // initEmployeeData();
    }
    initMerchantssData();

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

  var initParams =
      "offset: 0, limit: 10, order_by: {merchantbusinessname: asc}";
  Future<void> initMerchantssData() async {
    try {
      if (!UserService.isAdmin) {
        initParams =
            'offset: 0, limit: 10, order_by: {merchantbusinessname: asc}';
      }
// Maybe add subs in eventually? --------
      // Operation options =
      //     Operation(operationName: "GetAllMerchants", documentNode: gql("""
      //     subscription GetAllMerchants {
      //       v_merchant($initParams) {
      //         merchant
      //         updated_at
      //         employee
      //         employeefullname
      //         merchantbusinessname
      //         merchantfirstname
      //         merchantlastname
      //       }
      //     }
      //       """));

      // var result = wsClient.subscribe(options);
      // result.listen(
      //   (data) async {
      //     var merchantsArrDecoded = data.data["v_merchant"];
      //     if (merchantsArrDecoded != null) {
      //       var merchantsArr = List.from(merchantsArrDecoded);
      //       if (merchantsArr.length > 0) {
      //         setState(() {
      //           isEmpty = false;
      //           isLoading = false;
      //           merchants += merchantsArr;
      //           pageNum++;
      //         });
      //       }
      //     } else {
      //       setState(() {
      //         if (pageNum == 1) {
      //           isEmpty = true;
      //           // merchantsArr = [];
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
      //         msg: "Failed to load merchants for employee!",
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         backgroundColor: Colors.grey[600],
      //         textColor: Colors.white,
      //         fontSize: 16.0);
      //   },
      // );

      QueryOptions options = QueryOptions(documentNode: gql("""
          query GetAllMerchants {
            v_merchant($initParams) {
              updated_at
              merchant
              merchantfirstname
              merchantlastname
              merchantemailaddress
              merchantdbaname
              merchantbusinessname
              merchantphonenumber
            }
          }
      """), fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await client.query(options);

      if (result != null) {
        if (result.hasException == false) {
          var merchantsArrDecoded = result.data["v_merchant"];
          if (merchantsArrDecoded != null) {
            var merchantsArr = List.from(merchantsArrDecoded);
            if (merchantsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                merchants += merchantsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 1) {
                  isEmpty = true;
                  merchantsArr = [];
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
          '	_or: [{merchantbusinessname: {_ilike: "%$currentSearch%"}}, {merchantemailaddress: {_ilike: "%$currentSearch%"}}, {merchantfirstname: {_ilike: "%$currentSearch%"}}, {merchantlastname: {_ilike: "%$currentSearch%"}}, {merchantdbaname: {_ilike: "%$currentSearch%"}}, {merchantphonenumber: {_ilike: "%$currentSearch%"}},]';
      if (UserService.isAdmin) {
        params =
            "offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}";
        if (isSearching) {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {$searchParams}';
        }
        // EMPLOYEE FILTERING
        // if (isFiltering) {
        //   params =
        //       'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}}';
        // }
        // if (isSearching && isFiltering) {
        //   params =
        //       'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "$filterEmployee"}, $searchParams}';
        // }
      } else if (isSearching) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "${UserService.employee.employee}"}, $searchParams}';
      } else {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "${UserService.employee.employee}"}';
      }
      // Maybe add subs in eventually?----------
      // Operation options =
      //     Operation(operationName: "GetAllMerchants", documentNode: gql("""
      //     subscription GetAllMerchants {
      //       v_merchant($params) {
      //         merchant
      //         updated_at
      //         employee
      //         employeefullname
      //         merchantbusinessname
      //         merchantfirstname
      //         merchantlastname
      //       }
      //     }
      //       """));

      // var result = wsClient.subscribe(options);

      // result.listen(
      //   (data) async {
      //     var merchantsArrDecoded = data.data["v_merchant"];
      //     if (merchantsArrDecoded != null) {
      //       var merchantsArr = List.from(merchantsArrDecoded);
      //       if (merchantsArr.length > 0) {
      //         setState(() {
      //           for (var incLead in merchantsArr) {
      //             for (var currentLead in merchants) {
      //               if (incLead["merchant"] == currentLead["merchant"]) {
      //                 var oldIndex = merchants.indexOf(currentLead);
      //                 merchants[oldIndex] = incLead;
      //                 var newIndex = merchantsArr.indexOf(incLead);
      //                 merchantsArr.removeAt(newIndex);
      //               }
      //             }
      //           }
      //           isEmpty = false;
      //           isLoading = false;
      //           merchants += merchantsArr;
      //           pageNum++;
      //         });
      //       }
      //       isLoading = false;
      //     } else {
      //       setState(() {
      //         if (pageNum == 1) {
      //           isEmpty = true;
      //           // merchantsArr = [];
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
      //         msg: "Failed to load merchants for employee!",
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         backgroundColor: Colors.grey[600],
      //         textColor: Colors.white,
      //         fontSize: 16.0);
      //   },
      // );

      QueryOptions options = QueryOptions(documentNode: gql("""
          query GetAllMerchant {
            v_merchant($params) {
              updated_at
              merchant
              merchantfirstname
              merchantlastname
              merchantemailaddress
              merchantdbaname
              merchantbusinessname
              merchantphonenumber
            }
          }
      """), fetchPolicy: FetchPolicy.networkOnly);

      final QueryResult result = await client.query(options);

      if (result != null) {
        if (result.hasException == false) {
          var merchantsArrDecoded = result.data["v_merchant"];
          if (merchantsArrDecoded != null) {
            var merchantsArr = List.from(merchantsArrDecoded);
            if (merchantsArr.length > 0) {
              setState(() {
                isEmpty = false;
                isLoading = false;
                merchants += merchantsArr;
                pageNum++;
              });
            } else {
              setState(() {
                if (pageNum == 0) {
                  isEmpty = true;
                  merchantsArr = [];
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

  Future<void> searchMerchants(searchString) async {
    setState(() {
      currentSearch = searchString;
      pageNum = 0;
      isSearching = true;
      merchants = [];
      onScroll();
    });
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(() {
      filterEmployee = employeeId;
      pageNum = 0;
      isFiltering = true;
      merchants = [];
      onScroll();
    });
  }

  Future<void> clearFilter() async {
    if (isFiltering) {
      setState(() {
        filterEmployee = "";
        pageNum = 0;
        isFiltering = false;
        merchants = [];
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
        merchants = [];
      });
      onScroll();
    }
  }

  Future<void> initEmployeeData() async {
    try {
      var endpoint = "/employee";
      var resp;
      //REPLACE WITH GRAPHQL
      // var resp = await this.widget.apiService.authGet(context, endpoint);
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
      backgroundColor: UniversalStyles.backgroundColor,
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
          key: Key("merchantsScreenAppBar"),
          title: Text("Merchants"),
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
                            merchants = [];
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
                    searchMerchants(_searchController.text);
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
                  : CircleAvatar(
                      radius: 25,
                      backgroundColor: UniversalStyles.actionColor,
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          currentSearch = _searchController.text;
                          searchMerchants(_searchController.text);
                        },
                      ),
                    ),
            ],
          ),
          //EMPLOYEE DROPDOWN FILTER
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          //   child: UserService.isAdmin
          //       ? EmployeeDropDown(callback: (val) {
          //           if (val != null) {
          //             filterByEmployee(val);
          //           } else {
          //             clearFilter();
          //           }
          //         })
          //       : Container(),
          // ),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                  child: Empty("No merchants found"),
                )
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: merchants.map((merchant) {
                      var employeeName;

                      if (UserService.isAdmin) {
                        if (merchant["employeefullname"] != null) {
                          employeeName = merchant["employeefullname"];
                        } else {
                          employeeName = "Not Found";
                        }
                      }
                      var fullName = "";
                      var businessName = "";
                      var dbaName = "";
                      var email = "";
                      var phone = "";

                      if (merchant["merchantfirstname"] != null &&
                          merchant["merchantlastname"] != null) {
                        fullName = merchant["merchantfirstname"] +
                            " " +
                            merchant["merchantlastname"];
                      } else if (merchant["merchantfirstname"] != null) {
                        fullName = merchant["merchantfirstname"];
                      }
                      if (merchant["merchantbusinessname"] != null) {
                        businessName = merchant["merchantbusinessname"];
                      }
                      if (merchant["merchantdbaname"] != null) {
                        dbaName = merchant["merchantdbaname"];
                      }
                      if (merchant["merchantemailaddress"] != null) {
                        email = merchant["merchantemailaddress"];
                      }
                      if (merchant["merchantphonenumber"] != null) {
                        phone = merchant["merchantphonenumber"];
                      }

                      return GestureDetector(
                        onTap: () {
                          openMerchant(merchant);
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
                                          'DBA:',
                                          style: TextStyle(
                                            fontSize: 15,
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
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Email:',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Phone:',
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
                                            dbaName,
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
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            '$email',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            '$phone',
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
                              //INCLUDE EMPLOYEE NAME ON CARDS
                              // UserService.isAdmin
                              //     ? Divider(thickness: 2)
                              //     : Container(),
                              // UserService.isAdmin
                              //     ? Text("Employee: " + employeeName,
                              //         style: TextStyle(),
                              //         textAlign: TextAlign.right)
                              //     : Container(),
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
