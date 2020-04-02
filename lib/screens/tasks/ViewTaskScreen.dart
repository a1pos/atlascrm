import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:unicorndial/unicorndial.dart';

class ViewTaskScreen extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String taskId;

  ViewTaskScreen(this.taskId);

  @override
  ViewTaskScreenState createState() => ViewTaskScreenState();
}

class ViewTaskScreenState extends State<ViewTaskScreen> {
  var isLoading = true;

  var task;

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
        task = bodyDecoded;
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
    return WillPopScope(
      onWillPop: () {
        Navigator.popAndPushNamed(context, '/tasks');

        return Future.value(false);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          key: Key("viewTasksAppBar"),
          title: Text(isLoading ? "Loading..." : task[""]),
        ),
        body: isLoading
            ? CenteredClearLoadingScreen()
            : Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[],
                  ),
                ),
              ),
        floatingActionButton: UnicornDialer(
          parentButtonBackground: Color.fromARGB(500, 1, 224, 143),
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(
            Icons.add,
            color: Colors.white,
          ),
          childButtons: <UnicornButton>[
            UnicornButton(
              hasLabel: true,
              labelText: "Save Task",
              currentButton: FloatingActionButton(
                heroTag: "saveTask",
                backgroundColor: Colors.green[300],
                mini: true,
                foregroundColor: Colors.white,
                child: Icon(Icons.save),
                onPressed: () {
                  updateTask();
                },
              ),
            ),
            UnicornButton(
              hasLabel: true,
              labelText: "Delete Task",
              currentButton: FloatingActionButton(
                heroTag: "deleteTask",
                mini: true,
                backgroundColor: Colors.red[300],
                child: Icon(Icons.delete),
                foregroundColor: Colors.white,
                onPressed: () {
                  deleteTask();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfoRow(label, value, controller) {
    if (value != null) {
      controller.text = value;
    }

    var valueFmt = value ?? "N/A";

    if (valueFmt == "") {
      valueFmt = "N/A";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextField(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
