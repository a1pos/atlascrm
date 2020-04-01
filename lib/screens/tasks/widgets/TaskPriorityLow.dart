import 'package:flutter/material.dart';

class TaskPriorityLow extends StatefulWidget {
  final String title;
  final String description;
  final String dateTime;

  TaskPriorityLow({this.title, this.description, this.dateTime});

  @override
  _TaskPriorityLowState createState() => _TaskPriorityLowState();
}

class _TaskPriorityLowState extends State<TaskPriorityLow> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.snooze),
              title: Text(this.widget.title),
              subtitle: Text(this.widget.description),
              trailing: Text(this.widget.dateTime),
            ),
          ],
        ),
      ),
    );
  }
}
