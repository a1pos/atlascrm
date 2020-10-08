import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final Widget child;
  final String title;
  final IconData icon;
  final bool isClickable;
  final String route;
  final Key key;

  CustomCard(
      {this.child,
      this.title,
      this.icon,
      this.isClickable = false,
      this.route,
      this.key});

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: this.widget.key,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                this.widget.icon,
                size: 25,
                color: Colors.black,
              ),
              title: Text(
                this.widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              trailing: this.widget.isClickable
                  ? Icon(
                      Icons.open_in_new,
                    )
                  : null,
              onTap: this.widget.isClickable
                  ? () {
                      Navigator.pushNamed(context, this.widget.route);
                    }
                  : null,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.1,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: this.widget.child,
            )
          ],
        ),
      ),
    );
  }
}
