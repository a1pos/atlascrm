import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:round2crm/services/UserService.dart';
import 'package:round2crm/components/shared/LoadingScreen.dart';
import 'package:round2crm/components/shared/SlideRightRoute.dart';
import 'package:round2crm/components/style/UniversalStyles.dart';
import 'package:round2crm/screens/auth/AuthScreen.dart';
import 'package:round2crm/screens/dashboard/DashboardScreen.dart';
import 'package:round2crm/screens/employees/EmployeeListScreen.dart';
import 'package:round2crm/screens/employees/EmployeeMapHistoryScreen.dart';
import 'package:round2crm/screens/employees/SalesMapScreen.dart';
import 'package:round2crm/screens/employees/EmployeesManagementScreen.dart';
import 'package:round2crm/services/FirebaseCESService.dart';
import 'package:round2crm/screens/leads/LeadNotes.dart';
import 'package:round2crm/screens/leads/LeadTasks.dart';
import 'package:round2crm/screens/leads/LeadsScreen.dart';
import 'package:round2crm/screens/inventory/InventoryScreen.dart';
import 'package:round2crm/screens/installs/InstallsScreen.dart';
import 'package:round2crm/screens/merchants/MerchantsScreen.dart';
import 'package:round2crm/screens/tasks/TaskScreen.dart';
import 'package:round2crm/screens/employees/ViewEmployeeScreen.dart';
import 'package:round2crm/screens/inventory/ViewInventoryScreen.dart';
import 'package:round2crm/screens/leads/ViewLeadScreen.dart';
import 'package:round2crm/screens/merchants/ViewMerchantScreen.dart';
import 'package:round2crm/screens/tasks/ViewTaskScreen.dart';
import 'package:round2crm/screens/leads/uploads/StatementUploader.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseCESService().init();

  runApp(Round2CRM());
}

final UserService userService = new UserService();

class Round2CRM extends StatefulWidget {
  @override
  _Round2CRMState createState() => _Round2CRMState();
}

class _Round2CRMState extends State<Round2CRM> {
  bool isLoading = true;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  @override
  void initState() {
    super.initState();
    logger.i("Application initialized and starting PublicGQLClient");
    debugPrint("Application initialized and starting PublicGQLClient");
    GqlClientFactory.setPublicGraphQLClient();
    isAuthCheck();
    UserService.firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null && UserService.isAuthenticated) {
        navigatorKey.currentState.popAndPushNamed('/logout');
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
      debugPrint("Error checking authorization: " + err.toString());
      logger.e("Error checking authorization: " + err.toString());

      UserService.isAuthenticated = false;

      setState(
        () {
          isLoading = false;
        },
      );
    }
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
    FocusScope.of(context).requestFocus(new FocusNode());

    return GraphQLProvider(
      client: ValueNotifier<GraphQLClient>(GqlClientFactory.client),
      child: CacheProvider(
        child: MaterialApp(
          title: 'Round2 CRM',
          theme: defaultTheme,
          home: UserService.isAuthenticated
              ? DashboardScreen()
              : WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: AuthScreen(),
                ),
          initialRoute: "/",
          onGenerateRoute: (RouteSettings settings) {
            logger.i("Route switched to: " + settings.name);
            debugPrint("Route switched to: " + settings.name);
            switch (settings.name) {
              case '/dashboard':
                return MaterialPageRoute(
                  builder: (context) => DashboardScreen(),
                );
                break;
              case "/leads":
                return MaterialPageRoute(
                  builder: (context) => LeadsScreen(),
                );
                break;
              case "/merchants":
                return MaterialPageRoute(
                  builder: (context) => MerchantsScreen(),
                );
                break;
              case "/inventory":
                return MaterialPageRoute(
                  builder: (context) => InventoryScreen(),
                );
                break;
              case "/installs":
                return MaterialPageRoute(
                  builder: (context) => InstallsScreen(),
                );
                break;
              case "/logout":
                handleLogoutRoute();
                return MaterialPageRoute(builder: (context) => Round2CRM());
                break;
              case '/viewlead':
                return SlideRightRoute(
                  page: ViewLeadScreen(settings.arguments),
                );
                break;
              case '/viewmerchant':
                return SlideRightRoute(
                  page: ViewMerchantScreen(settings.arguments),
                );
                break;
              case '/viewinventory':
                return SlideRightRoute(
                  page: ViewInventoryScreen(settings.arguments),
                );
                break;
              case '/employeemgmt':
                return MaterialPageRoute(
                  builder: (context) => EmployeesManagementScreen(),
                );
                break;
              case '/salesmap':
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
              case '/viewemployee':
                return SlideRightRoute(
                  page: ViewEmployeeScreen(settings.arguments),
                );
                break;
              case '/viewtask':
                return SlideRightRoute(
                  page: ViewTaskScreen(settings.arguments),
                );
                break;
              case '/statementuploads':
                return SlideRightRoute(
                  page: StatementUploader(settings.arguments),
                );
                break;
              case '/leadnotes':
                return SlideRightRoute(
                  page: LeadNotes(settings.arguments),
                );
                break;
              case '/leadtasks':
                return SlideRightRoute(
                  page: LeadTasks(settings.arguments),
                );
                break;
            }
            return null;
          },
        ),
      ),
    );
  }
}
