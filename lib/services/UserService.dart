import 'dart:async';
import 'dart:developer';
import 'package:atlascrm/services/FirebaseCESService.dart';
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
  static bool isSalesManager = false;
  static bool isAuthenticated = false;

  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar']);

  static GoogleSignInAuthentication googleSignInAuthentication;

  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  getToken() async {
    var user = firebaseAuth.currentUser;
    if (user == null) {
      isAuthenticated = false;
      employee = Employee.getEmpty();
      return;
    } else {
      var idTokenResult = await user.getIdToken();
      return idTokenResult;
    }
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

        print('signInWithGoogle succeeded: $user');

        await linkGoogleAccount();

        return true;
      }
    } catch (err) {
      print(err);
    }
    return false;
  }

  Future<void> signOutGoogle() async {
    isAuthenticated = false;

    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  Future<void> linkGoogleAccount() async {
    setPublicGraphQLClient();

    var user = firebaseAuth.currentUser;
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
      throw (linkResult.exception);
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
      if (employee.role == "salesmanager") {
        isSalesManager = true;
        // socketService.initWebSocketConnection();
      } else {
        isSalesManager = false;
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

      var registrationToken = FirebaseCESService.getToken();

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
    }
  }

  Employee getCurrentEmployee() {
    return employee;
  }

  static Future<User> getCurrentUser() async {
    try {
      return firebaseAuth.currentUser;
    } catch (err) {
      log(err);
    }

    return null;
  }
}
