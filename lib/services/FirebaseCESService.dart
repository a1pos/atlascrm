import 'dart:convert';

import 'package:atlascrm/services/ApiService.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http_parser/http_parser.dart';

import 'package:dio/dio.dart';

enum FirebaseCMType { launch, resume, backgroundMessage, message }

class FirebaseCESService {
  static final FirebaseCESService _singleton = FirebaseCESService._internal();
  static const platform = const MethodChannel('com.ces.atlascrm.channel');

  static final ApiService apiService = new ApiService();

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static String _token;
  static bool _initialized = false;

  factory FirebaseCESService() {
    return _singleton;
  }

  FirebaseCESService._internal();

  Future<void> init() async {
    await Firebase.initializeApp();

    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.configure(
          onBackgroundMessage: myBackgroundMessageHandler,
          //onMessage hit when app is open
          onMessage: (Map<String, dynamic> message) async {
            handleFirebaseMessage(FirebaseCMType.message, message);
          },
          onLaunch: (Map<String, dynamic> message) async {
            handleFirebaseMessage(FirebaseCMType.launch, message);
          },
          onResume: (Map<String, dynamic> message) async {
            handleFirebaseMessage(FirebaseCMType.resume, message);
          });

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      _token = token;

      _initialized = true;
    }
  }

  static String getToken() {
    return _token;
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    handleFirebaseMessage(FirebaseCMType.backgroundMessage, message);
  }

  static Future<void> handleFirebaseMessage(
      FirebaseCMType type, Map<String, dynamic> message) async {
    print("$type: $message");

    if (message == null) return null;
    print("has a message");

    var messageData = message["data"];
    if (messageData == null) return null;
    print("has messageData: $messageData");

    var messageActionType = messageData["type"];
    if (messageActionType == null) return null;
    print("has messageActionType: $messageActionType");

    var messagePayload = messageData["payload"];
    if (messagePayload == null) return null;
    print("has messagePayload: $messagePayload");

    var messagePayloadJson = jsonDecode(messagePayload);
    if (messagePayloadJson == null) return null;
    print("has messagePayloadJson: $messagePayloadJson");

    switch (messageActionType) {
      case "IGNORE":
        return null;
        break;
      case "CAMERA_LINK":
        print("OPEN THE FUCKING CAMERA");
        var result = await platform.invokeMethod("openCamera");
        print("FILE URI: $result");

        try {
          // var type = "application";
          // var subType = "octet-stream";
          // if (result.contains(".jpg") ||
          //     result.contains(".jpeg") ||
          //     result.contains(".JPG") ||
          //     result.contains(".JPEG")) {
          //   type = "image";
          //   subType = "jpeg";
          // }
          // if (result.contains(".png") || result.contains(".PNG")) {
          //   type = "image";
          //   subType = "png";
          // }

          var formData = FormData.fromMap({
            "agreementBuilder": messagePayloadJson["agreementBuilder"],
            messagePayloadJson["uploadType"]: await MultipartFile.fromFile(result)
          });

          var resp = await apiService.authFilePostWithFormData(
              null, "/api/agreement/omaha/documents/upload", formData);

          if (resp.statusCode == 200) {
          } else {}
        } catch (err) {
          print(err);
        }
        break;
    }
  }
}
