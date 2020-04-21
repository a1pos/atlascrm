import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String API_URL = kReleaseMode
      ? "http://35.199.31.18/api/v1/"
      : "http://192.168.1.45:3002/api/v1/";
  static String WS_URL =
      kReleaseMode ? "ws://35.199.31.18:3003" : "ws://192.168.1.45:3003";

  static String GOOGLE_TOKEN = "";

  static String ACCESS_TOKEN = "";

  getApiUrl() {
    return API_URL;
  }

  getGoogleToken() {
    return GOOGLE_TOKEN;
  }
  getAccessToken(){
    return ACCESS_TOKEN;
  }
}
