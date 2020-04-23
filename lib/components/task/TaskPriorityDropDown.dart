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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Priority',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        DropdownButtonFormField<String>(
          validator: (value) {
            if (value == null) {
              return 'Please select a task priority';
            }
            return null;
          },
          isExpanded: true,
          value: this.widget.value,
          hint: Text("Please choose one"),
          items: taskPriorites.map((dynamic item) {
            return DropdownMenuItem<String>(
              value: item["value"],
              child: Text(item["text"]),
            );
          }).toList(),
          onChanged: (newValue) {
            this.widget.callback(newValue);
          },
        ),
      ],
    );
  }
}
