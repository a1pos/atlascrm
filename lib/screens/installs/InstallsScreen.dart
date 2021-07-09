import 'dart:ui';
import 'package:round2crm/components/install/InstallScheduleForm.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/shared/EmployeeDropDown.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/components/shared/CustomDrawer.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class InstallsScreen extends StatefulWidget {
  @override
  _InstallsScreenState createState() => _InstallsScreenState();
}

class _InstallsScreenState extends State<InstallsScreen> {
  bool isLoading = true;
  bool isEmpty = true;
  bool installsIncludeAll = false;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  TimeOfDay initTime;
  DateTime initDate;
  DateTime daySelected;

  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _calendarEvents;

  List installs = [];
  List activeInstalls = [];
  List unscheduledInstallsList = [];

  var unscheduledInstallCount = 0;
  var installDateController = TextEditingController();
  var subscription;
  var filterEmployee = "";
  var employeeDropdownValue;
  var viewDate;
  var iDate;

  @override
  void initState() {
    super.initState();
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
      for (var item in activeInstalls) {
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
      initialSelectedDay: daySelected ?? DateTime.now(),
      events: _calendarEvents,
      calendarController: _calendarController,
      headerStyle: HeaderStyle(formatButtonShowsNext: false),
      calendarStyle: CalendarStyle(),
      initialCalendarFormat: CalendarFormat.twoWeeks,
      onDaySelected: (date, events, _) {
        setState(() {
          daySelected = date;
          activeInstalls = events;
          if (activeInstalls.length == 0) {
            isEmpty = true;
          } else {
            isEmpty = false;
          }
        });
        logger.i("Day selected: " +
            daySelected.toString() +
            ", events found on day: " +
            activeInstalls.length.toString());
      },
    );
  }

  Future<void> initInstallData() async {
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "SUBSCRIBE_V_INSTALL",
      document: gql("""
          subscription SUBSCRIBE_V_INSTALL {
            v_install_table (order_by: {date: asc}) {
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
              ticket_open
            }
          }
        """),
      fetchPolicy: FetchPolicy.noCache,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    );

    subscription =
        await GqlClientFactory().authGqlsubscribe(options, (data) async {
      var installsArrDecoded = data.data["v_install_table"];
      if (installsArrDecoded != null && this.mounted) {
        setState(() {
          installs = installsArrDecoded;
          unscheduledInstallsList =
              installs.where((element) => element['date'] == null).toList();
          unscheduledInstallCount = unscheduledInstallsList.length;
          activeInstalls = installs;
          isLoading = false;
        });

        await fillEvents();
        logger.i("Installs data initialized and events filled on calendar");
      }
      isLoading = false;
    }, (error) {
      debugPrint("Error initializing installs: " + error.toString());
      logger.e("Error initializing installs: " + error.toString());
    }, () => refreshSub());
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initInstallData();
      logger.i("Refreshing installs subscription");
    }
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
                  children: unscheduledInstallsList.map(
                    (i) {
                      setState(() {
                        iDate = "TBD";
                        initDate = DateTime.now();
                        initTime = TimeOfDay.fromDateTime(initDate);
                        viewDate = "";
                      });
                      return InstallScheduleForm(
                        i,
                        viewDate,
                        iDate,
                        unscheduled: true,
                      );
                    },
                  ).toList(),
                )
        ],
      ),
    );
  }

  Widget getInstalls() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: "Search Installs"),
            onChanged: (value) {
              if (value.isNotEmpty) {
                var filtered = installs.where((e) {
                  String merchant = e["merchantbusinessname"];
                  String location = e["location"];

                  return (merchant != null || merchant != ""
                      ? merchant.toLowerCase().contains(value.toLowerCase()) ||
                          location.toLowerCase().contains(value)
                      : false);
                }).toList();

                setState(() {
                  employeeDropdownValue = "";

                  activeInstalls = filtered.toList();

                  if (activeInstalls.length > 0) {
                    isEmpty = false;
                    logger.i("Search performed for " +
                        value.toString() +
                        " and " +
                        activeInstalls.length.toString() +
                        " events found");
                  } else {
                    isEmpty = true;
                    logger.i("Search performed for " +
                        value.toString() +
                        " but no events were found");
                  }
                });
              } else {
                setState(() {
                  activeInstalls = installs;
                  isEmpty = true;
                  fillEvents();
                });
              }
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 0, 5),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Row(
                      children: [
                        Switch(
                          activeColor: UniversalStyles.themeColor,
                          value: installsIncludeAll,
                          onChanged: (bool value) {
                            if (value) {
                              var iFiltered = installs
                                  .where((e) => e["ticket_open"] == value)
                                  .toList();
                              setState(() {
                                activeInstalls = iFiltered.toList();
                                installsIncludeAll = value;
                              });
                            } else {
                              setState(() {
                                activeInstalls = installs;
                                installsIncludeAll = value;
                              });
                            }
                            fillEvents();
                            logger.i("Active Installs switch tapped to " +
                                value.toString() +
                                " and events filtered");
                          },
                        ),
                        Text("Active Installs"),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: EmployeeDropDown(
                    value: employeeDropdownValue,
                    callback: (val) {
                      if (val != null) {
                        var eFiltered = installs.where((e) {
                          String employee = e["employee"];
                          return (employee != null
                              ? employee
                                  .toLowerCase()
                                  .contains(val.toLowerCase())
                              : false);
                        }).toList();

                        setState(() {
                          activeInstalls = eFiltered.toList();
                          isEmpty = false;
                        });
                      } else {
                        setState(() {
                          activeInstalls = installs;
                          isEmpty = true;
                        });
                      }
                      fillEvents();
                      logger.i("Employee filter switched to " +
                          val.toString() +
                          " and events filtered");
                    },
                    roles: ["tech", "corporate_tech"],
                  ),
                ),
              ],
            ),
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
                        iDate = DateFormat("EEEE, MMM d, yyyy")
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
                    return InstallScheduleForm(
                      i,
                      viewDate,
                      iDate,
                      unscheduled: false,
                    );
                  }).toList(),
                )
        ],
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
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                Tab(
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 25,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: unscheduledInstallCount > 0
                            ? Container(
                                padding: EdgeInsets.all(2),
                                decoration: new BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  '${unscheduledInstallCount.toString()}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
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
