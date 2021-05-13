import 'package:flutter/material.dart';

class InstallItem extends StatefulWidget {
  final String merchant;
  final String dateTime;
  final String merchantDevice;
  final String employeeFullName;
  final String location;

  InstallItem({
    this.merchant,
    this.dateTime,
    this.merchantDevice,
    this.employeeFullName,
    this.location,
  });

  @override
  _InstallItemState createState() => _InstallItemState();
}

class _InstallItemState extends State<InstallItem> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.blueAccent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: ListTile(
                leading: Icon(
                  Icons.devices,
                  color: Colors.white,
                ),
                title: Text(
                  this.widget.merchant ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  this.widget.merchantDevice ?? "",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                child: Text(
                  this.widget.employeeFullName ?? "",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              child: Text(
                this.widget.location ?? "",
                style: TextStyle(color: Colors.white),
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
