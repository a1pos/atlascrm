import 'dart:async';
import 'dart:developer';
import 'package:atlascrm/services/NotificationService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/services/api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserService {
  static Employee employee;

  static bool isAdmin = false;
  static bool isTech = false;
  static bool isAuthenticated = false;

  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar']);

  static GoogleSignInAuthentication googleSignInAuthentication;

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // void startStreams() {
  //   _firebaseAuth.authStateChanges().listen((firebaseUser) async {
  //     print("AUTHSTATE CHANGES");
  //     // if (firebaseUser != null) {
  //     //   var user = _firebaseAuth.currentUser;
  //     //   var idTokenResult = await user.getIdToken();
  //     //   setPrivateGraphQLClient(idTokenResult);
  //     //   isAuthenticated = true;
  //     // } else {
  //     //   isAuthenticated = false;
  //     //   employee = Employee.getEmpty();
  //     // }
  //   });

  //   _firebaseAuth.idTokenChanges().listen((firebaseUser) async {
  //     print("ID TOKEN CHANGES");
  //     if (firebaseUser != null) {
  //       var user = _firebaseAuth.currentUser;
  //       var idTokenResult = await user.getIdToken();
  //       setPrivateGraphQLClient(idTokenResult);
  //       isAuthenticated = true;
  //     } else {
  //       isAuthenticated = false;
  //       employee = Employee.getEmpty();
  //     }
  //   });
  // }

  getToken() async {
    var user = _firebaseAuth.currentUser;
    if (user == null) {
      isAuthenticated = false;
      employee = Employee.getEmpty();
      return;
    } else {
      var idTokenResult = await user.getIdToken();
      return idTokenResult;
    }
  }

  Future<bool> signInWithGoogle(context) async {
    await Firebase.initializeApp();
    try {
      var googleSignInAccount = await googleSignIn.signIn();
      googleSignInAuthentication = await googleSignInAccount.authentication;

      await _firebaseAuth.signInWithCredential(GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      ));

      return true;
    } catch (err) {
      log(err);
    }
    return false;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future linkGoogleAccount() async {
    setPublicGraphQLClient();

    var user = _firebaseAuth.currentUser;
    print(user);
    MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
        mutation ACTION_LINK(\$uid: String!, \$email: String!) {
          link_google_account(uid: \$uid, email: \$email) {
              employee
          }
        }
    """), variables: {
      "email": user.email,
      "uid": user.uid,
    });
    final QueryResult linkResult = await client.mutate(mutateOptions);

    if (linkResult.hasException) {
      return null;
    } else {
      var idTokenResult = await user.getIdToken(true);
      print(idTokenResult);
      var empDecoded = linkResult.data["link_google_account"]["employee"];

      employee = Employee.fromJson(empDecoded);
      if (employee.role == "admin" || employee.role == "sa") {
        isAdmin = true;
        // socketService.initWebSocketConnection();
      } else {
        isAdmin = false;
      }
      if (employee.role == "tech") {
        isTech = true;
        // socketService.initWebSocketConnection();
      } else {
        isTech = false;
      }
      setPrivateGraphQLClient(idTokenResult);
      String companyId = empDecoded["company"];
      QueryOptions companyQueryOptions = QueryOptions(documentNode: gql("""
        query GET_COMPANY {
          company_by_pk(company: "$companyId") {
            company
            title
          }
        }
      """));

      final QueryResult companyResult = await client.query(companyQueryOptions);

      if (companyResult.hasException == false) {
        employee.companyName = companyResult.data["company_by_pk"]["title"];
      }

      var registrationToken = NotificationService.getToken();

      MutationOptions notificationRegistrationMutateOptions =
          MutationOptions(documentNode: gql("""
        mutation REGISTER_NOTIFICATION_TOKEN(\$uid: String!, \$registration_token: String!) {
          register_notification_token(uid: \$uid, registration_token: \$registration_token) {
              message
          }
        }
    """), variables: {
        "registration_token": registrationToken,
        "uid": user.uid,
      });

      final QueryResult notificationRegistrationResult =
          await client.mutate(notificationRegistrationMutateOptions);

      print(notificationRegistrationResult);

      return linkResult;
    }
  }

  Employee getCurrentEmployee() {
    return employee;
  }

  static Future<User> getCurrentUser() async {
    try {
      return _firebaseAuth.currentUser;
    } catch (err) {
      log(err);
    }

    return null;
  }
}
