import 'package:flutter/material.dart';

// class CustomAppBar extends AppBar {
//   CustomAppBar({Key key, Widget title})
//       : super(key: key, title: title, backgroundColor: Colors.green[200]);
// }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;

  const CustomAppBar({Key key, this.title}) : super(key: key);

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
                color: Colors.white,
              ),
            ),
            backgroundColor: Color.fromARGB(500, 1, 56, 112),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}
