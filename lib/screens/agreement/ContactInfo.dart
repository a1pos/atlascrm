import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/config/ConfigSettings.dart';

import 'package:intl/intl.dart';

class ContactInfoPage extends StatefulWidget {
  final ApiService apiService = new ApiService();

  @override
  ContactInfoPageState createState() => ContactInfoPageState();
}

class ContactInfoPageState extends State<ContactInfoPage> {
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
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: Key("viewTasksAppBar"),
        title: Text("test"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.delete, color: Colors.white),
            ),
          )
        ],
        backgroundColor: Color.fromARGB(500, 1, 56, 112),
      ),
      body: isLoading
          ? CenteredClearLoadingScreen()
          : Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text("testubg")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Fluttertoast.showToast(
              msg: "This happens on resolve",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        },
        backgroundColor: Color.fromARGB(500, 1, 224, 143),
        child: Icon(Icons.done),
      ),
    );
  }
}
