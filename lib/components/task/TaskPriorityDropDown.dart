import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

class TaskPriorityDropDown extends StatefulWidget {
  final String employeeId;
  final String value;
  final Function callback;

  TaskPriorityDropDown({this.employeeId, this.callback, this.value});

  @override
  _TaskPriorityDropDownState createState() => _TaskPriorityDropDownState();
}

class _TaskPriorityDropDownState extends State<TaskPriorityDropDown> {
  var taskPriorites = [
    {"value": "2", "text": "High"},
    {"value": "1", "text": "Medium"},
    {"value": "0", "text": "Low"},
  ];

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

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
              Future.delayed(Duration(seconds: 1), () {
                logger.i("No task priority selected for dropdown");
              });

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
            Future.delayed(Duration(seconds: 1), () {
              logger.i("Task priority dropdown value changed: " +
                  newValue.toString());
            });

            this.widget.callback(newValue);
          },
        ),
      ],
    );
  }
}
