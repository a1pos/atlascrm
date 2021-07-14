import 'dart:ui';
import 'package:logger/logger.dart';
import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/components/lead/LeadDropDown.dart';
import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/CustomDrawer.dart';
import 'package:round2crm/components/shared/EmployeeDropDown.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:round2crm/components/task/TaskPriorityDropDown.dart';
import 'package:round2crm/components/task/TaskItem.dart';
import 'package:round2crm/components/task/TaskTypeDropDown.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSaveDisabled;
  bool isLoading = true;
  bool isEmpty = true;

  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _calendarEvents;

  List tasks = [];
  List tasksFull = [];
  List activeTasks = [];

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  var taskTitleController = TextEditingController();
  var taskDescController = TextEditingController();
  var taskDateController = TextEditingController();

  var leadDropdownValue;
  var taskTypeDropdownValue;
  var taskPriorityDropdownValue;
  var employeeDropdownValue;
  var subscription;

  @override
  void initState() {
    super.initState();
    isSaveDisabled = false;
    _calendarController = CalendarController();
    _calendarEvents = {};
    initTasks();
  }

  @override
  dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
    super.dispose();
  }

  Future<void> fillEvents() async {
    setState(
      () {
        _calendarEvents = {};
        for (var item in tasks) {
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
          _calendarEvents.forEach((k, v) {
            if (k.day == currentDay.day &&
                k.month == currentDay.month &&
                k.year == currentDay.year) {
              activeTasks = v;
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
            (k, v) {
              if (k.day == currentDay.day &&
                  k.month == currentDay.month &&
                  k.year == currentDay.year) {
                activeTasks = v;
                setState(() {
                  isEmpty = false;
                });
              }
            },
          );
        }
      },
    );
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
          activeTasks = events;
          if (activeTasks.length == 0) {
            isEmpty = true;
          } else {
            isEmpty = false;
          }
        });
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Date selected on task calendar: " +
              date.toLocal().toString() +
              ", " +
              activeTasks.length.toString() +
              " tasks loaded");
        });
      },
    );
  }

  Future<void> initTasks() async {
    SubscriptionOptions options = SubscriptionOptions(
      operationName: "EMPLOYEE_TASKS",
      document: gql("""
          subscription EMPLOYEE_TASKS(\$employee: uuid!) {
            employee_by_pk(employee: \$employee) {
              tasks(where: {taskStatusByTaskStatus: {title: {_eq: "Open"}}}, order_by: {date: asc}) {
                task
                taskTypeByTaskType {
                  task_type
                  title
                }
                employee
                date
                priority
                task_status
                document
                merchant
                lead
                created_by
                updated_by
                created_at
              }
            }
          }
        """),
      fetchPolicy: FetchPolicy.noCache,
      variables: {"employee": "${UserService.employee.employee}"},
    );

    subscription =
        await GqlClientFactory().authGqlsubscribe(options, (data) async {
      var tasksArrDecoded = data.data["employee_by_pk"]["tasks"];
      if (tasksArrDecoded != null && this.mounted) {
        setState(() {
          tasks = tasksArrDecoded;
          tasksFull = tasks;
          isLoading = false;
        });
        await fillEvents();
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Tasks data loaded and events filled");
        });
      }
      isLoading = false;
    }, (error) {
      debugPrint("Error getting tasks: " + error.toString());
      logger.e("Error getting tasks: " + error.toString());
    }, () => refreshSub());
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initTasks();
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Tasks data refreshed");
      });
    }
  }

  Future<void> createTask() async {
    var successMsg = "Task created!";
    var msgLength = Toast.LENGTH_SHORT;
    var taskEmployee = UserService.isAdmin
        ? employeeDropdownValue
        : UserService.employee.employee;

    var openStatus;

    QueryOptions options = QueryOptions(
      document: gql("""
      query TASK_STATUS {
        task_status {
          task_status
          document
          title
        }
      }
    """),
    );

    final QueryResult result0 = await GqlClientFactory().authGqlquery(options);

    if (result0 != null) {
      if (result0.hasException == false) {
        result0.data["task_status"].forEach((item) {
          if (item["title"] == "Open") {
            openStatus = item["task_status"];
          }
        });

        await initTasks();
      } else {
        debugPrint(
            "Error getting task status: " + result0.exception.toString());
        logger.e("Error getting task status: " + result0.exception.toString());

        Fluttertoast.showToast(
          msg: "Error getting task status: " + result0.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
    var saveDate = DateTime.parse(taskDateController.text).toUtc();
    var saveDateFormat = DateFormat("yyyy-MM-dd HH:mm").format(saveDate);

    Map data = {
      "task_status": openStatus,
      "task_type": taskTypeDropdownValue,
      "priority": taskPriorityDropdownValue,
      "lead": leadDropdownValue,
      "employee": taskEmployee,
      "document": {
        "notes": taskDescController.text,
        "title": taskTitleController.text,
      },
      "date": saveDateFormat
    };

    try {
      MutationOptions options = MutationOptions(
        document: gql("""
        mutation INSERT_TASK(\$data: [task_insert_input!]! = {}) {
          insert_task(objects: \$data) {
            returning {
              task
            }
          }
        }
            """),
        fetchPolicy: FetchPolicy.noCache,
        variables: {"data": data},
      );

      final QueryResult result =
          await GqlClientFactory().authGqlmutate(options);

      if (result != null) {
        if (result.hasException == false) {
          Fluttertoast.showToast(
            msg: successMsg,
            toastLength: msgLength,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );

          await initTasks();
          Future.delayed(Duration(seconds: 1), () {
            logger.i("Task successfully added and task data reloaded");
          });
        } else {
          debugPrint(
              "Error inserting new task: " + result.exception.toString());
          logger.e("Error inserting new task: " + result.exception.toString());
          Fluttertoast.showToast(
            msg: "Error inserting new task: " + result.exception.toString(),
            toastLength: msgLength,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (err) {
      debugPrint("Error inserting new task: " + err.toString());
      logger.e("Error inserting new task: " + err.toString());
    }
    _formKey.currentState.reset();
  }

  Future<void> openAddTaskForm() async {
    Future.delayed(Duration(seconds: 1), () {
      logger.i("Add task form opened");
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              actions: <Widget>[
                !isSaveDisabled
                    ? MaterialButton(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: UniversalStyles.actionColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              isSaveDisabled = true;
                            });
                            await createTask();

                            Navigator.of(context).pop();
                            isSaveDisabled = false;
                          }
                        },
                      )
                    : Container(),
              ],
              title: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 7.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Add New Devices'),
                    GestureDetector(
                      onTap: () {
                        Future.delayed(Duration(seconds: 1), () {
                          logger.i("Add device form closed");
                        });

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
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: Stack(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: UserService.isAdmin == true
                                        ? EmployeeDropDown(
                                            value: employeeDropdownValue,
                                            callback: ((val) {
                                              setState(() {
                                                leadDropdownValue = null;
                                                employeeDropdownValue = val;
                                              });
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                logger.i(
                                                    "Employee changed to: " +
                                                        employeeDropdownValue);
                                              });
                                            }),
                                          )
                                        : Container(),
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  TaskTypeDropDown(
                                    value: taskTypeDropdownValue,
                                    callback: ((val) {
                                      setState(() {
                                        taskTypeDropdownValue = val;
                                      });
                                      Future.delayed(Duration(seconds: 1), () {
                                        logger.i("Task type changed to: " +
                                            taskTypeDropdownValue);
                                      });
                                    }),
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  TaskPriorityDropDown(
                                    value: taskPriorityDropdownValue,
                                    callback: (val) {
                                      setState(() {
                                        taskPriorityDropdownValue = val;
                                      });

                                      Future.delayed(Duration(seconds: 1), () {
                                        logger.i("Task priorty changed to: " +
                                            taskPriorityDropdownValue);
                                      });
                                    },
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 8,
                                        child: UserService.isAdmin &&
                                                employeeDropdownValue == null
                                            ? Container()
                                            : LeadDropDown(
                                                employeeId: UserService.isAdmin
                                                    ? employeeDropdownValue
                                                    : UserService
                                                        .employee.employee,
                                                value: leadDropdownValue,
                                                callback: (val) {
                                                  if (val != null) {
                                                    setState(() {
                                                      leadDropdownValue = val;
                                                    });
                                                    Future.delayed(
                                                        Duration(seconds: 1),
                                                        () {
                                                      logger.i(
                                                          "Lead value changed: " +
                                                              leadDropdownValue);
                                                    });
                                                  }
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    onEditingComplete: () =>
                                        FocusScope.of(context).nextFocus(),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        Future.delayed(Duration(seconds: 1),
                                            () {
                                          logger.i("No title entered");
                                        });

                                        return 'Please enter a title';
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.next,
                                    decoration:
                                        InputDecoration(labelText: "Title"),
                                    controller: taskTitleController,
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  DateTimeField(
                                    onEditingComplete: () =>
                                        FocusScope.of(context).nextFocus(),
                                    validator: (DateTime dateTime) {
                                      if (dateTime == null) {
                                        Future.delayed(Duration(seconds: 1),
                                            () {
                                          logger.i("No date entered");
                                        });

                                        return 'Please select a date';
                                      }
                                      return null;
                                    },
                                    decoration:
                                        InputDecoration(labelText: "Date"),
                                    format: DateFormat("yyyy-MM-dd HH:mm"),
                                    controller: taskDateController,
                                    onShowPicker:
                                        (context, currentValue) async {
                                      final date = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1900),
                                        initialDate:
                                            currentValue ?? DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                            currentValue ?? DateTime.now(),
                                          ),
                                        );
                                        return DateTimeField.combine(
                                            date, time);
                                      } else {
                                        return currentValue;
                                      }
                                    },
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  TextField(
                                    maxLines: 10,
                                    controller: taskDescController,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.greenAccent,
                                            width: 3.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 0.5),
                                      ),
                                      hintText: 'Description',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((val) {
      _formKey.currentState.reset();
      setState(() {
        employeeDropdownValue = null;
        leadDropdownValue = null;
        taskPriorityDropdownValue = null;
        taskTypeDropdownValue = null;
        taskTitleController.text = null;
        taskDateController.text = null;
        taskDescController.text = null;
      });
    });
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
        appBar: CustomAppBar(key: Key("taskAppBar"), title: Text("Tasks")),
        body: isLoading
            ? CenteredLoadingSpinner()
            : Container(
                padding: EdgeInsets.all(10),
                child: getTasks(),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: openAddTaskForm,
          backgroundColor: UniversalStyles.actionColor,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          splashColor: Colors.white,
        ),
      ),
    );
  }

  Widget getTasks() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Search Tasks",
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                Future.delayed(Duration(seconds: 1), () {
                  logger.i("Tasks filtered by search: " + value.toString());
                });

                var filtered = tasksFull.where((e) {
                  String title = e["document"]["title"];
                  String notes = e["document"]["notes"];

                  return (title != null || title != ""
                      ? title.toLowerCase().contains(value.toLowerCase()) ||
                          notes.toLowerCase().contains(value.toLowerCase())
                      : false);
                }).toList();

                setState(() {
                  activeTasks = filtered.toList();

                  if (activeTasks.length > 0) {
                    isEmpty = false;
                  } else {
                    isEmpty = true;
                  }
                });
              } else {
                setState(() {
                  activeTasks = [];
                  isEmpty = true;
                  fillEvents();
                });
              }
            },
          ),
          _buildCalendar(),
          isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Empty("No Active Tasks today"),
                )
              : Column(
                  children: activeTasks.map((t) {
                    var tDate;
                    if (t['date'] != null) {
                      tDate = DateFormat("EEE, MMM d, ''yy")
                          .add_jm()
                          .format(DateTime.parse(t['date']).toLocal());
                    } else {
                      tDate = "";
                    }
                    return GestureDetector(
                      onTap: () {
                        Future.delayed(Duration(seconds: 1), () {
                          logger.i("Task opened: " +
                              t["document"]["title"] +
                              "(" +
                              t["task"] +
                              ")");
                        });

                        Navigator.pushNamed(context, "/viewtask",
                            arguments: t["task"]);
                      },
                      child: TaskItem(
                          title: t["document"]["title"],
                          description: t["document"]["notes"],
                          dateTime: tDate,
                          type: t["taskTypeByTaskType"]["title"],
                          priority: t["priority"]),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
