import 'package:logger/logger.dart';
import 'package:round2crm/components/lead/LeadDropDown.dart';
import 'package:round2crm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:round2crm/components/shared/CustomAppBar.dart';
import 'package:round2crm/components/shared/EmployeeDropDown.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/components/task/TaskPriorityDropDown.dart';
import 'package:round2crm/components/task/TaskTypeDropDown.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class ViewTaskScreen extends StatefulWidget {
  final String taskId;

  ViewTaskScreen(this.taskId);

  @override
  ViewTaskScreenState createState() => ViewTaskScreenState();
}

class ViewTaskScreenState extends State<ViewTaskScreen> {
  bool isChanged = false;
  bool submitted = false;
  bool isLoading = true;
  DateTime initDate;
  DateTime taskDate;
  TimeOfDay initTime;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  var taskTitleController = TextEditingController();
  var taskDateController = TextEditingController();
  var taskDescController = TextEditingController();

  var task;
  var employeeDropdownValue;
  var taskTypeDropdownValue;
  var taskPriorityDropdownValue;
  var leadDropdownValue;
  var closedStatus;
  var viewDate;

  @override
  void initState() {
    super.initState();
    loadClosedStatus();
    loadTaskData();
  }

  @override
  dispose() {
    super.dispose();
  }

  changeButton() {
    setState(() {
      isChanged = true;
    });
  }

  Future<void> loadClosedStatus() async {
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
          if (item["title"] == "Closed") {
            closedStatus = item["task_status"];
          }
        });
      } else {
        print("Error getting task status: " + result0.exception.toString());
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
  }

  Future<void> loadTaskData() async {
    QueryOptions options = QueryOptions(
      document: gql("""
      query GET_TASK{
        task_by_pk(task: "${this.widget.taskId}"){
          task
          task_type
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
      """),
      fetchPolicy: FetchPolicy.noCache,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    );

    final QueryResult result = await GqlClientFactory().authGqlquery(options);
    if (result.hasException == false) {
      var body = result.data["task_by_pk"];
      if (body != null) {
        var bodyDecoded = body;
        logger.i("Task data loaded");

        if (bodyDecoded["date"] != null) {
          initDate = DateTime.parse(bodyDecoded["date"]).toLocal();
          initTime = TimeOfDay.fromDateTime(initDate);
          viewDate = DateFormat("yyyy-MM-dd HH:mm").format(initDate);
          setState(() {
            taskDateController.text = viewDate;
          });
        } else {
          initDate = DateTime.now();
          initTime = TimeOfDay.fromDateTime(initDate);
        }

        setState(() {
          task = bodyDecoded;
          taskTypeDropdownValue = bodyDecoded["task_type"];
          employeeDropdownValue = bodyDecoded["employee"];
          taskPriorityDropdownValue = bodyDecoded["priority"].toString();
          taskTitleController.text = bodyDecoded["document"]["title"];
          taskTitleController.addListener(changeButton);
          taskDateController.addListener(changeButton);
          taskDescController.text = bodyDecoded["document"]["notes"];
          taskDescController.addListener(changeButton);
          leadDropdownValue = bodyDecoded["lead"];
        });
      }
    } else {
      print("Error getting task data: " + result.exception.toString());
      logger.e("Error getting task data: " + result.exception.toString());

      Fluttertoast.showToast(
          msg: "Error getting task data: " + result.exception.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateTask(complete) async {
    try {
      if (taskDateController.text == null || taskDateController.text == "") {
        logger.i("Date not entered for updating task");
        Fluttertoast.showToast(
          msg: "Date is required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      } else {
        taskDate = DateTime.parse(taskDateController.text).toUtc();
      }

      Map data = {
        "task_status": complete ? closedStatus : task["task_status"],
        "task_type": taskTypeDropdownValue,
        "task": task["task"],
        "priority": taskPriorityDropdownValue,
        "lead": leadDropdownValue,
        "employee": employeeDropdownValue,
        "document": {
          "notes": taskDescController.text,
          "title": taskTitleController.text,
          "eventId": task["document"]["eventId"]
        },
        "date": taskDate.toString(),
      };

      MutationOptions options;

      options = MutationOptions(document: gql("""
        mutation UPDATE_TASK(\$data: task_set_input = {}) {
          update_task_by_pk (pk_columns: {task: "${this.widget.taskId}"}, _set: \$data) {
            priority
            updated_by
            updated_at
            task_type
            task_status
            task
            merchant
            lead
            employee
            document
            date
            created_by
            created_at
          }
        }
        """), fetchPolicy: FetchPolicy.noCache, variables: {"data": data});

      final QueryResult result =
          await GqlClientFactory().authGqlmutate(options);

      if (result != null) {
        if (result.hasException == false) {
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
          await loadTaskData();
          logger.i("Task updated successfully and task data reloaded");
          Navigator.pop(context);
        }
      } else {
        print("Error updating task: " + result.exception.toString());
        logger.e("Error updating task: " + result.exception.toString());

        Fluttertoast.showToast(
          msg: "Error updating task: " + result.exception.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (err) {
      print("Error updating task: " + err.toString());
      logger.e("Error updating task: " + err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalStyles.backgroundColor,
      appBar: CustomAppBar(
        key: Key("viewTasksAppBar"),
        title: Text(isLoading ? "Loading..." : task['document']['title']),
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
                          logger.e("Employee cannot be changed for tasks");
                          Fluttertoast.showToast(
                            msg: "Employee can not be changed for tasks!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[600],
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
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
                        logger.i("Task type changed and button changed: " +
                            taskTypeDropdownValue.toString());
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
                        logger.i("Task priority changed and button changed: " +
                            taskPriorityDropdownValue.toString());
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
                              logger.i(
                                  "Lead value changed: " + leadDropdownValue);
                            },
                            employeeId: employeeDropdownValue,
                            disabled: true,
                          ),
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
      floatingActionButton: submitted
          ? Container()
          : FloatingActionButton(
              onPressed: () async {
                setState(() {
                  submitted = true;
                });
                if (isChanged) {
                  await updateTask(false);
                } else {
                  await updateTask(true);
                }
              },
              backgroundColor: UniversalStyles.actionColor,
              child: isChanged ? Icon(Icons.save) : Icon(Icons.done),
            ),
    );
  }
}
