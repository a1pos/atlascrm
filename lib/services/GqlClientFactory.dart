import 'dart:async';
import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'UserService.dart';

class GqlClientFactory {
  static GraphQLClient client;
  static HttpLink _httpLink = HttpLink(
    ConfigSettings.HASURA_URL,
  );
  static GraphQLCache cache = GraphQLCache();
  static GraphQLCache cache2 = GraphQLCache();
  static bool isRefreshing = false;

  UserService userService = UserService();

  Future<QueryResult> authGqlquery(options) async {
    try {
      var result = await client.query(options);
      if (result != null) {
        if (result.hasException != false) {
          var errMsg = result.exception.toString();
          print(errMsg);
          if (errMsg.contains("JWTExpired")) {
            await refreshClient();
            result = await client.query(options);
          } else {
            Fluttertoast.showToast(
                msg: errMsg,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }
      }
      return result;
    } catch (err) {
      print(err);
      throw new Error();
    }
  }

  Future<QueryResult> authGqlmutate(options) async {
    try {
      var result = await client.mutate(options);
      if (result != null) {
        if (result.hasException != false) {
          var errMsg = result.exception.toString();
          print(errMsg);
          if (errMsg.contains("JWTExpired")) {
            await refreshClient();
            result = await client.mutate(options);
          } else {
            Fluttertoast.showToast(
                msg: errMsg,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }
      }
      return result;
    } catch (err) {
      print(err);
      throw new Error();
    }
  }

  Future<StreamSubscription> authGqlsubscribe(
      options, Function onData, Function onError, Function refresh) async {
    try {
      var result = client.subscribe(options);

      StreamSubscription subscription = result.listen(
        (data) async {
          onData(data);
        },
        onError: (error) async {
          var errMsg = error.toString();

          print(errMsg);
          if (errMsg.contains("JWTExpired")) {
            await refreshClient();
            onError(error);
            refresh();
          } else {
            onError(error);
            Fluttertoast.showToast(
                msg: errMsg,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
          }
        },
      );
      return subscription;
    } catch (err) {
      print(err);
      throw new Error();
    }
  }

  static refreshClient() async {
    if (!isRefreshing) {
      isRefreshing = true;
      print("TRYING TO REFRESH CLIENT");
      //set a public client so we can refresh tokens
      setPublicGraphQLClient();
      print("CLIENT SET TO PUBLIC");
      var success = await UserService().exchangeRefreshToken();
      if (success) {
        print("TOKEN REFRESHED");
        setPrivateGraphQLClient(UserService.token);
        print("CLIENT SET TO PRIVATE");
      } else {
        print("REFRESH TOKEN TIMED OUT: SIGNING OUT");
      }
      isRefreshing = false;
    }
  }

  static void setPrivateGraphQLClient(token) async {
    Link link;
    Link authws;
    final AuthLink _authLink = AuthLink(
      getToken: () async => 'Bearer ${UserService.token}',
    );

    final policies = Policies(
      cacheReread: CacheRereadPolicy.ignoreAll,
      fetch: FetchPolicy.networkOnly,
    );

    WebSocketLink _wsLink = WebSocketLink(
      ConfigSettings.HASURA_WEBSOCKET,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
        initialPayload: () {
          return {
            'headers': {'Authorization': 'Bearer ${UserService.token}'}
          };
        },
      ),
    );

    //WITHOUT ERRORLINK
    link = _authLink.concat(_httpLink);
    authws = _wsLink.concat(_authLink);
    link = link.concat(authws);
    link = Link.split((request) => request.isSubscription, _wsLink, link);

    final GraphQLClient aCLient = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        subscribe: policies,
        watchQuery: policies,
        query: policies,
        mutate: policies,
      ),
    );

    client = aCLient;
  }

  static void setPublicGraphQLClient() {
    final policies = Policies(
      cacheReread: CacheRereadPolicy.ignoreAll,
      fetch: FetchPolicy.noCache,
    );

    final GraphQLClient aCLient = GraphQLClient(
      link: _httpLink,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        subscribe: policies,
        query: policies,
        mutate: policies,
      ),
    );
    client = aCLient;
  }
}
