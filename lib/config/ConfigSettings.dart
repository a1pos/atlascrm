import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String HOOK_API_URL = "http://atlascrm.us:4433";

  static String HASURA_URL = kReleaseMode
      ? "https://busy-buzzard-29.hasura.app/v1/graphql"
      : "https://blessed-platypus-84.hasura.app/v1/graphql";

  static String HASURA_WEBSOCKET = kReleaseMode
      ? "wss://busy-buzzard-29.hasura.app/v1/graphql"
      : "wss://blessed-platypus-84.hasura.app/v1/graphql";

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
