import 'dart:ui';

import 'package:atlascrm/services/UserService.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  final UserService userService = new UserService();

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
  }

  void handleSignOut() {
    Navigator.of(context).popAndPushNamed('/logout');
  }

  @override
  Widget build(BuildContext context) {
    var employeeImage =
        Image.network(UserService.employee.document["googleClaims"]["picture"]);

    return Drawer(
      child: Container(
        color: Color.fromARGB(255, 21, 27, 38),
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
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 21, 27, 38),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.dashboard,
                color: Colors.white,
              ),
              title: Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, "/dashboard");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.playlist_add_check,
                color: Colors.white,
              ),
              title: Text(
                'Tasks',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, "/tasks");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.attach_money,
                color: Colors.white,
              ),
              title: Text(
                'Leads',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, "/leads");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.people,
                color: Colors.white,
              ),
              title: Text(
                'Merchants',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.popAndPushNamed(context, "/merchants");
              },
            ),
            UserService.isTech || UserService.isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.business_center,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Inventory',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/inventory");
                    },
                  )
                : Text(""),
            UserService.isTech || UserService.isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.drive_eta,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Mileage',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/mileage");
                    },
                  )
                : Text(""),
            UserService.isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Users',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/employeemgmt");
                    },
                  )
                : Text(""),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  leading: Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: handleSignOut,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
