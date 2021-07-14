import 'package:round2crm/components/shared/CenteredLoadingSpinner.dart';
import 'package:round2crm/components/shared/Empty.dart';
import 'package:round2crm/components/task/TaskItem.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class Tasks extends StatefulWidget {
  Tasks({Key key}) : super(key: key);

  @override
  TasksState createState() => TasksState();
}

class TasksState extends State<Tasks> {
  bool isLoading = true;
  bool isEmpty = true;

  List tasks = [];
  List activeTasks = [];

  ScrollController scrollController = ScrollController();

  var subscription;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

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
      fetchPolicy: FetchPolicy.noCache,
      variables: {"employee": "${UserService.employee.employee}"},
    );

    subscription = await GqlClientFactory().authGqlsubscribe(
      options,
      (data) {
        var tasksArrDecoded = data.data["employee_by_pk"]["tasks"];
        if (tasksArrDecoded != null && this.mounted) {
          Future.delayed(Duration(seconds: 1), () {
            logger.i("Tasks widget initialized");
          });

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
      (error) {
        debugPrint("Error in Tasks: " + error.toString());
        logger.e("Error in Tasks: " + error.toString());
      },
      () => refreshSub(),
    );
  }

  Future refreshSub() async {
    if (subscription != null) {
      await subscription.cancel();
      subscription = null;
      scrollController.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      Future.delayed(Duration(seconds: 1), () {
        logger.i("Tasks refreshed");
      });

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
              : buildDLGridView(context, activeTasks, scrollController),
    );
  }
}

Widget buildDLGridView(BuildContext context, list, scrollController) {
  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  return list.length == 0
      ? Empty("No Active Tasks found")
      : ListView(
          controller: scrollController,
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
                  Navigator.pushNamed(
                    context,
                    "/viewtask",
                    arguments: task['task'],
                  );

                  Future.delayed(Duration(seconds: 1), () {
                    logger.i(
                      "Opening task: " +
                          task["document"]["title"] +
                          " (" +
                          task["task"].toString() +
                          ")" +
                          " on " +
                          task["date"].toString(),
                    );
                  });
                },
                child: TaskItem(
                  title: task["document"]["title"],
                  description: task["document"]["notes"],
                  dateTime: tDate,
                  type: tType,
                  priority: tPriority,
                ),
              );
            },
          ),
        );
}
