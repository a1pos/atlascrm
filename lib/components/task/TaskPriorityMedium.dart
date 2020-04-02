import 'package:flutter/material.dart';

class TaskPriorityMedium extends StatefulWidget {
  final String title;
  final String description;
  final String dateTime;

  TaskPriorityMedium({this.title, this.description, this.dateTime});

  @override
  _TaskPriorityMediumState createState() => _TaskPriorityMediumState();
}

class _TaskPriorityMediumState extends State<TaskPriorityMedium> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.low_priority),
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
