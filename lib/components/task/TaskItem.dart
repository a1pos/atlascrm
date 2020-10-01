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
      Color.fromRGBO(229, 69, 69, 1),
      Color.fromRGBO(247, 188, 74, 1),
      Color.fromRGBO(119, 174, 237, 1),

      // Colors.red[100], //Light Red
      // Colors.yellow[100], //Light Yellow
      // Colors.green[100], //Light Green
    ];
    var index =
        _types.indexWhere((typeObj) => typeObj.name == this.widget.type);
    var taskIcon;
    if (index > 0) {
      taskIcon = Icon(
        _types[index].icon,
        color: Colors.white,
      );
    } else {
      // taskIcon = Icon(Icons.category);
      taskIcon = null;
    }
    return Center(
      child: Card(
        color: this.widget.priority == -1
            ? Colors.white
            : _colors[this.widget.priority],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: ListTile(
                leading: taskIcon,
                title: Text(
                  this.widget.title ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  this.widget.description ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ),
                // trailing: Text("" ?? "", style: TextStyle(fontSize: 11)),
              ),
            ),
            Divider(color: Colors.white),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Text(
                this.widget.dateTime,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
