import 'dart:async';
import 'dart:developer';
import 'package:atlascrm/services/FirebaseCESService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserService {
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar']);

  static Employee employee;

  static bool isAdmin = false;
  static bool isTech = false;
  static bool isSalesManager = false;
  static bool isAuthenticated = false;

  static String token;
  static String rToken;

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
    if (isAuthenticated) {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
    }
    isAuthenticated = false;
  }

  Future<void> linkGoogleAccount() async {
    GqlClientFactory.setPublicGraphQLClient();

    var user = firebaseAuth.currentUser;
    print(user);
    MutationOptions mutateOptions = MutationOptions(document: gql("""
        mutation ACTION_LINK(\$uid: String!, \$email: String!) {
          link_google_account(uid: \$uid, email: \$email) {
              employee
              token
              refreshToken
          }
        }
    """), variables: {
      "email": user.email,
      "uid": user.uid,
    });
    final QueryResult linkResult =
        await GqlClientFactory().authGqlmutate(mutateOptions);

    if (linkResult.hasException) {
      throw (linkResult.exception);
    } else {
      token = linkResult.data["link_google_account"]["token"];
      rToken = linkResult.data["link_google_account"]["refreshToken"];
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
    """), variables: {
        "registration_token": registrationToken,
        "uid": user.uid,
      });

      final QueryResult notificationRegistrationResult = await GqlClientFactory
          .client
          .mutate(notificationRegistrationMutateOptions);

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
      print(result.exception.toString());
      try {
        signOutGoogle();
        return false;
      } catch (err) {
        print(err);
        throw new Error();
      }
    } else {
      token = result.data["refresh_token"]["token"];
      return true;
    }
  }
}
