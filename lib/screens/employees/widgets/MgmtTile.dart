import 'package:flutter/material.dart';

class MgmtTile extends StatefulWidget {
  final Color tileColor;
  final IconData icon;
  final String text;
  final String route;

  MgmtTile({this.text, this.tileColor, this.icon, this.route});

  @override
  MgmtTileState createState() => MgmtTileState();
}

class MgmtTileState extends State<MgmtTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      color: this.widget.tileColor,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, this.widget.route);
        },
        child: Column(
          children: <Widget>[
            Icon(this.widget.icon),
            Text(this.widget.text),
          ],
        ),
      ),
    );
  }
}
