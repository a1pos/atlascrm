import 'dart:ui';

import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/lead/LeadsDropDown.dart';
import 'package:atlascrm/screens/tasks/widgets/TaskPriorityHigh.dart';
import 'package:atlascrm/screens/tasks/widgets/TaskPriorityLow.dart';
import 'package:atlascrm/screens/tasks/widgets/TaskPriorityMedium.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final ApiService apiService = ApiService();

  var isEmpty = false;
  var tasks = [];

  var taskStatusDropDownValue;
  var taskPriorityDropDownValue;

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
            });
          }
        }
      } else {}
    } catch (err) {
      print(err);
    }
  }

  Future<void> openAddTaskForm() async {
    var taskTypes = [];
    var leadDropdownValue;
    var taskPriorites = [
      {"value": "0", "text": "High"},
      {"value": "1", "text": "Medium"},
      {"value": "2", "text": "Low"},
    ];

    var taskTypesResp = await apiService.authGet(context, "/taskTypes");
    if (taskTypesResp != null) {
      if (taskTypesResp.statusCode == 200) {
        var taskTypesArrDecoded = taskTypesResp.data;
        if (taskTypesArrDecoded != null) {
          for (var item in taskTypesArrDecoded) {
            taskTypes.add({
              "type": item["type"],
              "parent": item["parent"],
              "title": item["title"]
            });
          }
        }
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
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
                          DropdownButton<String>(
                            isExpanded: true,
                            value: taskStatusDropDownValue,
                            hint: Text("Type"),
                            items: taskTypes.map((dynamic item) {
                              if (item["parent"] != null) {
                                return DropdownMenuItem<String>(
                                  value: item["type"],
                                  child: Text('${item["title"]}'),
                                );
                              }

                              return DropdownMenuItem<String>(
                                value: item["type"],
                                child: Text(
                                  item["title"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                taskStatusDropDownValue = newValue;
                              });
                            },
                          ),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: taskPriorityDropDownValue,
                            hint: Text("Priority"),
                            items: taskPriorites.map((dynamic item) {
                              return DropdownMenuItem<String>(
                                value: item["value"],
                                child: Text(
                                  item["text"],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                taskPriorityDropDownValue = newValue;
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
                          )
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
        taskStatusDropDownValue = null;
        leadDropdownValue = null;
        taskPriorityDropDownValue = null;
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
      body: Container(
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
                            return TaskPriorityHigh(
                              title: t["title"],
                              description: t["notes"],
                              dateTime: t["date"],
                            );
                            break;
                          case 1:
                            return TaskPriorityMedium(
                              title: t["title"],
                              description: t["notes"],
                              dateTime: t["date"],
                            );
                            break;
                          case 2:
                            return TaskPriorityLow(
                              title: t["title"],
                              description: t["notes"],
                              dateTime: t["date"],
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
