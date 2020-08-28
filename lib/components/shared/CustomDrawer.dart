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
            UserService.isAdmin || UserService.isSales || UserService.isTech
                ? ListTile(
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
                  )
                : Container(),
            UserService.isAdmin || UserService.isSales || UserService.isTech
                ? UserService.isTech
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
                          Navigator.popAndPushNamed(context, "/leads");
                        },
                      )
                : Container(),
            UserService.isTech || UserService.isAdmin || UserService.isSales
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
                      Navigator.popAndPushNamed(context, "/merchants");
                    },
                  )
                : Container(),
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
            // Expanded(
            //   child: Theme(
            //     data: Theme.of(context).copyWith(
            //         accentColor: Colors.white,
            //         unselectedWidgetColor: Colors.white..withOpacity(0.8)),
            //     child: ExpansionTile(
            //       title: Text("Expansion Title",
            //           style: TextStyle(color: Colors.white)),
            //       children: <Widget>[
            //         Text("children 1", style: TextStyle(color: Colors.white)),
            //         Text("children 2", style: TextStyle(color: Colors.white)),
            //         UserService.isAdmin
            //             ? ListTile(
            //                 leading: Icon(
            //                   Icons.account_box,
            //                   color: Colors.white,
            //                 ),
            //                 title: Text(
            //                   'Users',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //                 onTap: () {
            //                   Navigator.popAndPushNamed(
            //                       context, "/employeemgmt");
            //                 },
            //               )
            //             : Text(""),
            //       ],
            //     ),
            //   ),
            // ),
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
