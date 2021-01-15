import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String HOOK_API_URL =
      kReleaseMode ? "http://atlascrm.us:4433" : "http://atlascrm.us:4434";

  static String HASURA_URL = kReleaseMode
      ? "https://busy-buzzard-29.hasura.app/v1/graphql"
      : "http://24.154.179.10:10050/v1/graphql";

  static String HASURA_WEBSOCKET = kReleaseMode
      ? "wss://busy-buzzard-29.hasura.app/v1/graphql"
      : "ws://24.154.179.10:10050/v1/graphql";

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
