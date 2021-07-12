import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:round2crm/services/FirebaseCESService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:round2crm/models/Employee.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/config/ConfigSettings.dart';

class UserService {
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar']);

  final String URLBASE = ConfigSettings.HOOK_API_URL;

  static Employee employee;

  static bool isAdmin = false;
  static bool isTech = false;
  static bool isSalesManager = false;
  static bool isCorporateTech = false;
  static bool isAuthenticated = false;

  static String token;
  static String rToken;

  static GoogleSignInAuthentication googleSignInAuthentication;

  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output: CustomOuput(),
  );

  getToken() async {
    try {
      var user = firebaseAuth.currentUser;
      if (user == null) {
        isAuthenticated = false;
        employee = Employee.getEmpty();
        return;
      } else {
        var idTokenResult = await user.getIdToken();
        return idTokenResult;
      }
    } catch (err) {
      logger.e(err.toString());
      throw new Error();
    }
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    logger.i("App version: " + version);
    return version;
  }

  Future<bool> signInWithGoogle() async {
    try {
      await Firebase.initializeApp();

      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await firebaseAuth.signInWithCredential(credential);
      final User user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final User currentUser = firebaseAuth.currentUser;
        assert(user.uid == currentUser.uid);

        logger.i('signInWithGoogle succeeded: $user');

        await linkGoogleAccount();

        return true;
      }
    } catch (err) {
      logger.e(err.toString());
      debugPrint(err.toString());
    }
    return false;
  }

  Future<void> signOutGoogle() async {
    try {
      if (isAuthenticated) {
        await googleSignIn.signOut();
        await firebaseAuth.signOut();
      }

      isAuthenticated = false;

      logger.i("User signed out");
      debugPrint("User signed out");
    } catch (err) {
      logger.e(err.toString());
      debugPrint(err.toString());
      throw new Error();
    }
  }

  Future<void> linkGoogleAccount() async {
    try {
      GqlClientFactory.setPublicGraphQLClient();

      logger.i("Connecting to hooks API: " + URLBASE.toString());
      logger.i("Connecting to Hasura: " + ConfigSettings.HASURA_URL.toString());
      logger.i("Connecting to Websocket: " +
          ConfigSettings.HASURA_WEBSOCKET.toString());

      var user = firebaseAuth.currentUser;

      logger.i("User: " + user.displayName.toString() + " (" + user.uid + ")");
      getVersionNumber();

      MutationOptions mutateOptions = MutationOptions(
        document: gql("""
        mutation ACTION_LINK(\$uid: String!, \$email: String!) {
          link_google_account(uid: \$uid, email: \$email) {
              employee
              token
              refreshToken
          }
        }
    """),
        fetchPolicy: FetchPolicy.noCache,
        variables: {
          "email": user.email,
          "uid": user.uid,
        },
      );
      final QueryResult linkResult =
          await GqlClientFactory().authGqlmutate(mutateOptions);

      if (linkResult.hasException) {
        debugPrint(
            "Error linking google account: " + linkResult.exception.toString());
        logger.e(
            "Error linking google account: " + linkResult.exception.toString());
        throw (linkResult.exception);
      } else {
        token = linkResult.data["link_google_account"]["token"];
        rToken = linkResult.data["link_google_account"]["refreshToken"];
        var idTokenResult = await user.getIdToken(true);
        debugPrint("ID Token result: " + idTokenResult);

        var empDecoded = linkResult.data["link_google_account"]["employee"];

        employee = Employee.fromJson(empDecoded);
        logger.i("Employee role: " + employee.role.toString());

        if (employee.role == "admin" || employee.role == "sa") {
          isAdmin = true;
        } else {
          isAdmin = false;
        }
        if (employee.role == "tech") {
          isTech = true;
        } else {
          isTech = false;
        }
        if (employee.role == "corporate_tech") {
          isCorporateTech = true;
        } else {
          isCorporateTech = false;
        }

        if (employee.role == "salesmanager") {
          isSalesManager = true;
        } else {
          isSalesManager = false;
        }

        GqlClientFactory.setPrivateGraphQLClient(idTokenResult);
        String companyId = empDecoded["company"];
        QueryOptions companyQueryOptions = QueryOptions(
          document: gql("""
        query GET_COMPANY {
          company_by_pk(company: "$companyId") {
            company
            title
          }
        }
      """),
        );

        final QueryResult companyResult =
            await GqlClientFactory().authGqlquery(companyQueryOptions);

        if (companyResult.hasException == false) {
          employee.companyName = companyResult.data["company_by_pk"]["title"];
        }

        var registrationToken = FirebaseCESService.getToken();

        MutationOptions notificationRegistrationMutateOptions =
            MutationOptions(document: gql("""
        mutation REGISTER_NOTIFICATION_TOKEN(\$uid: String!, \$registration_token: String!) {
          register_notification_token(uid: \$uid, registration_token: \$registration_token) {
              message
          }
        }
    """), fetchPolicy: FetchPolicy.noCache, variables: {
          "registration_token": registrationToken,
          "uid": user.uid,
        });

        final QueryResult notificationRegistrationResult =
            await GqlClientFactory.client
                .mutate(notificationRegistrationMutateOptions);

        debugPrint("Registration token result: " +
            notificationRegistrationResult.data['register_notification_token']
                    ['message']
                .toString());
      }
    } catch (err) {
      logger.e(err.toString());
      debugPrint(err.toString());
      throw new Error();
    }
  }

  Employee getCurrentEmployee() {
    return employee;
  }

  static Future<User> getCurrentUser() async {
    try {
      return firebaseAuth.currentUser;
    } catch (err) {
      debugPrint(err.toString());
    }

    return null;
  }

  Future<bool> exchangeRefreshToken() async {
    MutationOptions mutateOptions = MutationOptions(
      document: gql("""
     mutation REFRESH_TOKEN(\$token: String!, \$refreshToken: String!) {
        refresh_token(token: \$token, refreshToken: \$refreshToken) {
            token
          }
        }
  """),
      variables: {"token": token, "refreshToken": rToken},
    );

    final QueryResult result =
        await GqlClientFactory().authGqlmutate(mutateOptions);
    if (result.hasException == true) {
      logger.e(result.exception.toString());

      try {
        signOutGoogle();
        return false;
      } catch (err) {
        logger.e(err.toString());
        debugPrint(err.toString());
        throw new Error();
      }
    } else {
      token = result.data["refresh_token"]["token"];
      return true;
    }
  }
}
