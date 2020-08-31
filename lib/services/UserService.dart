import 'dart:developer';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/SocketService.dart';
import 'package:atlascrm/services/api.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserService {
  static Employee employee;

  static bool isAdmin = false;
  static bool isTech = false;

  final ApiService apiService = new ApiService();
  final SocketService socketService = new SocketService();

  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar']);

  static GoogleSignInAuthentication googleSignInAuthentication;

  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<bool> isAuthenticated(context) async {
    try {
      print("about to check google sign in");
      var isGoogleSignedIn = await googleSignIn.isSignedIn();
      print("isGoogleSignedIn $isGoogleSignedIn");
      if (isGoogleSignedIn) {
        var googleSignInAccount =
            await googleSignIn.signInSilently(suppressErrors: false);
        googleSignInAuthentication = await googleSignInAccount.authentication;
        var firebaseUser = await firebaseAuth.currentUser();
        if (firebaseUser != null) {
          var isAuthed = await authorizeEmployee(context);
          if (isAuthed) {
            return true;
          }
        }
      }
    } catch (err) {
      print(err);
    }
    return false;
  }

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
    var user = await firebaseAuth.currentUser();
    MutationOptions mutateOptions = MutationOptions(
      onCompleted: (resultData) async {
        print(await resultData);
      },
      documentNode: gql("""
                   mutation {
                    add_employee(
                      input: { employee_account_type: 2, document: {
                          googleIdToken: "${googleSignInAuthentication.idToken}",
                          googleClaims: {
                            picture: "${user.photoUrl}"
                          },
                          fullName: "${user.displayName}",
                          email: "${user.email}",
                          googleUserId: "${googleSignIn.currentUser.id}"
                        } 
                      }
                    )
                  }
            """),
    );
    final QueryResult result = await client.mutate(mutateOptions);

    if (result.hasException) {
      print(result.exception.toString());
      return;
    } else {
      print(result.data);
      return result.data;
    }
    // var userObj = {
    //   'fullName': user.displayName,
    //   'email': user.email,
    //   'googleUserId': googleSignIn.currentUser.id
    // };
    // return await apiService.publicPost("link", userObj);
  }

  Employee getCurrentEmployee() {
    return employee;
  }

  Future<bool> authorizeEmployee(context) async {
    try {
      var user = await firebaseAuth.currentUser();
      QueryOptions queryOptions = QueryOptions(
        documentNode: gql("""
                query{
                  authorize(input:"${googleSignIn.currentUser.id}"){
                    employee
                    document
                    employee_account_type
                    company
                    is_active
                  }}
            """),
      );
      final QueryResult result = await client.query(queryOptions);
      print(result);
      if (result.hasException == false) {
        var empDecoded = result.data["authorize"];
        employee = Employee.fromJson(empDecoded);
        var roles = List.from(employee.document["roles"]);
        if (roles.contains("admin")) {
          isAdmin = true;
          socketService.initWebSocketConnection();
        } else {
          isAdmin = false;
        }
        if (roles.contains("tech")) {
          isTech = true;
          socketService.initWebSocketConnection();
        } else {
          isTech = false;
        }
        return true;
      }
    } catch (err) {
      print(err);
    }
    return false;
  }

  static Future<FirebaseUser> getCurrentUser() async {
    try {
      return await firebaseAuth.currentUser();
    } catch (err) {
      log(err);
    }

    return null;
  }
}
