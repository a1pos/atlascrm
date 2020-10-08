import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/task/TaskItem.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Tasks extends StatefulWidget {
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  var isEmpty = true;
  var isLoading = true;
  var tasks = [];
  var activeTasks = [];
  @override
  void initState() {
    super.initState();

    initTasks();
    print(UserService.employee);
  }

  Future<void> initTasks() async {
    Operation options =
        Operation(operationName: "EMPLOYEE_TASKS", documentNode: gql("""
          subscription EMPLOYEE_TASKS(\$employee: uuid!) {
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

    var result = wsClient.subscribe(options);
    result.listen(
      (data) async {
        var tasksArrDecoded = data.data["employee_by_pk"]["tasks"];
        if (tasksArrDecoded != null) {
          setState(() {
            tasks = tasksArrDecoded;
            // activeTasks = tasks.where((e) => e["document"]["active"]).toList();
            activeTasks = tasks;
            if (tasks.length > 0) {
              isEmpty = false;
            }
            isLoading = false;
          });
          // await fillEvents();
        }
        isLoading = false;
      },
      onError: (error) {
        print("STREAM LISTEN ERROR DASHBOARD TASKS");
        print(error);
        setState(() {
          isLoading = false;
        });

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
                : buildDLGridView(context, activeTasks));

    // return Query(
    //     options: QueryOptions(
    //         documentNode: gql("""
    // subscription EmployeeTasks(\$employee: uuid!) {
    //   employee_by_pk(employee: \$employee) {
    //     tasks {
    //       task
    //       taskTypeByTaskType {
    //         task_type
    //         title
    //       }
    //       employee
    //       date
    //       priority
    //       task_status
    //       document
    //       merchant
    //       lead
    //       created_by
    //       updated_by
    //       created_at
    //     }
    //   }
    // }
    //         """),
    //         pollInterval: 1,
    //         variables: {"employee": "${UserService.employee.employee}"}),
    //     builder: (QueryResult result,
    //         {VoidCallback refetch, FetchMore fetchMore}) {
    //       return Container(
    //           child: result.loading
    //               ? Row(
    //                   crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: <Widget>[
    //                     CenteredLoadingSpinner(),
    //                   ],
    //                 )
    //               : result.data == null
    //                   ? Empty("No Active Tasks found")
    //                   : buildDLGridView(
    //                       context, result.data["employee"]["tasks"]));
    //     });
  }
}

Widget buildDLGridView(BuildContext context, list) {
  return list.length == 0
      ? Empty("No Active Tasks found")
      : ListView(
          shrinkWrap: true,
          children: List.generate(list.length, (index) {
            var task = list[index];

            var tDate;
            var tType = "none";
            var tPriority = -1;

            if (task['date'] != null) {
              tDate = DateFormat("EEE, MMM d, ''yy")
                  .add_jm()
                  .format(DateTime.parse(task['date']));
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
          }));
}
