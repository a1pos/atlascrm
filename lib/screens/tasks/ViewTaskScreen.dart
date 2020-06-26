import 'package:atlascrm/components/lead/LeadDropDown.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/task/TaskPriorityDropDown.dart';
import 'package:atlascrm/components/task/TaskTypeDropDown.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ViewTaskScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();
  final StorageService storageService = new StorageService();

  final String taskId;

  ViewTaskScreen(this.taskId);

  @override
  ViewTaskScreenState createState() => ViewTaskScreenState();
}

class ViewTaskScreenState extends State<ViewTaskScreen> {
  final ApiService apiService = ApiService();
  var isLoading = true;

  var taskTitleController = TextEditingController();
  var taskDateController = TextEditingController();
  var taskDescController = TextEditingController();

  var task;
  bool isChanged = false;
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

  changeButton() {
    setState(() {
      isChanged = true;
    });
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
        var viewDate = DateFormat("yyyy-MM-dd HH:mm").format(initDate);
        setState(() {
          task = bodyDecoded;
          taskTypeDropdownValue = bodyDecoded["type"];
          employeeDropdownValue = bodyDecoded["owner"];
          taskPriorityDropdownValue = bodyDecoded["priority"].toString();
          taskTitleController.text = bodyDecoded["document"]["title"];
          taskTitleController.addListener(changeButton);
          taskDateController.text = viewDate;
          taskDateController.addListener(changeButton);
          taskDescController.text = bodyDecoded["document"]["notes"];
          taskDescController.addListener(changeButton);
          leadDropdownValue = bodyDecoded["lead"];
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateTask(complete) async {
    try {
      var token = await this.widget.storageService.read("access_token");
      var data = {
        "task": task["task"],
        "status": task["status"],
        "type": taskTypeDropdownValue,
        "owner": employeeDropdownValue,
        "date": taskDateController.text,
        "priority": taskPriorityDropdownValue,
        "lead": leadDropdownValue,
        "document": !complete
            ? {
                "title": taskTitleController.text,
                "notes": taskDescController.text,
                "eventid": task["document"]["eventid"],
                "active": true,
              }
            : {
                "title": taskTitleController.text,
                "notes": taskDescController.text,
                "eventid": task["document"]["eventid"],
                "active": false,
              }
      };
      var resp1 =
          await apiService.authPut(context, "/googlecalendar/" + token, data);
      if (resp1 != null) {
        if (resp1.statusCode == 200) {
          // Fluttertoast.showToast(
          //     msg: "Successfully updated Calendar Event!",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     backgroundColor: Colors.grey[600],
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          var event = resp1.data["eventid"];
          print('TASK: ' + task["task"]);
          data["document"]["eventid"] = event;
        }
      } else {
        Fluttertoast.showToast(
            msg: "Couldn't update Calendar Event",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
      var resp =
          await apiService.authPut(context, "/task/" + task["task"], data);
      if (resp != null) {
        if (resp.statusCode == 200) {
          !complete
              ? Fluttertoast.showToast(
                  msg: "Successfully updated task!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[600],
                  textColor: Colors.white,
                  fontSize: 16.0)
              : Fluttertoast.showToast(
                  msg: "Successfully resolved task!",
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

  Future<void> deleteCheck() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete this Task?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this task?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                deleteTask();

                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTask() async {
    Fluttertoast.showToast(
        msg: "This happens on delete",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: Key("viewTasksAppBar"),
        title: Text(isLoading ? "Loading..." : task['document']['title']),
        // action: <Widget>[
        //   Padding(
        //     padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
        //     child: UserService.isAdmin
        //         ? IconButton(
        //             onPressed: () {
        //               deleteCheck();
        //             },
        //             icon: Icon(Icons.delete, color: Colors.white),
        //           )
        //         : Container(),
        //   )
        // ],
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
                      disabled: true,
                      value: employeeDropdownValue,
                      callback: ((val) {
                        setState(() {
                          val = null;
                          Fluttertoast.showToast(
                              msg: "Employee can not be changed for tasks!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[600],
                              textColor: Colors.white,
                              fontSize: 16.0);
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
                          changeButton();
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
                          changeButton();
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
                                  changeButton();
                                });
                              },
                              employeeId: employeeDropdownValue,
                              disabled: true),
                        ),
                        // Expanded(
                        //   flex: 2,
                        //   child: Text('asdf'),
                        // ),
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
                              context: context, initialTime: initTime);
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
                          borderSide:
                              BorderSide(color: Colors.greenAccent, width: 3.0),
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
          if (isChanged) {
            await updateTask(false);
          } else {
            await updateTask(true);
          }
        },
        backgroundColor: Color.fromARGB(500, 1, 224, 143),
        child: isChanged ? Icon(Icons.save) : Icon(Icons.done),
      ),
    );
  }
}
