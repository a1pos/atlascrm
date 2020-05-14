import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/Empty.dart';
import 'package:atlascrm/components/task/TaskItem.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    initTasks();
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
              isLoading = false;
              if (activeTasks.length > 0) {
                isEmpty = false;
              }
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
    return Container(
      child: isLoading
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CenteredLoadingSpinner(),
              ],
            )
          : isEmpty
              ? Empty("No Active Tasks found")
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: activeTasks.map((t) {
                          var tDate = DateFormat("EEE, MMM d, ''yy")
                              .add_jm()
                              .format(DateTime.parse(t['date']));
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/viewtask",
                                  arguments: t["task"]);
                            },
                            child: TaskItem(
                                title: t["document"]["title"],
                                description: t["document"]["notes"],
                                dateTime: tDate,
                                type: t["typetitle"],
                                priority: t["priority"]),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
    );
  }
}
