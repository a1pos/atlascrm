import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/task/TaskItem.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Tasks extends StatefulWidget {
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final ApiService apiService = ApiService();

  var isEmpty = true;
  var isLoading = true;
  var tasks = [];
  var activeTasks = [];
  @override
  void initState() {
    super.initState();

    // initTasks();
  }

  Future<void> initTasks() async {
    try {
      var resp = await apiService.authGet(
          context, "/employee/${UserService.employee.employee}/task");
      if (resp != null) {
        if (resp.statusCode == 200) {
          var tasksArrDecoded = resp.data;
          if (tasksArrDecoded != null && tasksArrDecoded.length > 0) {
            setState(() {
              tasks = tasksArrDecoded;
              activeTasks =
                  tasks.where((e) => e["document"]["active"]).toList();
              if (activeTasks.length > 0) {
                isEmpty = false;
              }
              isLoading = false;
              print(activeTasks);
            });
          } else {
            setState(() {
              isLoading = false;
              isEmpty = true;
            });
          }
        } else {
          throw new Error();
        }
      } else {
        throw new Error();
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Subscription("EmployeeTasks", """
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
            """, builder: ({error, bool loading, payload}) {
      print(error);
      // return Container(
      //   child: Text(loading.toString()),
      // );
      return Container(
          child: loading
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CenteredLoadingSpinner(),
                  ],
                )
              : payload.data == null
                  ? Empty("No Active Tasks found")
                  : buildDLGridView(
                      context, payload.data["employee"]["tasks"]));
    }, variables: {"employee": "${UserService.employee.employee}"});
    // return Query(
    //     options: QueryOptions(
    //         documentNode: gql("""
    //       subscription EmployeeTasks(\$employee: uuid!) {
    //         employee_by_pk(employee: \$employee) {
    //           tasks {
    //             task
    //             taskTypeByTaskType {
    //               task_type
    //               title
    //             }
    //             employee
    //             date
    //             priority
    //             task_status
    //             document
    //             merchant
    //             lead
    //             created_by
    //             updated_by
    //             created_at
    //           }
    //         }
    //       }
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
            if (task['date'] != null) {
              tDate = DateFormat("EEE, MMM d, ''yy")
                  .add_jm()
                  .format(DateTime.parse(task['date']));
            } else {
              tDate = "";
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
                  type: task["task_type"]["title"],
                  priority: task["priority"]),
            );
          }));
}
