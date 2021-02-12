import 'dart:async';
import 'package:atlascrm/config/ConfigSettings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'UserService.dart';

class GqlClientFactory {
  static GraphQLClient client;
  static HttpLink _httpLink = HttpLink(
    uri: ConfigSettings.HASURA_URL,
  );
  static InMemoryCache cache = InMemoryCache();
  static InMemoryCache cache2 = InMemoryCache();
  UserService userService = UserService();
  static bool isRefreshing = false;

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
    }
  }

  Future<StreamSubscription<FetchResult>> authGqlsubscribe(
      options, Function onData, Function onError, Function refresh) async {
    try {
      var result = client.subscribe(options);

      StreamSubscription<FetchResult> subscription = result.listen(
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
    Link authwserr;

    final AuthLink _authLink = AuthLink(
      getToken: () async => 'Bearer ${UserService.token}',
    );

    WebSocketLink _wsLink = WebSocketLink(
        url: ConfigSettings.HASURA_WEBSOCKET,
        config: SocketClientConfig(
          autoReconnect: true,
          inactivityTimeout: Duration(seconds: 30),
          initPayload: () {
            return {
              'headers': {'Authorization': 'Bearer ${UserService.token}'}
            };
          },
        ));
    // ErrorLink _errorLink = ErrorLink(errorHandler: (ErrorResponse error) {
    //   print("=========ERRORLINK===========");
    //   var errMsg = error.exception.clientException.message;
    //   print(errMsg);
    //   if (errMsg.contains("JWTExpired")) {
    //     print("ATTEMPTING TO REFRESH TOKENS");
    //     UserService().exchangeRefreshToken();
    //     error.operation.setContext({
    //       "headers": {"Authorization": 'Bearer ${UserService.token}'}
    //     });
    //   }
    // });

    //WITHOUT ERRORLINK
    link = _authLink.concat(_httpLink);
    authws = _wsLink.concat(_authLink);
    link = link.concat(authws);

    //WITH ERRORLINK
    // authws = _wsLink.concat(_authLink);
    // link = _errorLink.concat(authws.concat(_httpLink));

    final GraphQLClient aCLient = GraphQLClient(link: link, cache: cache);

    client = aCLient;
  }

  static void setPublicGraphQLClient() {
    final GraphQLClient aCLient = GraphQLClient(link: _httpLink, cache: cache);
    client = aCLient;
  }
}
