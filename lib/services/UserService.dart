import 'dart:developer';
import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:atlascrm/models/Employee.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/SocketService.dart';
import 'package:atlascrm/services/StorageService.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  static Employee employee;
  static bool isAdmin = false;
  final ApiService apiService = new ApiService();
  final SocketService socketService = new SocketService();
  GoogleSignInAccount currentUser;
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

  Future<bool> signInWithGoogle(context) async {
    try {
      var googleSignInAccount = await googleSignIn.signIn();
      var googleSignInAuthentication = await googleSignInAccount.authentication;
      await storageService.save("token", googleSignInAuthentication.idToken);
      await storageService.save(
          "access_token", googleSignInAuthentication.accessToken);
      currentUser = googleSignIn.currentUser;
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
    var userAuth = await currentUser.authentication;
    var userObj = {
      "googleIdToken": userAuth.idToken,
      'fullName': currentUser.displayName,
      'email': currentUser.email,
      "googleUserId": currentUser.id
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
        // var token = await storageService.read("token");
        // var accessToken = await storageService.read("access_token");
        // if (token != null) {
        //   ConfigSettings.GOOGLE_TOKEN = token;
        //   ConfigSettings.ACCESS_TOKEN = accessToken;
        // }
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
