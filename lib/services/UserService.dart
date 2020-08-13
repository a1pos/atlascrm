import 'dart:developer';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/SocketService.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<Response> linkGoogleAccount() async {
    var user = await firebaseAuth.currentUser();
    var userObj = {
      'fullName': user.displayName,
      'email': user.email,
      'googleUserId': googleSignIn.currentUser.id
    };
    return await apiService.publicPost("link", userObj);
  }

  Employee getCurrentEmployee() {
    return employee;
  }

  Future<bool> authorizeEmployee(context) async {
    try {
      var employeeAuthResp = await apiService.authGet(context, "/authorize");
      if (employeeAuthResp.statusCode == 200) {
        var empDecoded = employeeAuthResp.data;
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
