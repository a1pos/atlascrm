import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final String text;

  Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.list),
            Text(
              this.text,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
