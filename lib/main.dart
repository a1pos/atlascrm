import 'package:atlascrm/components/shared/CameraPage.dart';
import 'package:atlascrm/components/shared/CustomWebView.dart';
import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/components/shared/SlideRightRoute.dart';
import 'package:atlascrm/screens/auth/AuthScreen.dart';
import 'package:atlascrm/screens/dashboard/AdminDashboardScreen.dart';
import 'package:atlascrm/screens/dashboard/SalesDashboardScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeCallHistoryScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeListScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeMapHistoryScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeMapScreen.dart';
import 'package:atlascrm/screens/employees/EmployeesManagementScreen.dart';
import 'package:atlascrm/screens/employees/ViewEmployeeScreen.dart';
import 'package:atlascrm/screens/leads/LeadsScreen.dart';
import 'package:atlascrm/screens/leads/ViewLeadScreen.dart';
import 'package:atlascrm/screens/tasks/TaskScreen.dart';
import 'package:atlascrm/screens/tasks/ViewTaskScreen.dart';
import 'package:atlascrm/screens/agreement/AgreementBuilder.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
      .requestPermissions(
          [PermissionGroup.camera, PermissionGroup.storage]);

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
      home: isAuthenticated
          ? UserService.isAdmin
              ? AdminDashboardScreen()
              : SalesDashboardScreen()
          : AuthScreen(),
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(
                builder: (context) => UserService.isAdmin
                    ? AdminDashboardScreen()
                    : SalesDashboardScreen());
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
              page: EmployeeMapScreen(),
            );
            break;
          case '/employeemaphistory':
            return SlideRightRoute(
              page: EmployeeMapHistoryScreen(settings.arguments),
            );
            break;
          case '/tasks':
            return SlideRightRoute(
              page: TaskScreen(),
            );
            break;
          case '/employeelist':
            return SlideRightRoute(
              page: EmployeeListScreen(true),
            );
            break;
          case '/employeecallhistory':
            return SlideRightRoute(
              page: EmployeeCallHistoryScreen(settings.arguments),
            );
            break;
          case '/viewemployee':
            return SlideRightRoute(
                page: ViewEmployeeScreen(settings.arguments));
            break;
          case '/viewtask':
            return SlideRightRoute(page: ViewTaskScreen(settings.arguments));
            break;
          case '/agreementbuilder':
            return SlideRightRoute(page: AgreementBuilder(settings.arguments));
            break;
          case '/camera':
            return SlideRightRoute(
                page:
                    CameraPage(cameras: cameras, callback: settings.arguments));
            break;
          case '/docusigner':
            return SlideRightRoute(
              page: CustomWebView(
                title: "Docusigner",
                selectedUrl:
                    "https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=c04d3d47-c7be-46d5-a10a-471e8c9e531b&env=demo&acct=d805e4d3-b594-4e79-9d49-243e076e75e6&v=2",
              ),
            );

            break;
          case '/settings':
            // return MaterialPageRoute(builder: (context) => SettingsScreen());
            break;
        }
      },
    );
  }
}
