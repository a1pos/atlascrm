import 'dart:ui';
import 'dart:developer';
import 'dart:convert';

import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:atlascrm/components/lead/LeadDropDown.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/components/task/TaskPriorityDropDown.dart';
import 'package:atlascrm/components/task/TaskItem.dart';
import 'package:atlascrm/components/task/TaskTypeDropDown.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/screens/leads/LeadStepper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  final ApiService apiService = ApiService();
  final StorageService storageService = new StorageService();
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _calendarEvents;

  final _formKey = GlobalKey<FormState>();
  var isEmpty = true;
  var isLoading = true;

  var tasks = [];
  var tasksFull = [];
  var activeTasks = [];

  var taskTitleController = TextEditingController();
  var taskDescController = TextEditingController();
  var taskDateController = TextEditingController();

  var leadDropdownValue;
  var taskTypeDropdownValue;
  var taskPriorityDropdownValue;
  var employeeDropdownValue;

  bool isSaveDisabled;
  @override
  void initState() {
    super.initState();
    isSaveDisabled = false;
    _calendarController = CalendarController();
    _calendarEvents = {};
    initTasks();
  }

  Future<void> fillEvents() async {
    setState(() {
      _calendarEvents = {};
      for (var item in tasks) {
        if (item["date"] != null) {
          var itemDate = DateTime.parse(item["date"]);
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
      onDaySelected: (date, events) {
        setState(() {
          activeTasks = events;
          if (activeTasks.length == 0) {
            isEmpty = true;
          } else {
            isEmpty = false;
          }
        });
      },
      // code to replace bubbles with numbers on calendar
      // builders: CalendarBuilders(
      //   markersBuilder: (context, date, events, holidays) {
      //     final children = <Widget>[];

      //     if (events.isNotEmpty) {
      //       children.add(
      //         Positioned(
      //           right: 1,
      //           bottom: 1,
      //           child: AnimatedContainer(
      //             duration: const Duration(milliseconds: 300),
      //             decoration: BoxDecoration(
      //               shape: BoxShape.rectangle,
      //               color: _calendarController.isSelected(date)
      //                   ? Colors.orange[500]
      //                   : _calendarController.isToday(date)
      //                       ? Colors.orange[300]
      //                       : Colors.blue[400],
      //             ),
      //             width: 16.0,
      //             height: 16.0,
      //             child: Center(
      //               child: Text(
      //                 '${events.length}',
      //                 style: TextStyle().copyWith(
      //                   color: Colors.white,
      //                   fontSize: 12.0,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       );
      //     }

      //     if (holidays.isNotEmpty) {
      //       children.add(
      //         Positioned(
      //           right: -2,
      //           top: -2,
      //           child: Icon(
      //             Icons.add_box,
      //             size: 20.0,
      //             color: Colors.blueGrey[800],
      //           ),
      //         ),
      //       );
      //     }

      //     return children;
      //   },
      // )
    );
  }

  Future<void> initTasks() async {
    Operation options =
        Operation(operationName: "EmployeeTasks", documentNode: gql("""
          subscription EmployeeTasks(\$employee: uuid!) {
            employee_by_pk(employee: \$employee) {
              tasks {
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
            """), variables: {"employee": "${UserService.employee.employee}"});

    var result = client.subscribe(options);
    result.listen(
      (data) async {
        var tasksArrDecoded = data.data["employee_by_pk"]["tasks"];
        if (tasksArrDecoded != null) {
          setState(() {
            tasks = tasksArrDecoded;
            // activeTasks = tasks.where((e) => e["document"]["active"]).toList();
            tasksFull = tasks;
            // if (tasks.length > 0) {}
            isLoading = false;
          });
          await fillEvents();
        }
        isLoading = false;
      },
      onError: (error) {
        print(error);
        isLoading = false;

        Fluttertoast.showToast(
            msg: "Failed to load tasks for employee!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      },
    );
  }

  Future newCalendarEvent(token, data) async {
    var taskEmployee = UserService.isAdmin
        ? employeeDropdownValue
        : UserService.employee.employee;
    var resp1 = await this.widget.apiService.authPost(
        context, "/googlecalendar/" + token + "/" + taskEmployee, data);
    if (resp1 != null) {
      if (resp1.statusCode == 200) {
        var event = await resp1.data["eventid"];
        return event;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> createTask() async {
    var successMsg = "Task created, but couldn't add Calendar Event!";
    var msgLength = Toast.LENGTH_SHORT;
    var taskEmployee = UserService.isAdmin
        ? employeeDropdownValue
        : UserService.employee.employee;
    var token = UserService.googleSignInAuthentication.accessToken;

    var openStatus;

    QueryOptions options = QueryOptions(documentNode: gql("""
      query TaskStatus {
        task_status {
          task_status
          document
          title
        }
      }
    """));

    final QueryResult result0 = await client.query(options);

    if (result0 != null) {
      if (result0.hasException == false) {
        result0.data["task_status"].forEach((item) {
          if (item["title"] == "Open") {
            openStatus = item["task_status"];
          }
        });

        await initTasks();
      }
    } else {
      print(new Error());
      throw new Error();
    }

    var timeNow = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());

    Map data = {
      "task_status": openStatus,
      "task_type": taskTypeDropdownValue,
      "priority": taskPriorityDropdownValue,
      "lead": leadDropdownValue,
      "employee": taskEmployee,
      "document": {
        "notes": taskDescController.text,
        "title": taskDescController.text,
        "active": true,
        "eventid": null
      },
      "date": taskDateController.text,
      "created_by": "16a9424f-4c7d-44d7-87cd-029b3d13ad6d",
      "created_at": timeNow,
      "updated_by": "16a9424f-4c7d-44d7-87cd-029b3d13ad6d",
      "updated_at": timeNow
    };

    //GOOGLECALENDAR LOGIC
    // var event = await newCalendarEvent(token, data);
    // if (event != null) {
    //   data["document"]["eventid"] = event;
    //   successMsg = "Successfully created task!";
    //   msgLength = Toast.LENGTH_LONG;
    // }

    try {
      MutationOptions options = MutationOptions(documentNode: gql("""
        mutation InsertTask(\$data: [task_insert_input!]! = {}) {
          insert_task(objects: \$data) {
            returning {
              task
            }
          }
        }
            """), variables: {"data": data});

      final QueryResult result = await client.mutate(options);

      if (result != null) {
        if (result.hasException == false) {
          Fluttertoast.showToast(
              msg: successMsg,
              toastLength: msgLength,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);

          await initTasks();
        }
      } else {
        print(new Error());
        throw new Error();
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(
          msg: "Failed to create task for employee!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
    _formKey.currentState.reset();
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
            child: LeadStepper(successCallback: () {
              initTasks();
            }),
          ),
        );
      },
    );
  }

  Future<void> openAddTaskForm() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    'Cancel',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                !isSaveDisabled
                    ? MaterialButton(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Color.fromARGB(500, 1, 224, 143),
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
              title: Text('Add New Task'),
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
                                              }),
                                            )
                                          : Container()),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  TaskTypeDropDown(
                                    value: taskTypeDropdownValue,
                                    callback: ((val) {
                                      setState(() {
                                        taskTypeDropdownValue = val;
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
                                    },
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 8,
                                        child: LeadDropDown(
                                          employeeId: UserService.isAdmin ==
                                                  true
                                              ? employeeDropdownValue
                                              : UserService.employee.employee,
                                          value: leadDropdownValue,
                                          callback: (val) {
                                            setState(() {
                                              leadDropdownValue = val;
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 13, 0, 0),
                                          child: IconButton(
                                            icon: Icon(Icons.add),
                                            color: Color.fromARGB(
                                                500, 1, 224, 143),
                                            onPressed: (() {
                                              openAddLeadForm();
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    onEditingComplete: () =>
                                        FocusScope.of(context).nextFocus(),
                                    validator: (value) {
                                      if (value.isEmpty) {
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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 242, 242),
      drawer: CustomDrawer(),
      appBar: CustomAppBar(key: Key("taskAppBar"), title: Text("Tasks")),
      body: isLoading
          ? LoadingScreen()
          : Container(
              padding: EdgeInsets.all(10),
              child: getTasks(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTaskForm,
        backgroundColor: Color.fromARGB(500, 1, 224, 143),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        splashColor: Colors.white,
      ),
    );
  }

  Widget taskList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Search Tasks",
            ),
            onChanged: (value) {
              var filtered = tasksFull.where((e) {
                String title = e["document"]["title"];
                String notes = e["document"]["notes"];
                return title.toLowerCase().contains(value.toLowerCase()) ||
                    notes.toLowerCase().contains(value.toLowerCase());
              }).toList();

              setState(() {
                activeTasks = filtered.toList();
              });
            },
          ),
          _buildCalendar(),
          isEmpty
              ? Empty("No Active Tasks today")
              : Column(
                  children: activeTasks.map((t) {
                    var tDate;
                    if (t['date'] != null) {
                      tDate = DateFormat("EEE, MMM d, ''yy")
                          .add_jm()
                          .format(DateTime.parse(t['date']));
                    } else {
                      tDate = "";
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/viewtask",
                            arguments: t["task"]);
                      },
                      child: TaskItem(
                          title: t["document"]["title"],
                          description: t["document"]["notes"],
                          dateTime: tDate,
                          type: t["typetitle"],
                          priority: t["priority"]),
                    );
                  }).toList(),
                ),
        ],
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
              var filtered = tasksFull.where((e) {
                String title = e["document"]["title"];
                String notes = e["document"]["notes"];
                return title.toLowerCase().contains(value.toLowerCase()) ||
                    notes.toLowerCase().contains(value.toLowerCase());
              }).toList();

              setState(() {
                activeTasks = filtered.toList();
              });
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
                          .format(DateTime.parse(t['date']));
                    } else {
                      tDate = "";
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/viewtask",
                            arguments: t["task"]);
                      },
                      child: TaskItem(
                          title: t["document"]["title"],
                          description: t["document"]["notes"],
                          dateTime: tDate,
                          type: t["typetitle"],
                          priority: t["priority"]),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
