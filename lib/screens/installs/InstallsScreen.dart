import 'dart:ui';
import 'package:atlascrm/components/install/InstallItem.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class InstallsScreen extends StatefulWidget {
  @override
  _InstallsScreenState createState() => _InstallsScreenState();
}

class _InstallsScreenState extends State<InstallsScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSearching = false;
  bool isFiltering = false;
  bool isLocFiltering = false;
  bool isLoading = true;
  bool isEmpty = true;
  bool isSaveDisabled;

  TimeOfDay initTime;
  DateTime initDate;

  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _calendarEvents;

  List installs = [];
  List installsFull = [];
  List activeInstalls = [];
  List unscheduledInstallsList = [];

  var installDateController = TextEditingController();
  var subscription;
  var filterEmployee = "";
  var employeeDropdownValue;
  var viewDate;
  var iDate;

  @override
  void initState() {
    super.initState();
    isSaveDisabled = false;
    _calendarController = CalendarController();
    _calendarEvents = {};
    initInstallData();
  }

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
    super.dispose();
  }

  Future<void> fillEvents() async {
    setState(() {
      _calendarEvents = {};
      for (var item in installs) {
        if (item["date"] != null) {
          var itemDate = DateTime.parse(item["date"]).toLocal();
          itemDate = DateTime(
              itemDate.year, itemDate.month, itemDate.day, 12, 0, 0, 0, 0);
          if (_calendarEvents[itemDate] == null) {
            _calendarEvents[itemDate] = [item];
          } else {
            _calendarEvents[itemDate].add(item);
          }
        } else {
          continue;
        }
      }
      if (_calendarController.selectedDay != null) {
        DateTime currentDay = _calendarController.selectedDay;
        setState(() {
          isEmpty = true;
        });
        _calendarEvents.forEach((key, value) {
          if (key.day == currentDay.day &&
              key.month == currentDay.month &&
              key.year == currentDay.year) {
            activeInstalls = value;

            setState(() {
              isEmpty = false;
            });
          }
        });
      } else {
        DateTime currentDay = DateTime.now();
        setState(() {
          isEmpty = true;
        });
        _calendarEvents.forEach(
          (key, value) {
            if (key.day == currentDay.day &&
                key.month == currentDay.month &&
                key.year == currentDay.year) {
              activeInstalls = value;

              setState(() {
                isEmpty = false;
              });
            }
          },
        );
      }
    });
  }

  Widget _buildCalendar() {
    return TableCalendar(
      initialSelectedDay: DateTime.now(),
      events: _calendarEvents,
      calendarController: _calendarController,
      headerStyle: HeaderStyle(formatButtonShowsNext: false),
      calendarStyle: CalendarStyle(),
      onDaySelected: (date, events, _) {
        setState(() {
          activeInstalls = events;
          if (activeInstalls.length == 0) {
            isEmpty = true;
          } else {
            isEmpty = false;
          }
        });
      },
    );
  }

  Future<void> initInstallData() async {
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "SUBSCRIBE_V_INSTALL",
      document: gql("""
          subscription SUBSCRIBE_V_INSTALL{
            v_install (order_by: {date: asc}) {
              install
              merchant
              merchantbusinessname
              employee
              employeefullname
              merchantdevice
              date
              location
              cash_discounting
              ticket_created
              ticket
            }
          }
        """),
      fetchPolicy: FetchPolicy.networkOnly,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    );

    subscription =
        await GqlClientFactory().authGqlsubscribe(options, (data) async {
      var installsArrDecoded = data.data["v_install"];
      if (installsArrDecoded != null && this.mounted) {
        setState(() {
          installs = installsArrDecoded;
          unscheduledInstallsList =
              installs.where((element) => element['date'] == null).toList();
          installsFull = installs;
          isLoading = false;
        });

        await fillEvents();
      }
      isLoading = false;
    }, (error) {}, () => refreshSub());
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initInstallData();
    }
  }

  Future<void> changeInstall(i) async {
    var successMsg = "Install claimed and ticket created!";
    var msgLength = Toast.LENGTH_SHORT;

    var installEmployee = employeeDropdownValue;
    var install = i['install'];
    var ticketStatus;
    var ticketCategory;
    var merchantName = i['merchantbusinessname'];
    var merchant = i['merchant'];

    var installDate = DateTime.parse(installDateController.text).toUtc();
    var installDateFormat = DateFormat("yyyy-MM-dd HH:mm").format(installDate);

    Map data;

    QueryOptions options = QueryOptions(
      document: gql("""
        query TICKET_STATUS {
          ticket_status{
            ticket_status
            title
          }
        }
      """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        result.data["ticket_status"].forEach((item) {
          if (item["title"] == "Scheduled For Install") {
            ticketStatus = item["ticket_status"];
          }
        });
      } else {
        print(new Error());
      }
    }

    QueryOptions ticketCategoryOptions = QueryOptions(
      document: gql("""
      query TICKET_CATEGORY{
        ticket_category{
          ticket_category
          title
        }
      }
    """),
    );

    final QueryResult ticketCategoryResult =
        await GqlClientFactory().authGqlquery(ticketCategoryOptions);

    if (ticketCategoryResult != null) {
      if (ticketCategoryResult.hasException == false) {
        ticketCategoryResult.data["ticket_category"].forEach((item) {
          if (item["title"] == "Install") {
            ticketCategory = item["ticket_category"];
          }
        });
        await initInstallData();
      } else {
        print(new Error());
      }
    }

    QueryOptions installDocumentOptions = QueryOptions(
      document: gql("""
      query GET_INSTALL_DOC(\$install: uuid!){
        install(where: {install: {_eq: \$install}}) {
          document
        }
      }
    """),
      variables: {
        "install": install,
      },
    );

    final QueryResult installDocumentResult =
        await GqlClientFactory().authGqlquery(installDocumentOptions);

    if (installDocumentResult != null) {
      if (installDocumentResult.hasException == false) {
        i["document"] = installDocumentResult.data["install"][0]["document"];
      } else {
        print(new Error());
      }
    }

    if (i["date"] != null || i['employee'] != "") {
      data = {
        "ticket_status": ticketStatus,
        "document": {
          " title": "Installation: $merchantName",
        },
        "is_active": true,
        "employee": installEmployee,
        "date": installDateFormat
      };

      confirmInstall(i);
    } else {
      var successMsg = "Install ticket updated!";
      var msgLength = Toast.LENGTH_SHORT;
      data = {
        "ticket_status": ticketStatus,
        "document": {
          " title": "Installation: $merchantName",
        },
        "is_active": true,
        "employee": null,
        "date": null
      };

      //updateInstall(i);
    }

    Fluttertoast.showToast(
        msg: successMsg,
        toastLength: msgLength,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.of(context).pop();
  }

  void confirmInstall(i) async {
    var installEmployee = employeeDropdownValue;
    var install = i['install'];
    var ticketStatus;
    var ticketCategory;
    var merchantName = i['merchantbusinessname'];
    var merchant = i['merchant'];

    var installDate = DateTime.parse(installDateController.text).toUtc();
    var installDateFormat = DateFormat("yyyy-MM-dd HH:mm").format(installDate);

    Map data;

    QueryOptions options = QueryOptions(
      document: gql("""
        query TICKET_STATUS {
          ticket_status{
            ticket_status
            title
          }
        }
      """),
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);

    if (result != null) {
      if (result.hasException == false) {
        result.data["ticket_status"].forEach((item) {
          if (item["title"] == "Scheduled For Install") {
            ticketStatus = item["ticket_status"];
          }
        });
      } else {
        print(new Error());
      }
    }

    QueryOptions ticketCategoryOptions = QueryOptions(
      document: gql("""
      query TICKET_CATEGORY{
        ticket_category{
          ticket_category
          title
        }
      }
    """),
    );

    final QueryResult ticketCategoryResult =
        await GqlClientFactory().authGqlquery(ticketCategoryOptions);

    if (ticketCategoryResult != null) {
      if (ticketCategoryResult.hasException == false) {
        ticketCategoryResult.data["ticket_category"].forEach((item) {
          if (item["title"] == "Install") {
            ticketCategory = item["ticket_category"];
          }
        });
        await initInstallData();
      } else {
        print(new Error());
      }
    }

    QueryOptions installDocumentOptions = QueryOptions(
      document: gql("""
      query GET_INSTALL_DOC(\$install: uuid!){
        install(where: {install: {_eq: \$install}}) {
          document
        }
      }
    """),
      variables: {
        "install": install,
      },
    );

    final QueryResult installDocumentResult =
        await GqlClientFactory().authGqlquery(installDocumentOptions);

    if (installDocumentResult != null) {
      if (installDocumentResult.hasException == false) {
        i["document"] = installDocumentResult.data["install"][0]["document"];
      } else {
        print(new Error());
      }
    }

    if (i["date"] != null || i['employee'] != "") {
      data = {
        "ticket_status": ticketStatus,
        "document": {
          " title": "Installation: $merchantName",
        },
        "is_active": true,
        "employee": installEmployee,
        "date": installDateFormat
      };

      MutationOptions mutateOptions = MutationOptions(document: gql("""
        mutation NEW_TICKET(
          \$document: jsonb!
          \$date: timestamptz!
          \$ticket_status: uuid!
          \$is_active: Boolean
        ) {
          insert_ticket(
            objects: {
              date: \$date
              document: \$document
              is_active: \$is_active
            }
          ) {
            returning {
              ticket
            }
          }
        }
        """), variables: {
        "document": data["document"],
        "date": data["date"],
        "ticket_status": data["ticket_status"],
        "is_active": data["is_active"],
      });

      final QueryResult result =
          await GqlClientFactory().authGqlmutate(mutateOptions);

      if (result.hasException) {
        Fluttertoast.showToast(
            msg: result.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
      var ticket = result.data["insert_ticket"]["returning"][0]["ticket"];

      MutationOptions insertAssigneeOptions = MutationOptions(
        document: gql("""
          mutation INSERT_TICKET_ASSIGNEE(\$ticket: uuid!, \$employee: uuid!){
            insert_ticket_assignee(
              objects: {ticket \$ticket, employee: \$employee}
            ) {
              returning {
                ticket_assignee
              }
            }
          }
        """),
        variables: {
          "ticket": ticket,
          "employee": data["employee"],
        },
      );

      final QueryResult insertAssigneeResult =
          await GqlClientFactory().authGqlmutate(insertAssigneeOptions);

      if (insertAssigneeResult.hasException) {
        Fluttertoast.showToast(
            msg: insertAssigneeResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }

      var ticketAssignee = result.data["insert_ticket_assignee"]["returning"][0]
          ["ticket_assignee"];

      MutationOptions insertTicketMerchantOptions = MutationOptions(
        document: gql("""
          mutation INSERT_TICKET_MERCHANT(\$merchant: uuid!, \$ticket: uuid!){
            insert_ticket_merchant(
              objects: {merchant: \$merchant, ticket: \$ticket}
            ){
              returning {
                ticket_merchant
              }
            }
          }
      """),
        variables: {
          "ticket": ticket,
          "merchant": merchant,
        },
      );

      final QueryResult insertTicketMerchantResult =
          await GqlClientFactory().authGqlmutate(insertTicketMerchantOptions);

      if (insertTicketMerchantResult.hasException) {
        Fluttertoast.showToast(
            msg: insertTicketMerchantResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }

      var ticketMerchant = result.data["insert_ticket_merchant"]["returning"][0]
          ["ticket_merchant"];

      MutationOptions insertTicketLabelOptions = MutationOptions(
        document: gql("""
          mutation INSERT_TICKET_LABEL(\$ticket_category: uuid!, \$ticket: uuid!){
            insert_ticket_label(
              objects: {ticket_category: \$ticket_category, ticket: \$ticket}
            ) {
              returning {
                ticket_label
              }
            }
          }
        """),
        variables: {
          "ticket": ticket,
          "ticket_category": ticketCategory,
        },
      );

      final QueryResult insertTicketLabelResult =
          await GqlClientFactory().authGqlmutate(insertTicketLabelOptions);

      if (insertTicketLabelResult.hasException) {
        Fluttertoast.showToast(
            msg: insertTicketMerchantResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }

      var ticketLabel =
          result.data["insert_ticket_label"]["returning"][0]["ticket_label"];

      MutationOptions updateInstallOptions = MutationOptions(
        document: gql("""
          mutation UPDATE_INSTALL_BY_PK(\$install: uuid!, \$ticket: uuid!){
            update_install_by_pk(
              pk_columns: {install: \$install}
              _set: {ticket: \$ticket}
            ) {
              install
            }
          }
        """),
        variables: {
          "install": install,
          "ticket": ticket,
        },
      );

      final QueryResult updateInstallResult =
          await GqlClientFactory().authGqlmutate(updateInstallOptions);

      if (updateInstallResult.hasException) {
        Fluttertoast.showToast(
            msg: updateInstallResult.exception.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }

      if (i['document'] != null) {
        MutationOptions insertTicketCommentOptions =
            MutationOptions(document: gql("""
          mutation INSERT_TICKET_COMMENT(\$ticket: uuid!, \$document: jsonb!, \$initial_comment: Boolean!){
            insert_ticket_comment_one(
              object: {
                ticket: \$ticket,
                document: \$document,
                initial_comment: \$initial_comment
              }
            ) {
              ticket_comment
            }
          }
        """), variables: {
          "document": i['document'],
          "ticket": ticket,
          "initial_comment": true,
        });

        final QueryResult insertTicketCommentResult =
            await GqlClientFactory().authGqlmutate(insertTicketCommentOptions);

        if (insertTicketCommentResult.hasException) {
          Fluttertoast.showToast(
              msg: updateInstallResult.exception.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        }

        MutationOptions updateInstallByPKOptions = MutationOptions(
          document: gql("""
          mutation UPDATE_INSTALL_BY_PK(\$install: uuid!, \$ticket_created: Boolean){
            update_install_by_pk (
              pk_columns: {install: \$install}
              _set: {ticket_created: \$ticket_created}
            ) {
              install
            }
          }
        """),
          variables: {
            "install": install,
            "ticket_created": true,
          },
        );

        final QueryResult updateInstallByPKResult =
            await GqlClientFactory().authGqlmutate(updateInstallByPKOptions);

        if (updateInstallByPKResult.hasException) {
          Fluttertoast.showToast(
              msg: updateInstallResult.exception.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    }
  }

  Widget installList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Search Installs",
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                var filtered = installsFull.where((e) {
                  String merchant = e["merchantbusinessname"];

                  return (merchant != null
                      ? merchant.toLowerCase().contains(value.toLowerCase())
                      : false);
                }).toList();

                setState(() {
                  activeInstalls = filtered.toList();
                  isEmpty = false;
                });
              } else {
                setState(() {
                  activeInstalls = [];
                  isEmpty = true;
                });
              }
            },
          ),
          _buildCalendar(),
          isEmpty
              ? Empty("No installs today")
              : Column(
                  children: activeInstalls.map((i) {
                    if (i['date'] != null) {
                      iDate = DateFormat("EEE, MMM d, ''yy")
                          .add_jm()
                          .format(DateTime.parse(i['date']).toLocal());
                      initDate = DateTime.parse(i['date']).toLocal();
                      initTime = TimeOfDay.fromDateTime(initDate);
                      viewDate = DateFormat("yyyy-MM-dd HH:mm")
                          .format(DateTime.parse(i['date']).toLocal());
                    } else {
                      iDate = "TBD";
                      initDate = DateTime.now();
                      initTime = TimeOfDay.fromDateTime(initDate);
                      viewDate = "";
                    }
                    return installScheduleForm(i, viewDate);
                  }).toList(),
                )
        ],
      ),
    );
  }

  Widget unscheduledInstalls() {
    return SingleChildScrollView(
      child: Column(
        children: [
          unscheduledInstallsList.length == 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Empty("No unscheduled installs"),
                )
              : Column(
                  children: unscheduledInstallsList.map((i) {
                    setState(() {
                      iDate = "TBD";
                      initDate = DateTime.now();
                      initTime = TimeOfDay.fromDateTime(initDate);
                      viewDate = "";
                    });
                    return installScheduleForm(i, viewDate);
                  }).toList(),
                )
        ],
      ),
    );
  }

  Widget getInstalls() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: "Search Installs"),
            onChanged: (value) {
              if (value.isNotEmpty) {
                var filtered = installsFull.where((e) {
                  String merchant = e["merchantbusinessname"];

                  return (merchant != null
                      ? merchant.toLowerCase().contains(value.toLowerCase())
                      : false);
                }).toList();

                setState(() {
                  activeInstalls = filtered.toList();
                  isEmpty = false;
                });
              } else {
                setState(() {
                  activeInstalls = [];
                  isEmpty = true;
                });
              }
            },
          ),
          _buildCalendar(),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Empty("No installs today"),
                )
              : Column(
                  children: activeInstalls.map((i) {
                    if (i['date'] != null) {
                      setState(() {
                        iDate = DateFormat("EEE, MMM d, ''yy")
                            .add_jm()
                            .format(DateTime.parse(i['date']).toLocal());
                        initDate = DateTime.parse(i['date']).toLocal();
                        initTime = TimeOfDay.fromDateTime(initDate);
                        viewDate = DateFormat("yyyy-MM-dd HH:mm")
                            .format(DateTime.parse(i['date']).toLocal());
                      });
                    } else {
                      setState(() {
                        iDate = "TBD";
                        initDate = DateTime.now();
                        initTime = TimeOfDay.fromDateTime(initDate);
                        viewDate = "";
                      });
                    }
                    return installScheduleForm(i, viewDate);
                  }).toList(),
                )
        ],
      ),
    );
  }

  Widget installScheduleForm(i, viewDate) {
    return GestureDetector(
      onTap: () {
        setState(() {
          installDateController.text = viewDate;
          employeeDropdownValue = i['employee'];
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  MaterialButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    child: i['date'] != null
                        ? Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          )
                        : Text(
                            'Schedule',
                            style: TextStyle(color: Colors.white),
                          ),
                    color: UniversalStyles.actionColor,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          isSaveDisabled = true;
                        });
                        await changeInstall(i);
                      }
                    },
                  )
                ],
                title: Text(
                  i["merchantbusinessname"],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: EmployeeDropDown(
                            value: i['employee'] ?? "",
                            callback: (val) {
                              setState(() {
                                employeeDropdownValue = val;
                              });
                            },
                          ),
                        ),
                        DateTimeField(
                          onEditingComplete: () =>
                              FocusScope.of(context).nextFocus(),
                          validator: (DateTime dateTime) {
                            if (dateTime == null) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                          decoration:
                              InputDecoration(labelText: "Install Date"),
                          format: DateFormat("yyyy-MM-dd HH:mm"),
                          controller: installDateController,
                          initialValue: viewDate.isEmpty
                              ? null
                              : DateTime.parse(viewDate),
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? initDate,
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  currentValue ?? DateTime.now(),
                                ),
                              );
                              return DateTimeField.combine(date, time);
                            } else {
                              return currentValue;
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      child: InstallItem(
        merchant: i["merchantbusinessname"],
        dateTime: iDate ?? "TBD",
        merchantDevice: i["merchantdevice"] ?? "No Terminal",
        employeeFullName: i["employeefullname"] ?? "",
        location: i["location"],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/dashboard");
        return false;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: CustomDrawer(),
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.calendar_today),
                ),
                Tab(
                  icon: Icon(Icons.schedule),
                )
              ],
            ),
            title: Text("Installs"),
          ),
          body: isLoading
              ? CenteredLoadingSpinner()
              : TabBarView(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: getInstalls(),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: unscheduledInstalls(),
                    ),
                  ],
                  physics: NeverScrollableScrollPhysics(),
                ),
        ),
      ),
    );
  }
}
