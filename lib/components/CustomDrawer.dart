import 'dart:ui';

import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  final UserService userService = new UserService();

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  var hasAdminAccess = false;

  @override
  void initState() {
    super.initState();

    var currentEmployee = UserService.employee;
    if (currentEmployee != null) {
      var roles = List.from(currentEmployee.document["roles"]);

      if (roles.contains("admin")) {
        hasAdminAccess = true;
      }
    }
  }

  void handleSignOut() {
    Navigator.of(context).popAndPushNamed('/logout');
  }

  @override
  Widget build(BuildContext context) {
    var employeeImage =
        Image.network(UserService.employee.document["googleClaims"]["picture"]);

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: employeeImage.image,
                  maxRadius: 45,
                ),
                Text(
                  UserService.employee.document["fullName"],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(500, 1, 56, 112),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.popAndPushNamed(context, "/dashboard");
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Leads'),
            onTap: () {
              Navigator.popAndPushNamed(context, "/leads");
            },
          ),
          hasAdminAccess
              ? ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Employees'),
                  onTap: () {
                    Navigator.popAndPushNamed(context, "/employeemgmt");
                  },
                )
              : Text(""),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: Icon(Icons.power_settings_new),
                title: Text('Log Out'),
                onTap: handleSignOut,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
