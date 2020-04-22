import 'package:atlascrm/components/lead/LeadDropDown.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/task/TaskPriorityDropDown.dart';
import 'package:atlascrm/components/task/TaskTypeDropDown.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/config/ConfigSettings.dart';

import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String taskId;

  EditTaskScreen(this.taskId);

  @override
  EditTaskScreenState createState() => EditTaskScreenState();
}

class EditTaskScreenState extends State<EditTaskScreen> {
  final ApiService apiService = ApiService();
  var isLoading = true;

  var taskTitleController = TextEditingController();
  var taskDateController = TextEditingController();
  var taskDescController = TextEditingController();


  var task;

  var employeeDropdownValue;
  var taskTypeDropdownValue;
  var taskPriorityDropdownValue;
  var leadDropdownValue;
  DateTime initDate;
  TimeOfDay initTime;
  @override
  void initState() {
    super.initState();

    loadTaskData();
  }

  Future<void> loadTaskData() async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/task/" + this.widget.taskId);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;
        initDate = DateTime.parse(bodyDecoded["date"]);
        initTime = TimeOfDay.fromDateTime(initDate);
        setState(() {
          task = bodyDecoded;
          taskTypeDropdownValue = bodyDecoded["type"];
          employeeDropdownValue = bodyDecoded["owner"];
          taskPriorityDropdownValue = bodyDecoded["priority"].toString();
          taskTitleController.text = bodyDecoded["document"]["title"];
          taskDateController.text = bodyDecoded["date"];
          taskDescController.text = bodyDecoded["document"]["notes"];
          leadDropdownValue = bodyDecoded["lead"];
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateTask() async {
   try {
      var token = ConfigSettings.ACCESS_TOKEN;
      var data = {
        "task": task["task"],
        "status": task["status"],
        "type": taskTypeDropdownValue,
        "owner": employeeDropdownValue,
        "date": taskDateController.text,
        "priority": taskPriorityDropdownValue,
        "lead": leadDropdownValue,
        "document": {
          "title": taskTitleController.text,
          "notes": taskDescController.text,
          "eventid": task["document"]["eventid"],
        }
      };
      var resp1 = await apiService.authPut(
          context, "/googlecalendar/"+ token, data);
      if (resp1 != null) {
        if (resp1.statusCode == 200) {
          Fluttertoast.showToast(
              msg: "Successfully updated Calendar Event!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
          var event = resp1.data["eventid"];
          print('TASK: ' + task["task"]);
          data["document"]["eventid"] = event;
        }
      } else {
        throw new Error();
      }
      var resp = await apiService.authPut(
          context, "/task/" + task["task"], data);
      if (resp != null) {
        if (resp.statusCode == 200) {
          Fluttertoast.showToast(
              msg: "Successfully updated task!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);

          Navigator.pushNamed(context, "/tasks");
        }
      } else {
        throw new Error();
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(
          msg: "Failed to update task for employee!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

  }

  Future<void> deleteTask() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: Key("viewTasksAppBar"),
        title: Text(isLoading ? "Loading..." : task["document"]["title"]),
      ),
      body: isLoading
          ? CenteredClearLoadingScreen()
          : Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: "Title"),
                      controller: taskTitleController,
                      // validator: validate,
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    EmployeeDropDown(
                      value: employeeDropdownValue,
                      callback: ((val) {
                        setState(() {
                          employeeDropdownValue = val;
                        });
                      }),
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
                        DateTimeField(
                          decoration: InputDecoration(labelText: "Date"),
                          format: DateFormat("yyyy-MM-dd HH:mm"),
                          controller: taskDateController,
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
                                  initialTime: initTime
                                );
                                return DateTimeField.combine(date, time);
                              } else {
                                return currentValue;
                              }
                            },
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
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await updateTask();
        },
        backgroundColor: Color.fromARGB(500, 1, 224, 143),
        child: Icon(Icons.save),
      ),
    );
  }
}