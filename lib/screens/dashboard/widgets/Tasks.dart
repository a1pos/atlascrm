import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/task/TaskItem.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Tasks extends StatefulWidget {
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  bool isLoading = true;
  bool isEmpty = true;

  var tasks = [];
  var activeTasks = [];
  var subscription;

  @override
  void initState() {
    super.initState();

    initTasks();
  }

  @override
  void dispose() async {
    super.dispose();
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
    }
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
      variables: {"employee": "${UserService.employee.employee}"},
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) {
        var tasksArrDecoded = data.data["employee_by_pk"]["tasks"];
        if (tasksArrDecoded != null) {
          setState(
            () {
              tasks = tasksArrDecoded;
              activeTasks = tasks;
              if (tasks.length > 0) {
                isEmpty = false;
              }
              isLoading = false;
            },
          );
        }
        isLoading = false;
      },
      (error) {},
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      initTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CenteredLoadingSpinner(),
              ],
            )
          : activeTasks == null
              ? Empty("No Active Tasks found")
              : buildDLGridView(context, activeTasks),
    );
  }
}

Widget buildDLGridView(BuildContext context, list) {
  return list.length == 0
      ? Empty("No Active Tasks found")
      : ListView(
          shrinkWrap: true,
          children: List.generate(
            list.length,
            (index) {
              var task = list[index];

              var tDate;
              var tType = "none";
              var tPriority = -1;

              if (task['date'] != null) {
                tDate = DateFormat("EEE, MMM d, ''yy")
                    .add_jm()
                    .format(DateTime.parse(task['date']).toLocal());
              } else {
                tDate = "";
              }
              if (task["taskTypeByTaskType"] != null) {
                tType = task["taskTypeByTaskType"]["title"];
              }
              if (task["priority"] != null) {
                tPriority = task["priority"];
              }
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/viewtask",
                      arguments: task["task"]);
                },
                child: TaskItem(
                    title: task["document"]["title"],
                    description: task["document"]["notes"],
                    dateTime: tDate,
                    type: tType,
                    priority: tPriority),
              );
            },
          ),
        );
}
