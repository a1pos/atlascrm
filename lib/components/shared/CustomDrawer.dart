import 'dart:ui';
import 'package:round2crm/components/shared/NotificationCenter.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/services/UserService.dart';
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
    var employeeImage;
    try {
      employeeImage = Image.network(UserService.employee.document["photoURL"]);
    } catch (err) {
      employeeImage = Image.asset("assets/google_logo.png");
    }

    return Drawer(
      child: Container(
        color: UniversalStyles.themeColor,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: employeeImage.image,
                        maxRadius: 35,
                      ),
                      NotificationCenter()
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 22),
                      children: <TextSpan>[
                        TextSpan(
                            text: "ROUND2",
                            style: TextStyle(fontFamily: "InterBold")),
                        TextSpan(
                            text: "CRM",
                            style: TextStyle(fontFamily: "InterLight")),
                      ],
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(81, 203, 194, 1),
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
                Navigator.pushReplacementNamed(context, "/dashboard");
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
                Navigator.pushReplacementNamed(context, "/tasks");
              },
            ),
            UserService.isTech
                ? Container()
                : ListTile(
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
                      Navigator.pushReplacementNamed(context, "/leads");
                    },
                  ),
            UserService.isTech ||
                    UserService.isCorporateTech ||
                    UserService.isAdmin ||
                    UserService.isSalesManager
                ? ListTile(
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
                      Navigator.pushReplacementNamed(context, "/merchants");
                    },
                  )
                : Container(),
            UserService.isTech ||
                    UserService.isCorporateTech ||
                    UserService.isAdmin
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
                      Navigator.pushReplacementNamed(context, "/inventory");
                    },
                  )
                : Container(),
            UserService.isTech ||
                    UserService.isCorporateTech ||
                    UserService.isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.build,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Installs',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, "/installs");
                    },
                  )
                : Text(""),
            UserService.isAdmin ||
                    UserService.isSalesManager ||
                    UserService.isCorporateTech
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
                      Navigator.pushReplacementNamed(context, "/employeemgmt");
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
