import 'package:atlascrm/components/shared/CustomAppBar.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CustomDrawer.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/screens/employees/EmployeeListScreen.dart';
import 'package:atlascrm/screens/employees/widgets/MgmtTile.dart';
import 'package:flutter/material.dart';

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/dashboard");
        return false;
      },
      child: Scaffold(
        backgroundColor: UniversalStyles.backgroundColor,
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
                      child: EmployeeListScreen(false),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
