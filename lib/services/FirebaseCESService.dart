import 'package:round2crm/services/ApiService.dart';
import 'package:round2crm/services/GqlClientFactory.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

import 'package:logger/logger.dart';

enum FirebaseCMType { launch, resume, backgroundMessage, message }

class FirebaseCESService {
  static final FirebaseCESService _singleton = FirebaseCESService._internal();
  static final ApiService apiService = new ApiService();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static const platform = const MethodChannel('com.ces.atlascrm.channel');

  static String _token;
  static bool _initialized = false;

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output:
  );

  factory FirebaseCESService() {
    return _singleton;
  }

  FirebaseCESService._internal();

  Future<dynamic> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    if (!_initialized) {
      // For iOS request permission first.

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: "@drawable/ic_notification",
              ),
            ),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        logger.i("A new onMessageOpenedApp event was published");

        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: "@drawable/ic_notification",
                color: Color.fromARGB(1, 58, 179, 171),
              ),
            ),
          );
        }
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

  Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    logger.i("Handling a background message ${message.messageId}");
  }

  Future<void> handleFirebaseMessage(message) async {
    logger.i("{$message}");

    if (message == null) return null;
    logger.i(message.body);

    var messageActionType = "IGNORE";
    if (messageActionType == null) return null;

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
            variables: {"phone_link_stream": message["phone_link_stream"]},
            fetchPolicy: FetchPolicy.noCache);

        if (result == null) {
          await GqlClientFactory().authGqlmutate(options);
          return;
        }

        try {
          var formData = FormData.fromMap({
            "agreementBuilder": message["agreementBuilder"],
            message["uploadType"]: await MultipartFile.fromFile(result)
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
