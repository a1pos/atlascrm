import 'package:atlascrm/components/CustomAppBar.dart';
import 'package:atlascrm/components/CustomCard.dart';
import 'package:atlascrm/components/CustomDrawer.dart';
import 'package:atlascrm/screens/employees/EmployeeList.dart';

import 'package:flutter/material.dart';

import 'MgmtTile.dart';

class EmployeesManagementScreen extends StatefulWidget {
  @override
  _EmployeesManagementScreenState createState() =>
      _EmployeesManagementScreenState();
}

class _EmployeesManagementScreenState extends State<EmployeesManagementScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        key: Key("employeeMgmtAppBar"),
        title: Text("Employee Management"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  CustomCard(
                    title: "Tools",
                    icon: Icons.build,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          color: Colors.white,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              MgmtTile(
                                text: "Employee Map",
                                icon: Icons.zoom_out_map,
                                route: "/employeemap",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  CustomCard(
                    title: "Employees",
                    isClickable: true,
                    route: "/employeelist",
                    icon: Icons.people,
                    child: EmployeeList(false),
                  ),

                  // // Card(
                  // //   elevation: 3,
                  // //   child: Column(
                  // //     children: <Widget>[
                  // //       CardHeader('Tools', null, Icons.build),
                  // //       Container(
                  // //         padding: EdgeInsets.all(5),
                  // //         color: Colors.white,
                  // //         child: Row(
                  // //           crossAxisAlignment: CrossAxisAlignment.start,
                  // //           children: <Widget>[
                  // //             MgmtTile(
                  // //               text: "Employee Map",
                  // //               tileColor: Colors.white,
                  // //               icon: Icons.zoom_out_map,
                  // //               route: "/employeemap",
                  // //             ),
                  // //           ],
                  // //         ),
                  // //       ),
                  // //     ],
                  // //   ),
                  // // ),
                  // Padding(
                  //   padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  // ),
                  // Card(
                  //   elevation: 3,
                  //   child: Column(
                  //     children: <Widget>[
                  //       CardHeader("Employees", "/employeelist", Icons.people),
                  //       EmployeeList(false)
                  //     ],
                  //   ),
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
