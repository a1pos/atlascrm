import 'package:atlascrm/components/lead/LeadDropDown.dart';
import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/shared/EmployeeDropDown.dart';
import 'package:atlascrm/components/task/TaskPriorityDropDown.dart';
import 'package:atlascrm/components/task/TaskTypeDropDown.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class ViewTaskScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String taskId;

  ViewTaskScreen(this.taskId);

  @override
  ViewTaskScreenState createState() => ViewTaskScreenState();
}

class ViewTaskScreenState extends State<ViewTaskScreen> {
  var isLoading = true;

  var taskTitleController = TextEditingController();

  var task;

  var employeeDropdownValue;
  var taskTypeDropdownValue;
  var taskPriorityDropdownValue;
  var leadDropdownValue;

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
        setState(() {
          task = bodyDecoded;
          taskTypeDropdownValue = bodyDecoded["type"];
          employeeDropdownValue = bodyDecoded["owner"];
          taskPriorityDropdownValue = bodyDecoded["priority"].toString();
          taskTitleController.text = bodyDecoded["document"]["title"];
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateTask() async {}

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
