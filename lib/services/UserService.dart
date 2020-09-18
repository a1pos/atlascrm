import 'dart:developer';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/services/api.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void initState() {
    firebaseAuth.onAuthStateChanged.listen((firebaseUser) async {
      print(firebaseUser);
      if (firebaseUser != null) {
        var linkResponse = await linkGoogleAccount();
        var user = await firebaseAuth.currentUser();
        var idTokenResult = await user.getIdToken();
        print(idTokenResult.claims);
        setPrivateGraphQLClient(idTokenResult.token);
        isAuthenticated = true;
        employee = linkResponse.data["linkGoogleAccount"]["employee"];
      } else {
        isAuthenticated = false;
        employee = Employee.getEmpty();
      }
    });
  }

  // Future<bool> isAuthenticated(context) async {
  //   try {
  //     print("about to check google sign in");
  //     var isGoogleSignedIn = await googleSignIn.isSignedIn();
  //     print("isGoogleSignedIn $isGoogleSignedIn");
  //     if (isGoogleSignedIn) {
  //       var googleSignInAccount =
  //           await googleSignIn.signInSilently(suppressErrors: false);
  //       googleSignInAuthentication = await googleSignInAccount.authentication;
  //       var firebaseUser = await firebaseAuth.currentUser();
  //       if (firebaseUser != null) {
  //         var isAuthed = await authorizeEmployee(context);
  //         if (isAuthed) {
  //           return true;
  //         }
  //       }
  //     }
  //   } catch (err) {
  //     print(err);
  //   }
  //   return false;
  // }

  Future<bool> signInWithGoogle(context) async {
    try {
      var googleSignInAccount = await googleSignIn.signIn();
      googleSignInAuthentication = await googleSignInAccount.authentication;

      await firebaseAuth.signInWithCredential(GoogleAuthProvider.getCredential(
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
    await firebaseAuth.signOut();
  }

  Future linkGoogleAccount() async {
    setPublicGraphQLClient();

    var user = await firebaseAuth.currentUser();
    print(user);
    MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
        mutation actionLink(\$uid: String!, \$email: String!) {
          linkGoogleAccount(uid: \$uid, email: \$email) {
              employee
          }
        }
    """), variables: {
      "email": user.email,
      "uid": user.uid,
    });
    final QueryResult result = await client.mutate(mutateOptions);

    if (result.hasException) {
      return null;
    } else {
      var idTokenResult = await user.getIdToken(refresh: true);
      print(idTokenResult);
      var empDecoded = result.data["linkGoogleAccount"]["employee"];
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
      setPrivateGraphQLClient(idTokenResult.token);
      return result;
    }
  }

  Employee getCurrentEmployee() {
    return employee;
  }

  // Future<bool> authorizeEmployee(context) async {
  //   setPublicGraphQLClient();
  //   var user = await firebaseAuth.currentUser();
  //   try {
  //     QueryOptions queryOptions = QueryOptions(
  //       documentNode: gql("""
  //               query{
  //                 authorize(input:"${googleSignIn.currentUser.id}"){
  //                   employee
  //                   document
  //                   employee_account_type
  //                   company{company}
  //                   is_active
  //                 }}
  //           """),
  //     );
  //     final QueryResult result = await client.query(queryOptions);

  //     if (result.hasException == false && result.data["authorize"] != null) {
  //       var empDecoded = result.data["authorize"];
  //       employee = Employee.fromJson({
  //         "employee": empDecoded["employee"],
  //         "is_active": empDecoded["is_active"],
  //         "document": empDecoded["document"],
  //         "employee_account_type": empDecoded["employee_account_type"],
  //         "company": empDecoded["company"]["company"],
  //       });
  //       var roles = [];
  //       if (employee.document["roles"] != null) {
  //         roles = List.from(employee.document["roles"]);
  //       }
  //       if (roles.contains("admin")) {
  //         isAdmin = true;
  //         socketService.initWebSocketConnection();
  //       } else {
  //         isAdmin = false;
  //       }
  //       if (roles.contains("tech")) {
  //         isTech = true;
  //         socketService.initWebSocketConnection();
  //       } else {
  //         isTech = false;
  //       }
  //       return true;
  //     }
  //     return false;
  //   } catch (err) {
  //     print(err);
  //   }
  //   return false;
  // }

  static Future<FirebaseUser> getCurrentUser() async {
    try {
      return await firebaseAuth.currentUser();
    } catch (err) {
      log(err);
    }

    return null;
  }
}
