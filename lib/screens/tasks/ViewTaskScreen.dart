import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class ViewTaskScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String taskId;

  ViewTaskScreen(this.taskId);

  @override
  ViewTaskScreenState createState() => ViewTaskScreenState();
}

class ViewTaskScreenState extends State<ViewTaskScreen> with TickerProviderStateMixin{
  final ApiService apiService = ApiService();
  var isLoading = true;

  var taskTitle;
  var taskDateController = TextEditingController();
  var taskDescController = TextEditingController();


  var task;

  var employeeDropdownValue;
  var taskTypeDropdownValue;
  var taskPriorityDropdownValue;
  var leadDropdownValue;
  DateTime initDate;
  TimeOfDay initTime;

AnimationController _controller;

  static const List<IconData> icons = const [ Icons.edit, Icons.done ];



  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
          taskTitle = bodyDecoded["document"]["title"];
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
              padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                    "Title: $taskTitle"
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Text(
                      "Employee: $employeeDropdownValue"
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Text(
                      "Type: $taskTypeDropdownValue"
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Text(
                      "Priority: $taskPriorityDropdownValue"
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 8,
                          child: Text(
                            "Lead: $leadDropdownValue"
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('asdf'),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child:Text(
                      "Date: $initDate"
                      ),
                    ),
                    TextField(
                      maxLines: 10,
                      readOnly: true,
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
      floatingActionButton: new Column(
        mainAxisSize: MainAxisSize.min,
        children: new List.generate(icons.length, (int index) {
          Widget child = new Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: new ScaleTransition(
              scale: new CurvedAnimation(
                parent: _controller,
                curve: new Interval(
                  0.0,
                  1.0 - index / icons.length / 2.0,
                  curve: Curves.easeOut
                ),
              ),
              child: new FloatingActionButton(
                heroTag: null,
                backgroundColor: Color.fromARGB(500, 1, 224, 143),
                mini: true,
                child: new Icon(icons[index], color: Colors.white),
                onPressed: () {
                  if (index == 0){
                    Navigator.pushNamed(context, "/edittask",
                    arguments: task["task"]);
                  }
                },
              ),
            ),
          );
          return child;
        }).toList()..add(
          new FloatingActionButton(
            heroTag: null,
            backgroundColor: Color.fromARGB(500, 1, 224, 143),
            child: new AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform: new Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: new Icon(_controller.isDismissed ? Icons.dehaze : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
      ),
    );
  }
}
