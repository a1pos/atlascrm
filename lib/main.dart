import 'package:atlascrm/components/shared/CameraPage.dart';
import 'package:atlascrm/components/shared/LoadingScreen.dart';
import 'package:atlascrm/components/shared/SlideRightRoute.dart';
import 'package:atlascrm/components/style/UniversalStyles.dart';
import 'package:atlascrm/screens/auth/AuthScreen.dart';
import 'package:atlascrm/screens/dashboard/DashboardScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeCallHistoryScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeListScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeMapHistoryScreen.dart';
import 'package:atlascrm/screens/employees/EmployeeMapScreen.dart';
import 'package:atlascrm/screens/employees/EmployeesManagementScreen.dart';
import 'package:atlascrm/screens/employees/ViewEmployeeScreen.dart';
import 'package:atlascrm/screens/leads/LeadNotes.dart';
import 'package:atlascrm/screens/leads/LeadTasks.dart';
import 'package:atlascrm/screens/leads/LeadsScreen.dart';
import 'package:atlascrm/screens/leads/ViewLeadScreen.dart';
import 'package:atlascrm/screens/merchants/MerchantsScreen.dart';
import 'package:atlascrm/screens/merchants/ViewMerchantScreen.dart';
import 'package:atlascrm/screens/inventory/InventoryScreen.dart';
import 'package:atlascrm/screens/inventory/ViewInventoryScreen.dart';
import 'package:atlascrm/screens/installs/InstallsScreen.dart';
import 'package:atlascrm/screens/installs/ViewInstallScreen.dart';
import 'package:atlascrm/screens/mileage/MileageScreen.dart';
import 'package:atlascrm/screens/tasks/TaskScreen.dart';
import 'package:atlascrm/screens/tasks/ViewTaskScreen.dart';
import 'package:atlascrm/screens/agreement/AgreementBuilder.dart';
import 'package:atlascrm/services/FirebaseCESService.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:atlascrm/screens/leads/uploads/StatementUploader.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseCESService().init();

  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
      .requestPermissions([PermissionGroup.camera, PermissionGroup.storage]);

  cameras = await availableCameras();

  runApp(AtlasCRM());
}

final UserService userService = new UserService();

class AtlasCRM extends StatefulWidget {
  @override
  _AtlasCRMState createState() => _AtlasCRMState();
}

class _AtlasCRMState extends State<AtlasCRM> {
  bool isLoading = true;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    GqlClientFactory.setPublicGraphQLClient();
    isAuthCheck();
    UserService.firebaseAuth.authStateChanges().listen((firebaseUser) {
      print(firebaseUser);
      if (firebaseUser == null && UserService.isAuthenticated) {
        navigatorKey.currentState.popAndPushNamed('/logout');
        // Navigator.of(context).popAndPushNamed('/logout');
      }
    });
  }

  Future<void> isAuthCheck() async {
    try {
      var currentUser = UserService.firebaseAuth.currentUser;
      if (currentUser == null) {
        UserService.isAuthenticated = false;

        setState(() {
          isLoading = false;
        });
      } else {
        UserService.isAuthenticated = true;

        await userService.linkGoogleAccount();

        setState(() {
          isLoading = false;
        });

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Color.fromARGB(0, 1, 56, 112),
          ),
        );
      }
    } catch (err) {
      UserService.isAuthenticated = false;

      setState(() {
        isLoading = false;
      });
    }

    // var isAuthed = await userService.signInWithGoogle();
    // if (isAuthed) {
    //   UserService.isAuthenticated = true;

    //   setState(() {
    //     isLoading = false;
    //   });

    //   SystemChrome.setSystemUIOverlayStyle(
    //     SystemUiOverlayStyle(
    //       statusBarColor: Color.fromARGB(0, 1, 56, 112),
    //     ),
    //   );
    // } else {
    //   if (this.mounted) {
    //     UserService.isAuthenticated = false;

    //     setState(() {
    //       isLoading = false;
    //     });
    //   }
    // }
  }

  Future<void> handleLogoutRoute() async {
    await userService.signOutGoogle();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? getLoadingScreen() : getHomeScreen(context);
  }

  Widget getLoadingScreen() {
    return MaterialApp(
      home: LoadingScreen(),
    );
  }

  Widget getHomeScreen(context) {
    return GraphQLProvider(
      client: ValueNotifier<GraphQLClient>(GqlClientFactory.client),
      child: CacheProvider(
        child: MaterialApp(
            title: 'ATLAS CRM',
            theme: defaultTheme,
            navigatorKey: navigatorKey,
            // ThemeData(
            //   appBarTheme: AppBarTheme(color: Colors.red),
            //   primarySwatch: Colors.red,
            //   backgroundColor: Colors.orange,
            //   brightness: Brightness.light,
            //   fontFamily: "LatoRegular",
            // ),
            home: UserService.isAuthenticated
                ? DashboardScreen()
                : WillPopScope(
                    onWillPop: () async {
                      print("main trying to pop");
                      return false;
                    },
                    child: AuthScreen()),
            initialRoute: "/",
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/dashboard':
                  print("navigated to: " + settings.name);
                  return MaterialPageRoute(
                      builder: (context) => DashboardScreen());
                  break;
                case "/leads":
                  return MaterialPageRoute(builder: (context) => LeadsScreen());
                  break;
                case "/merchants":
                  return MaterialPageRoute(
                      builder: (context) => MerchantsScreen());
                  break;
                case "/inventory":
                  return MaterialPageRoute(
                      builder: (context) => InventoryScreen());
                  break;
                case "/installs":
                  return MaterialPageRoute(
                      builder: (context) => InstallsScreen());
                  break;
                case "/logout":
                  handleLogoutRoute();
                  return MaterialPageRoute(builder: (context) => AtlasCRM());
                  break;
                case '/viewlead':
                  return SlideRightRoute(
                      page: ViewLeadScreen(settings.arguments));
                  break;
                case '/viewmerchant':
                  return SlideRightRoute(
                      page: ViewMerchantScreen(settings.arguments));
                  break;
                case '/viewinventory':
                  return SlideRightRoute(
                      page: ViewInventoryScreen(settings.arguments));
                  break;
                case '/viewinstall':
                  return SlideRightRoute(
                      page: ViewInstallScreen(settings.arguments));
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
                  return SlideRightRoute(
                      page: ViewTaskScreen(settings.arguments));
                  break;
                case '/agreementbuilder':
                  return SlideRightRoute(
                      page: AgreementBuilder(settings.arguments));
                  break;
                case '/camera':
                  return SlideRightRoute(
                      page: CameraPage(
                          cameras: cameras, callback: settings.arguments));
                  break;
                case '/mileage':
                  return MaterialPageRoute(
                      builder: (context) => MileageScreen());
                  break;
                case '/statementuploads':
                  return SlideRightRoute(
                      page: StatementUploader(settings.arguments));
                  break;
                case '/leadnotes':
                  return SlideRightRoute(page: LeadNotes(settings.arguments));
                  break;
                case '/leadtasks':
                  return SlideRightRoute(page: LeadTasks(settings.arguments));
                  break;
                case '/settings':
                  // return MaterialPageRoute(builder: (context) => SettingsScreen());
                  break;
              }
            }),
      ),
    );
  }
}
