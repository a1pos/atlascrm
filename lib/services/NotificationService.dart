import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  factory NotificationService() => _instance;

  static final NotificationService _instance = NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static String _token;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
          onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //update is_read
      }, onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
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
}
