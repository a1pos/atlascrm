import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String API_URL = !kReleaseMode
      ? "https://butlerbizsys.com/api/v1/"
      : "http://192.168.1.30:3002/api/v1/";
  static String WS_URL =
      !kReleaseMode ? "wss://butlerbizsys.com" : "ws://192.168.1.30:3002";

  static String PUSHER_KEY = '78b022eea08a75c792e5';

  static String GOOGLE_TOKEN = "";

  static String ACCESS_TOKEN = "";

  getApiUrl() {
    return API_URL;
  }

  getGoogleToken() {
    return GOOGLE_TOKEN;
  }

  getAccessToken() {
    return ACCESS_TOKEN;
  }
}
