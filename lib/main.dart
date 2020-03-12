import 'package:atlascrm/screens/auth/AuthScreen.dart';
import 'package:atlascrm/screens/dashboard/DashboardScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeCallHistory.dart';
import 'package:atlascrm/screens/employees/EmployeeList.dart';
import 'package:atlascrm/screens/employees/EmployeeMap.dart';
import 'package:atlascrm/screens/employees/EmployeeMapHistory.dart';
import 'package:atlascrm/screens/employees/EmployeesManagementScreen.dart';
import 'package:atlascrm/screens/employees/ViewEmployeeScreen.dart';
import 'package:atlascrm/screens/leads/LeadsScreen.dart';
import 'package:atlascrm/screens/leads/ViewLeadScreen.dart';
import 'package:atlascrm/screens/shared/CameraPage.dart';
import 'package:atlascrm/screens/shared/LoadingScreen.dart';
import 'package:atlascrm/screens/shared/SlideRightRoute.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
  //     .requestPermissions(
  //         [PermissionGroup.camera, PermissionGroup.access_media_location]);

  cameras = await availableCameras();

  runApp(AtlasCRM());
}

class AtlasCRM extends StatefulWidget {
  final UserService userService = new UserService();

  @override
  _AtlasCRMState createState() => _AtlasCRMState();
}

class _AtlasCRMState extends State<AtlasCRM> {
  bool isAuthenticated = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    isAuthCheck();
  }

  Future<void> isAuthCheck() async {
    var isAuthed = await this.widget.userService.isAuthenticated(context);
    if (isAuthed) {
      setState(() {
        isLoading = false;
        isAuthenticated = true;
      });

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(0, 1, 56, 112),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
        isAuthenticated = false;
      });
    }
  }

  Future<void> handleLogoutRoute() async {
    await this.widget.userService.signOutGoogle();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    setState(() {
      isLoading = true;
      isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? getLoadingScreen() : getHomeScreen();
  }

  Widget getLoadingScreen() {
    return MaterialApp(
      home: LoadingScreen(),
    );
  }

  Widget getHomeScreen() {
    return MaterialApp(
      title: 'ATLAS CRM',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        fontFamily: "LatoRegular",
      ),
      home: isAuthenticated ? DashboardScreen() : AuthScreen(),
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => DashboardScreen());
            break;
          case "/leads":
            return MaterialPageRoute(builder: (context) => LeadsScreen());
            break;
          case "/logout":
            handleLogoutRoute();
            return MaterialPageRoute(builder: (context) => AtlasCRM());
            break;
          case '/viewlead':
            return SlideRightRoute(page: ViewLeadScreen(settings.arguments));
            break;
          case '/employeemgmt':
            return MaterialPageRoute(
                builder: (context) => EmployeesManagementScreen());
            break;
          case '/employeemap':
            return SlideRightRoute(
              page: EmployeeMap(),
            );
            break;
          case '/employeemaphistory':
            return SlideRightRoute(
              page: EmployeeMapHistory(settings.arguments),
            );
            break;
          case '/employeelist':
            return SlideRightRoute(
              page: EmployeeList(true),
            );
            break;
          case '/employeecallhistory':
            return SlideRightRoute(
              page: EmployeeCallHistory(settings.arguments),
            );
            break;
          case '/viewemployee':
            return SlideRightRoute(
                page: ViewEmployeeScreen(settings.arguments));
            break;
          case '/camera':
            return SlideRightRoute(
                page:
                    CameraPage(cameras: cameras, callback: settings.arguments));
            break;
          case '/settings':
            // return MaterialPageRoute(builder: (context) => SettingsScreen());
            break;
        }
      },
    );
  }
}
