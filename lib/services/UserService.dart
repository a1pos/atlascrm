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

  Future linkGoogleAccount(context) async {
    var user = await firebaseAuth.currentUser();

    QueryOptions options = QueryOptions(documentNode: gql("""
        query EmployeeExistCheck(\$document: jsonb) {
              employee(where:  { document: { _contains: \$document } }) {
                    document
                    employee
                  }
                }
            """), pollInterval: 5, variables: {
      "document": {"email": "${user.email}"}
    });

    final QueryResult result1 = await client.query(options);

    print(result1);
    if (result1.data["employee"].length == 0) {
      MutationOptions mutateOptions = MutationOptions(documentNode: gql("""
              mutation linkNewEmployee(
                    \$company: uuid
                    \$document: jsonb
                    \$employee_account_type: Int
                  ) {
                    insert_employee(
                      objects: {
                        company: \$company
                        document: \$document
                        employee_account_type: \$employee_account_type
                        created_by: "00000000-0000-0000-0000-000000000000"
                        updated_by: "00000000-0000-0000-0000-000000000000"
                      }
                    ) {
                      returning {
                        company
                        employee
                        document
                        is_active
                      }
                    }
                  }
            """), variables: {
        "company": "e80724af-c512-41d5-96c3-4a890e4e62d5",
        "document": {
          "picture": user.photoUrl,
          "fullName": user.displayName,
          "email": user.email,
          "uid": user.uid,
          "roles": ["admin"]
        },
        "employee_account_type": 1
      });
      final QueryResult result = await client.mutate(mutateOptions);

      if (result.hasException) {
        return null;
      } else {
        var empDecoded = result1.data["employee"][0];
        employee = Employee.fromJson({
          "employee": empDecoded["employee"],
          // "is_active": empDecoded["is_active"],
          "document": empDecoded["document"],
          // "employee_account_type": empDecoded["employee_account_type"],
          // "company": empDecoded["company"]["company"],
        });
        var roles = [];
        if (employee.document["roles"] != null) {
          roles = List.from(employee.document["roles"]);
        }
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
    } else {
      var empDecoded = result1.data["employee"][0];
      employee = Employee.fromJson({
        "employee": empDecoded["employee"],
        // "is_active": empDecoded["is_active"],
        "document": empDecoded["document"],
        // "employee_account_type": empDecoded["employee_account_type"],
        // "company": empDecoded["company"]["company"],
      });
      var roles = [];
      if (employee.document["roles"] != null) {
        roles = List.from(employee.document["roles"]);
      }
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
  }

  Employee getCurrentEmployee() {
    return employee;
  }

  Future<bool> authorizeEmployee(context) async {
    var user = await firebaseAuth.currentUser();
    try {
      QueryOptions queryOptions = QueryOptions(
        documentNode: gql("""
                query{
                  authorize(input:"${googleSignIn.currentUser.id}"){
                    employee
                    document
                    employee_account_type
                    company{company}
                    is_active
                  }}
            """),
      );
      final QueryResult result = await client.query(queryOptions);

      if (result.hasException == false && result.data["authorize"] != null) {
        var empDecoded = result.data["authorize"];
        employee = Employee.fromJson({
          "employee": empDecoded["employee"],
          "is_active": empDecoded["is_active"],
          "document": empDecoded["document"],
          "employee_account_type": empDecoded["employee_account_type"],
          "company": empDecoded["company"]["company"],
        });
        var roles = [];
        if (employee.document["roles"] != null) {
          roles = List.from(employee.document["roles"]);
        }
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
      return false;
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
