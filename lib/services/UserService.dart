import 'dart:developer';

import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/SocketService.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  static Employee employee;

  static bool isAdmin = false;

  final ApiService apiService = new ApiService();
  final SocketService socketService = new SocketService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar']);
  final StorageService storageService = new StorageService();

  Future<bool> isAuthenticated(context) async {
    try {
      var isGoogleSignedIn = await googleSignIn.isSignedIn();
      if (isGoogleSignedIn) {
        var isAuthed = await authorizeEmployee(context);
        if (isAuthed) {
          return true;
        }
      }
    } catch (err) {
      var blah = "asdf";
    }

    return false;
  }

  Future<String> getCurrentGoogleUserId() async {
    var user = await _auth.currentUser();
    return user.uid;
  }

  Future<bool> signInWithGoogle(context) async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
          await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      await storageService.save("token", googleSignInAuthentication.idToken);
      await storageService.save(
          "access_token", googleSignInAuthentication.accessToken);

      return true;
    } catch (err) {
      log(err);
    }

    return false;
  }

  Future<void> signOutGoogle() async {
    await storageService.delete("token");
    await storageService.delete("access_token");

    await googleSignIn.signOut();
  }

  Future<Response> linkGoogleAccount() async {
    var user = await _auth.currentUser();
    var idToken = await user.getIdToken();

    var provider = user.providerData
        .where((provider) => provider.providerId == "google.com");

    var googleComUser = provider.first;

    var userObj = {
      "googleIdToken": idToken.token,
      "googleExpTime": idToken.expirationTime.toString(),
      "googleClaims": idToken.claims,
      'fullName': googleComUser.displayName,
      'email': googleComUser.email,
      "googleUserId": googleComUser.uid
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
        var token = await storageService.read("token");
        var accessToken = await storageService.read("access_token");
        if (token != null) {
          ConfigSettings.GOOGLE_TOKEN = token;
          ConfigSettings.ACCESS_TOKEN = accessToken;
        }

        var empDecoded = employeeAuthResp.data;
        employee = Employee.fromJson(empDecoded);

        var roles = List.from(employee.document["roles"]);

        if (roles.contains("admin")) {
          isAdmin = true;
          socketService.initWebSocketConnection();
        } else {
          isAdmin = false;
        }

        return true;
      }
    } catch (err) {
      print(err);
    }

    return false;
  }
}
