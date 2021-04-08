import 'package:atlascrm/services/ApiService.dart';
import 'package:atlascrm/services/GqlClientFactory.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:async';

enum FirebaseCMType { launch, resume, backgroundMessage, message }

class FirebaseCESService {
  static final FirebaseCESService _singleton = FirebaseCESService._internal();
  static final ApiService apiService = new ApiService();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static const platform = const MethodChannel('com.ces.atlascrm.channel');

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
      // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      //   myBackgroundMessageHandler(message);
      // });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        handleFirebaseMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleFirebaseMessage(message);
      });

      // _firebaseMessaging.configure(
      //     onBackgroundMessage: myBackgroundMessageHandler,
      //     //onMessage hit when app is open
      //     onMessage: (Map<String, dynamic> message) async {
      //       handleFirebaseMessage(FirebaseCMType.message, message);
      //     },
      //     onLaunch: (Map<String, dynamic> message) async {
      //       handleFirebaseMessage(FirebaseCMType.launch, message);
      //     },
      //     onResume: (Map<String, dynamic> message) async {
      //       handleFirebaseMessage(FirebaseCMType.resume, message);
      //     });

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      _token = token;

      _initialized = true;
    }
  }

  static String getToken() {
    return _token;
  }

  static Future<dynamic> myBackgroundMessageHandler(message) async {
    handleFirebaseMessage(message);
  }

  static Future<void> handleFirebaseMessage(message) async {
    print("$message");

    if (message == null) return null;
    print("has a message");

    var messageData = message.data;
    if (messageData == null) return null;
    print("has messageData: $messageData");

    var messageActionType = messageData["type"];
    if (messageActionType == null) return null;
    print("has messageActionType: $messageActionType");

    switch (messageActionType) {
      case "IGNORE":
        return null;
        break;
      case "CAMERA_LINK":
        print("OPEN THE CAMERA");
        var result = await platform.invokeMethod("openCamera");
        print("FILE URI: $result");

        var options = MutationOptions(
            document: gql("""
          mutation REMOVE_PHONE_LINK(\$phone_link_stream: uuid!) {
            update_phone_link_stream_by_pk(pk_columns: {phone_link_stream: \$phone_link_stream},_set:{completed:true}){
              phone_link_stream
            }
          }
          """),
            variables: {"phone_link_stream": messageData["phone_link_stream"]},
            fetchPolicy: FetchPolicy.networkOnly);

        if (result == null) {
          await GqlClientFactory().authGqlmutate(options);
          return;
        }

        try {
          var formData = FormData.fromMap({
            "agreementBuilder": messageData["agreementBuilder"],
            messageData["uploadType"]: await MultipartFile.fromFile(result)
          });

          var resp = await apiService.authFilePostWithFormData(
              null, "/api/agreement/omaha/documents/upload", formData);

          await GqlClientFactory().authGqlmutate(options);
          if (resp.statusCode != 200) {
            print(resp);
          }
        } catch (err) {
          print(err);
        }
        break;
    }
  }
}
