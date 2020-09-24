import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String HOOK_API_URL =
      kReleaseMode ? "http://atlascrm.us:4433" : "http://192.168.1.45:3002";

  // static String WS_URL =
  //     kReleaseMode ? "wss://atlascrm.us" : "ws://192.168.1.45:3002";

  static String PUSHER_KEY = '78b022eea08a75c792e5';

  static String GOOGLE_TOKEN = "";

  static String ACCESS_TOKEN = "";

  // getApiUrl() {
  //   return API_URL;
  // }

  getGoogleToken() {
    return GOOGLE_TOKEN;
  }

  getAccessToken() {
    return ACCESS_TOKEN;
  }
}
