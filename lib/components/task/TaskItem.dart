import 'package:flutter/material.dart';

class TaskItem extends StatefulWidget {
  final String title;
  final String description;
  final String dateTime;
  final String type;
  final int priority;
  TaskItem(
      {this.title, this.description, this.dateTime, this.type, this.priority});

  @override
  _TaskItemState createState() => _TaskItemState();
}

class Type {
  String name;
  IconData icon;

  Type(this.name, this.icon);
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    List<Type> _types = [
      Type('Phone Call', Icons.phone),
      Type('Appointment', Icons.calendar_today),
      Type('Corporate Meeting', Icons.business),
      Type('Physical Stop', Icons.person)
    ];
    List<Color> _colors = [
      Color(0x9Fef9a9a), //Light Red
      Color(0x9Ffff59d), //Light Yellow
      Color(0x9Fa5d6a7), //Light Green
    ];
    var index =
        _types.indexWhere((typeObj) => typeObj.name == this.widget.type);
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: _colors[this.widget.priority],
              child: ListTile(
                leading: Icon(_types[index].icon),
                title: Text(this.widget.title ?? ""),
                subtitle: Text(this.widget.description ?? ""),
                trailing: Text(this.widget.dateTime ?? ""),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
