import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String HOOK_API_URL = kReleaseMode
      ? "https://api-prod.atlascrm.us"
      // : "http://192.168.100.53:4434";
      : "https://api-dev.atlascrm.us";

  static String HASURA_URL = kReleaseMode
      ? "https://hasura-prod.atlascrm.us/v1/graphql"
      // ? "http://24.154.179.10:10051/v1/graphql"
      // : "http://192.168.100.53:10050/v1/graphql";
      : "https://hasura-dev.atlascrm.us/v1/graphql";

  static String HASURA_WEBSOCKET = kReleaseMode
      ? "wss://hasura-prod.atlascrm.us/v1/graphql"
      // ? "ws://24.154.179.10:10051/v1/graphql"
      : "wss://hasura-dev.atlascrm.us/v1/graphql";
  // : "ws://192.168.100.53:10050/v1/graphql";

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
