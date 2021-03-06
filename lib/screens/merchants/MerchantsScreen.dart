import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/CustomCard.dart';
import 'package:round2crm/components/shared/CustomDrawer.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class MerchantsScreen extends StatefulWidget {
  @override
  _MerchantsScreenState createState() => _MerchantsScreenState();
}

class _MerchantsScreenState extends State<MerchantsScreen> {
  bool isSearching = false;
  bool isFiltering = false;
  bool isLoading = true;
  bool isEmpty = true;

  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  var merchants = [];
  var employees = [];
  var employeesFull = [];
  var columns = [];

  var dropdownVal = "2";

  var currentSearch = "";
  var pageNum = 0;
  var filterEmployee = "";
  var sortQueries = [
    "boarded_date: desc",
    "boarded_date: asc",
    "merchantbusinessname: asc"
  ];
  var sortQuery = "merchantbusinessname: asc";

  @override
  void initState() {
    super.initState();
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

  var initParams =
      'offset: 0, limit: 10, order_by: {merchantbusinessname: asc}';
  Future<void> initMerchantsData() async {
    try {
      if (!UserService.isAdmin) {
        initParams =
            'offset: 0, limit: 10, order_by: {merchantbusinessname: asc}';
      }

      Future.delayed(Duration(seconds: 1), () {
        logger.i("Parameters for merchants: " + initParams);
      });

      QueryOptions options = QueryOptions(
        document: gql("""
        query GET_MERCHANTS {
          v_merchant($initParams) {
            merchant
            merchantfirstname
            merchantlastname
            merchantemailaddress
            merchantbusinessname
            city
            merchant_id
            merchantphonenumber
            lead
            is_active
            company_name
            boarded_date
            employeefullname
          }
        }
      """),
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          Future.delayed(Duration(seconds: 1), () {
            logger.i("Merchant data loaded");
          });

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
          Future.delayed(Duration(seconds: 1), () {
            logger.e("ERROR: Error getting merchants: " +
                result.exception.toString());
          });

          Fluttertoast.showToast(
            msg: "Error getting merchants: " + result.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      Future.delayed(Duration(seconds: 1), () {
        logger.e("ERROR: Error getting merchants: " + err.toString());
      });

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
      params =
          "offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where:{_and:[{is_active:{_eq: true}}]}";
      if (isSearching) {
        params =
            'offset: $offsetAmount, limit: $limitAmount, order_by: {$sortQuery}, where:{_and:[{is_active:{_eq: true}},{$searchParams}]}';
      }

      Future.delayed(Duration(seconds: 1), () {
        logger.i("Parameters for merchants onScroll: " + params);
      });

      QueryOptions options = QueryOptions(
        document: gql("""
          query GET_V_MERCHANTS {
            v_merchant($params) {
              updated_at
              merchant
              merchant_id
              merchantfirstname
              merchantlastname
              merchantemailaddress
              merchantdbaname
              merchantbusinessname
              merchantphonenumber
              lead
              is_active
              company_name
              boarded_date
            }
          }
      """),
      );

      final QueryResult result = await GqlClientFactory().authGqlquery(options);

      if (result != null) {
        if (result.hasException == false) {
          Future.delayed(Duration(seconds: 1), () {
            logger.i("Merchant data reloaded onScroll");
          });

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
              setState(
                () {
                  if (pageNum == 0) {
                    isEmpty = true;
                    merchantsArr = [];
                  }
                  isLoading = false;
                },
              );
            }
          }
        } else {
          Future.delayed(Duration(seconds: 1), () {
            logger.e("ERROR: Error getting merchant data onScroll: " +
                result.exception.toString());
          });

          Fluttertoast.showToast(
            msg: "Error getting merchant data onScroll: " +
                result.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      Future.delayed(Duration(seconds: 1), () {
        logger.e(
            "ERROR: Error getting merchant data onScroll: " + err.toString());
      });
    }
  }

  Future<void> searchMerchants(searchString) async {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Filtering merchants by search: " + searchString);
    });
    setState(
      () {
        currentSearch = searchString;
        pageNum = 0;
        isSearching = true;
        merchants = [];
        onScroll();
      },
    );
  }

  Future<void> filterByEmployee(employeeId) async {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Filtering merchants by employee: " + employeeId);
    });
    setState(() {
      filterEmployee = employeeId;
      pageNum = 0;
      isFiltering = true;
      merchants = [];
      onScroll();
    });
  }

  Future<void> clearFilter() async {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Filtering merchants cleared");
    });

    if (isFiltering) {
      setState(
        () {
          filterEmployee = "";
          pageNum = 0;
          isFiltering = false;
          merchants = [];
        },
      );
      onScroll();
    }
  }

  Future<void> clearSearch() async {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Filtering merchants by search cleared");
    });

    if (isSearching) {
      setState(
        () {
          pageNum = 0;
          currentSearch = "";
          isSearching = false;
          _searchController.clear();
          merchants = [];
        },
      );
      onScroll();
    }
  }

  void openMerchant(merchant) {
    Future.delayed(Duration(seconds: 1), () {
      logger.i(
        "Merchant opened: " +
            merchant["merchantbusinessname"] +
            " (" +
            merchant["merchant"] +
            ")",
      );
    });
    Navigator.pushNamed(
      context,
      "/viewmerchant",
      arguments: merchant["merchant"],
    );
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
          key: Key("merchantsScreenAppBar"),
          title: Text("Merchants"),
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
                    ].map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],
                        child: Text(
                          item['text'],
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(
                        () {
                          dropdownVal = newVal;
                          sortQuery = sortQueries[int.parse(dropdownVal)];
                          clearSearch();
                          pageNum = 0;
                          merchants = [];
                          onScroll();
                        },
                      );
                      Future.delayed(Duration(seconds: 1), () {
                        logger.i("Merchant sort changed: " + sortQuery);
                      });
                    },
                  ),
                ),
              ],
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
                          if (_searchController.text != "") {
                            searchMerchants(_searchController.text);
                            currentSearch = _searchController.text;
                          }
                        },
                      ),
                    ),
            ],
          ),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                  child: Empty("No merchants found"),
                )
              : Expanded(
                  flex: 6,
                  child: ListView(
                    controller: _scrollController,
                    children: merchants.map(
                      (merchant) {
                        var fullName = "";
                        var businessName = "";
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
                        if (merchant["merchantemailaddress"] != null) {
                          email = merchant["merchantemailaddress"];
                        }
                        if (merchant["merchantphonenumber"] != null) {
                          phone = merchant["merchantphonenumber"]
                              .replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'),
                                  (Match m) => "(${m[1]}) ${m[2]}-${m[3]}");
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
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
