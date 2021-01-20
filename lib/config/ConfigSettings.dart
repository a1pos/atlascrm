import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String HOOK_API_URL =
      !kReleaseMode ? "http://atlascrm.us:4433" : "http://atlascrm.us:4434";

  static String HASURA_URL = !kReleaseMode
      ? "https://hasura-prod.atlascrm.us/v1/graphql"
      : "https://hasura-dev.atlascrm.us/v1/graphql";

  static String HASURA_WEBSOCKET = !kReleaseMode
      ? "wss://hasura-prod.atlascrm.us/v1/graphql"
      : "wss://hasura-dev.atlascrm.us/v1/graphql";

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
