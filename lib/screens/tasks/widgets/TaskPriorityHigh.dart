import 'package:flutter/material.dart';

class TaskPriorityHigh extends StatefulWidget {
  final String title;
  final String description;
  final String dateTime;

  TaskPriorityHigh({this.title, this.description, this.dateTime});

  @override
  _TaskPriorityHighState createState() => _TaskPriorityHighState();
}

class _TaskPriorityHighState extends State<TaskPriorityHigh> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.priority_high),
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
