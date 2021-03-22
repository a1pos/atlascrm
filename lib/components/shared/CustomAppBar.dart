import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget> action;

  const CustomAppBar({Key key, this.title, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleWidget = this.title as Text;
    var stringValue = titleWidget.data;
    return Column(
      children: [
        Container(
          child: AppBar(
            iconTheme: new IconThemeData(
              color: Colors.white,
            ),
            title: Text(
              stringValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: action,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}
