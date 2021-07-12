import 'package:flutter/foundation.dart';

class ConfigSettings {
  static String HOOK_API_URL = kReleaseMode
      ? "https://api-prod.round2crm.com"
      : "https://api-dev.round2crm.com";

  static String HASURA_URL = kReleaseMode
      ? "https://hasura-prod.round2crm.com/v1/graphql"
      : "https://hasura-dev.round2crm.com/v1/graphql";

  static String HASURA_WEBSOCKET = kReleaseMode
      ? "wss://hasura-prod.round2crm.com/v1/graphql"
      : "wss://hasura-dev.round2crm.com/v1/graphql";

  static String GOOGLE_TOKEN = "";

  static String ACCESS_TOKEN = "";

  getGoogleToken() {
    return GOOGLE_TOKEN;
  }

  getAccessToken() {
    return ACCESS_TOKEN;
  }
}
