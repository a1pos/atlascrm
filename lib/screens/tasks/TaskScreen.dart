import 'dart:ui';

import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/lead/LeadsDropDown.dart';
import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/components/task/TaskPriorityDropDown.dart';
import 'package:atlascrm/components/task/TaskPriorityHigh.dart';
import 'package:atlascrm/components/task/TaskPriorityLow.dart';
import 'package:atlascrm/components/task/TaskPriorityMedium.dart';
import 'package:atlascrm/components/task/TaskTypeDropDown.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final ApiService apiService = ApiService();

  var isEmpty = false;
  var isLoading = true;
  var tasks = [];

  @override
  void initState() {
    super.initState();

    initTasks();
  }

  Future<void> initTasks() async {
    try {
      var resp = await apiService.authGet(
          context, "/task/for/${UserService.employee.employee}");
      if (resp != null) {
        if (resp.statusCode == 200) {
          var tasksArrDecoded = resp.data;
          if (tasksArrDecoded != null) {
            var temp = [];

            for (var item in tasksArrDecoded) {
              temp.add(item);
            }

            setState(() {
              tasks = temp;
              isLoading = false;
            });
          }
        }
      } else {}
    } catch (err) {
      print(err);
    }
  }

  Future<void> openAddTaskForm() async {
    var taskTitleController = TextEditingController();
    var taskDescController = TextEditingController();

    var leadDropdownValue;
    var taskTypeDropdownValue;
    var taskPriorityDropdownValue;
    var employeeDropdownValue;

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
                MaterialButton(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  color: Color.fromARGB(500, 1, 224, 143),
                  onPressed: () {},
                ),
              ],
              title: Text('Add New Task'),
              content: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Stack(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          EmployeeDropDown(
                            value: employeeDropdownValue,
                            callback: ((val) {
                              setState(() {
                                employeeDropdownValue = val;
                              });
                            }),
                          ),
                          TaskTypeDropDown(
                            value: taskTypeDropdownValue,
                            callback: ((val) {
                              setState(() {
                                taskTypeDropdownValue = val;
                              });
                            }),
                          ),
                          TaskPriorityDropDown(
                            value: taskPriorityDropdownValue,
                            callback: (val) {
                              setState(() {
                                taskPriorityDropdownValue = val;
                              });
                            },
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 8,
                                child: LeadsDropDown(
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
                                child: Text('asdf'),
                              ),
                            ],
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: "Title"),
                            controller: taskTitleController,
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
                                    color: Colors.greenAccent, width: 3.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 0.5),
                              ),
                              hintText: 'Description',
                            ),
                          ),
                          DateTimeField(
                            decoration: InputDecoration(labelText: "Date"),
                            format: DateFormat("yyyy-MM-dd HH:mm"),
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.combine(date, time);
                              } else {
                                return currentValue;
                              }
                            },
                          ),
                        ],
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
      setState(() {
        leadDropdownValue = null;
        taskPriorityDropdownValue = null;
        taskTypeDropdownValue = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("taskAppBar"),
        title: Text("Tasks"),
      ),
      body: isLoading
          ? LoadingScreen()
          : Container(
              padding: EdgeInsets.all(10),
              child: tasks.length == 0
                  ? Empty("No Tasks found")
                  : SingleChildScrollView(
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: tasks.map((t) {
                              switch (t["priority"]) {
                                case 0:
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, "/viewtask",
                                          arguments: t["task"]);
                                    },
                                    child: TaskPriorityHigh(
                                      title: t["title"],
                                      description: t["notes"],
                                      dateTime: t["date"],
                                    ),
                                  );
                                  break;
                                case 1:
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, "/viewtask",
                                          arguments: t["task"]);
                                    },
                                    child: TaskPriorityMedium(
                                      title: t["title"],
                                      description: t["notes"],
                                      dateTime: t["date"],
                                    ),
                                  );
                                  break;
                                case 2:
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, "/viewtask",
                                          arguments: t["task"]);
                                    },
                                    child: TaskPriorityLow(
                                      title: t["title"],
                                      description: t["notes"],
                                      dateTime: t["date"],
                                    ),
                                  );
                                  break;
                              }
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
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
}
