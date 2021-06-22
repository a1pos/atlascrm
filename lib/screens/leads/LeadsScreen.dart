import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'LeadStepper.dart';

class LeadsScreen extends StatefulWidget {
  @override
  _LeadsScreenState createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  bool isSearching = false;
  bool isFiltering = false;
  bool salesIncludeStale = false;
  bool isLoading = true;
  bool isEmpty = true;

  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  var leads = [];
  var employees = [];
  var employeesFull = [];
  var columns = [];

  var dropdownVal = "2";

  var currentDate;
  var currentSearch = "";
  var pageNum = 0;
  var filterEmployee = "";
  var sortQueries = [
    "leadcreatedat: desc",
    "leadcreatedat: asc",
    "leadbusinessname: asc"
  ];
  var sortQuery = "leadbusinessname: asc";

  @override
  void initState() {
    super.initState();
    if (UserService.isAdmin) {}
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

  getCurrentDateTime() {
    currentDate = DateFormat.yMd().add_jm().format(DateTime.now()).toString();

    return currentDate;
  }

  Future<void> openStaleModal(lead) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stale Lead'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This lead is stale, would you like to claim it?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                openLead(lead);
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 17, color: Colors.green),
              ),
              onPressed: () async {
                Map data = {
                  "employee": UserService.employee.employee,
                  "is_stale": false
                };

                MutationOptions mutateOptions = MutationOptions(
                  document: gql("""
                      mutation UPDATE_LEAD (\$data: lead_set_input){
                        update_lead_by_pk(pk_columns: {lead: "${lead["lead"]}"}, _set: \$data){
                          lead
                        }
                      }
                  """),
                  fetchPolicy: FetchPolicy.noCache,
                  variables: {"data": data},
                );
                final QueryResult result =
                    await GqlClientFactory().authGqlmutate(mutateOptions);

                if (result.hasException == false) {
                  Fluttertoast.showToast(
                      msg: "Lead Claimed!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.of(context).pop();
                  openLead(lead);
                } else {
                  Fluttertoast.showToast(
                    msg: "Failed to claim lead!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey[600],
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  var initParams = "offset: 0, limit: 10, order_by: {leadbusinessname: asc}";
  Future<void> initLeadsData() async {
    try {
      if (!UserService.isAdmin) {
        if (salesIncludeStale) {
          initParams =
              'offset: 0, limit: 10, order_by: {leadbusinessname: asc}, where: {_or: [{employee: {_eq: "${UserService.employee.employee}"}}, {stale: {_eq: true}}]}';
        } else {
          initParams =
              'offset: 0, limit: 10, order_by: {leadbusinessname: asc}, where: {employee: {_eq: "${UserService.employee.employee}"}}';
        }
      }

      QueryOptions options = QueryOptions(
        document: gql("""
          query GET_LEADS {
            v_lead($initParams) {
              lead
              updated_at
              employee
              employeefullname
              leadbusinessname
              leadfirstname
              leadlastname
              stale
              text
            }
          }
      """),
        fetchPolicy: FetchPolicy.noCache,
      );

      final result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          var leadsArrDecoded = result.data["v_lead"];
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(
                () {
                  isEmpty = false;
                  isLoading = false;
                  leads += leadsArr;
                  pageNum++;
                },
              );
            } else {
              setState(
                () {
                  if (pageNum == 1) {
                    isEmpty = true;
                    leadsArr = [];
                  }
                  isLoading = false;
                },
              );
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
      setState(
        () {
          isLoading = false;
        },
      );
    } catch (err) {
      print(err);
      setState(
        () {
          isLoading = false;
        },
      );
    }
  }

  Future<void> onScroll() async {
    try {
      var offsetAmount = pageNum * 10;
      var limitAmount = 10;
      var params;

      var searchParams =
          '	_or: [{leadbusinessname: {_ilike: "%$currentSearch%"}}, {employeefullname: {_ilike: "%$currentSearch%"}}, {leademailaddress: {_ilike: "%$currentSearch%"}}, {leadfirstname: {_ilike: "%$currentSearch%"}}, {leadlastname: {_ilike: "%$currentSearch%"}}, {leaddbaname: {_ilike: "%$currentSearch%"}}, {leadphonenumber: {_ilike: "%$currentSearch%"}},]';
      if (UserService.isAdmin || UserService.isSalesManager) {
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
        if (salesIncludeStale) {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {_and:[{_or: [{employee: {_eq: "${UserService.employee.employee}"}},{stale: {_eq: true}}]},{$searchParams}]}';
        } else {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "${UserService.employee.employee}"}, $searchParams}';
        }
      } else {
        if (salesIncludeStale) {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {_or: [{employee: {_eq: "${UserService.employee.employee}"}}, {stale: {_eq: true}}]}';
        } else {
          params =
              'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where: {employee: {_eq: "${UserService.employee.employee}"}}';
        }
      }

      QueryOptions options = QueryOptions(
        document: gql("""
          query GET_LEADS {
            v_lead($params) {
              lead
              updated_at
              employee
              employeefullname
              leadbusinessname
              leadfirstname
              leadlastname
              stale
              text
            }
          }
      """),
        fetchPolicy: FetchPolicy.noCache,
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          var leadsArrDecoded = result.data["v_lead"];
          if (leadsArrDecoded != null) {
            var leadsArr = List.from(leadsArrDecoded);
            if (leadsArr.length > 0) {
              setState(
                () {
                  isEmpty = false;
                  isLoading = false;
                  leads += leadsArr;
                  pageNum++;
                },
              );
            } else {
              setState(
                () {
                  if (pageNum == 0) {
                    isEmpty = true;
                    leadsArr = [];
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
      print(err);
    }
  }

  Future<void> searchLeads(searchString) async {
    setState(
      () {
        currentSearch = searchString;
        pageNum = 0;
        isSearching = true;
        leads = [];
        onScroll();
      },
    );
  }

  Future<void> filterByEmployee(employeeId) async {
    setState(
      () {
        filterEmployee = employeeId;
        pageNum = 0;
        isFiltering = true;
        leads = [];
        onScroll();
      },
    );
  }

  Future<void> clearFilter() async {
    if (isFiltering) {
      setState(
        () {
          filterEmployee = "";
          pageNum = 0;
          isFiltering = false;
          leads = [];
        },
      );
      onScroll();
    }
  }

  Future<void> clearSearch() async {
    if (isSearching) {
      setState(
        () {
          pageNum = 0;
          currentSearch = "";
          isSearching = false;
          _searchController.clear();
          leads = [];
        },
      );
      onScroll();
    }
  }

  Future<void> toggleStale(value) async {
    clearSearch();
    setState(
      () {
        pageNum = 0;
        currentSearch = "";
        isSearching = false;
        _searchController.clear();
        leads = [];
        salesIncludeStale = value;
      },
    );
    onScroll();
  }

  void openAddLeadForm() {
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
                Text('Add New Lead'),
                GestureDetector(
                  onTap: () {
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/dashboard");
        return false;
      },
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          key: Key("leadsScreenAppBar"),
          title: Text("Leads"),
          action: <Widget>[
            Row(
              children: <Widget>[
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
                    ].map<DropdownMenuItem<String>>(
                      (item) {
                        return DropdownMenuItem<String>(
                          value: item['value'],
                          child: Text(
                            item['text'],
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (newVal) {
                      setState(
                        () {
                          dropdownVal = newVal;
                          sortQuery = sortQueries[int.parse(dropdownVal)];
                          clearSearch();
                          pageNum = 0;
                          leads = [];
                          onScroll();
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
        body: Container(
            padding: EdgeInsets.all(10),
            child: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  Duration(seconds: 1),
                  () {
                    setState(() {
                      pageNum = 0;
                      isLoading = true;
                      sortQuery = sortQueries[int.parse(dropdownVal)];
                      clearSearch();
                      toggleStale(false);
                    });

                    currentDate = getCurrentDateTime();

                    Fluttertoast.showToast(
                      msg: "Refresh completed at " + currentDate,
                      toastLength: Toast.LENGTH_LONG,
                    );
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: Expanded(
                      child:
                          isLoading ? CenteredLoadingSpinner() : getDataTable(),
                    ),
                  ),
                ],
              ),
            )),
        floatingActionButton: FloatingActionButton(
          onPressed: openAddLeadForm,
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
                      backgroundColor: UniversalStyles.actionColor,
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
            child: UserService.isAdmin || UserService.isSalesManager
                ? EmployeeDropDown(
                    callback: (val) {
                      if (val != null) {
                        filterByEmployee(val);
                      } else {
                        clearFilter();
                      }
                    },
                  )
                : Row(
                    children: [
                      Switch(
                        activeColor: UniversalStyles.themeColor,
                        value: salesIncludeStale,
                        onChanged: (value) {
                          toggleStale(value);
                        },
                      ),
                      Text("Show all Stale leads")
                    ],
                  ),
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
                    children: leads.map(
                      (lead) {
                        var employeeName;
                        var fullName = "";
                        var businessName = "";

                        if (lead["employeefullname"] != null) {
                          employeeName = lead["employeefullname"];
                        } else {
                          employeeName = "Not Found";
                        }

                        if (lead["leadfirstname"] != null &&
                            lead["leadlastname"] != null) {
                          fullName = lead["leadfirstname"] +
                              " " +
                              lead["leadlastname"];
                        } else if (lead["leadfirstname"] != null) {
                          fullName = lead["leadfirstname"];
                        }
                        if (lead["leadbusinessname"] != null) {
                          businessName = lead["leadbusinessname"];
                        }

                        return GestureDetector(
                          onTap: () {
                            lead["stale"] &&
                                    !UserService.isSalesManager &&
                                    !UserService.isAdmin
                                ? openStaleModal(lead)
                                : openLead(lead);
                          },
                          child: CustomCard(
                            trailing: lead["stale"]
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      border: Border.all(
                                        color: Colors.orange[50],
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "Stale",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.orange[400],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : lead["text"] == "Boarded"
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          border: Border.all(
                                            color: Colors.green[50],
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "Boarded",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.green[400],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                            color: Colors.white,
                            title: businessName,
                            icon: Icons.arrow_forward_ios,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                UserService.isAdmin ||
                                        UserService.isSalesManager ||
                                        lead["stale"]
                                    ? Divider(thickness: 2)
                                    : Container(),
                                UserService.isAdmin ||
                                        UserService.isSalesManager ||
                                        lead["stale"]
                                    ? Row(
                                        mainAxisAlignment: lead["stale"]
                                            ? MainAxisAlignment.spaceEvenly
                                            : MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Employee: " + employeeName,
                                            style: TextStyle(),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
