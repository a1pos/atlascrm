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

  Future<void> updateInstall(i) async {
    //if schedule vs update - create ticket on
    var successMsg = "Install claimed and ticket created!";
    var msgLength = Toast.LENGTH_SHORT;

    var installEmployee = employeeDropdownValue;
    var ticketStatus;
    var merchantName = i['merchantbusinessname'];

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
            ticketStatus = item["title"];
          }
        });
        await initInstallData();
      } else {
        print(new Error());
      }
    }
    var installDate = DateTime.parse(installDateController.text).toUtc();
    var installDateFormat = DateFormat("yyyy-MM-dd HH:mm").format(installDate);

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
    } else {
      data = {
        "ticket_status": ticketStatus,
        "document": {
          " title": "Installation: $merchantName",
        },
        "is_active": true,
        "employee": null,
        "date": null
      };
    }

    print(data);

    // Fluttertoast.showToast(
    //     msg: successMsg,
    //     toastLength: msgLength,
    //     gravity: ToastGravity.BOTTOM,
    //     backgroundColor: Colors.grey[600],
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    //     Navigator.of(context).pop();
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
          installDateController.text = viewDate ?? "";
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
                        await updateInstall(i);
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
                          initialValue:
                              viewDate != null ? DateTime.parse(viewDate) : "",
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: currentValue ?? viewDate ?? "",
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()));
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
          location: i["location"]),
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

/* Scaffold(
        backgroundColor: UniversalStyles.backgroundColor,
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          key: Key("inventoryscreenappbar"),
          title: Text("Installs"),
          action: <Widget>[],
        ),
        body: isLoading
            ? CenteredLoadingSpinner()
            : Container(padding: EdgeInsets.all(10), child: getInstalls()),
      ), */
