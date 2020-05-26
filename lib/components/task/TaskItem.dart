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
      Type('Physical Stop', Icons.store_mall_directory),
      Type('Quota Goal', Icons.trending_up)
    ];
    List<Color> _colors = [
      Colors.red[100], //Light Red
      Colors.yellow[100], //Light Yellow
      Colors.green[100], //Light Green
    ];
    var index =
        _types.indexWhere((typeObj) => typeObj.name == this.widget.type);
    Icon taskIcon;
    if (index != -1) {
      taskIcon = Icon(_types[index].icon);
    } else {
      taskIcon = Icon(Icons.category);
    }
    return Center(
      child: Card(
        color: _colors[this.widget.priority],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: ListTile(
                leading: taskIcon,
                title: Text(
                  this.widget.title ?? "",
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  this.widget.description ?? "",
                  overflow: TextOverflow.ellipsis,
                ),
                // trailing: Text("" ?? "", style: TextStyle(fontSize: 11)),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Text(
                this.widget.dateTime,
              ),
            )
          ],
        ),
      ),
    );
  }
}
