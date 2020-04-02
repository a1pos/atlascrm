import 'package:atlascrm/services/ApiService.dart';
import 'package:flutter/material.dart';

class TaskPriorityDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;

  TaskPriorityDropDown({this.employeeId, this.callback, this.value});

  @override
  _TaskPriorityDropDownState createState() => _TaskPriorityDropDownState();
}

class _TaskPriorityDropDownState extends State<TaskPriorityDropDown> {
  final ApiService apiService = ApiService();

  var dropDownValue;

  var taskPriorites = [
    {"value": "0", "text": "High"},
    {"value": "1", "text": "Medium"},
    {"value": "2", "text": "Low"},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: dropDownValue,
      hint: Text("Priority"),
      items: taskPriorites.map((dynamic item) {
        return DropdownMenuItem<String>(
          value: item["value"],
          child: Text(
            item["text"],
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        this.widget.callback(newValue);
      },
    );
  }
}
