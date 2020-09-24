import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String HOOK_API_URL = "http://atlascrm.us:4433";

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
