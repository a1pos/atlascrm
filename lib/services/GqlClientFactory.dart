import 'dart:async';
import 'package:round2crm/config/ConfigSettings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:round2crm/utils/CustomOutput.dart';
import 'package:round2crm/utils/LogPrinter.dart';
import 'UserService.dart';

class GqlClientFactory {
  static GraphQLClient client;
  static HttpLink _httpLink = HttpLink(
    ConfigSettings.HASURA_URL,
  );
  static GraphQLCache cache = GraphQLCache();
  static GraphQLCache cache2 = GraphQLCache();
  static bool isRefreshing = false;

  var logger = Logger(
    printer: SimpleLogPrinter(),
    output: CustomOutput(),
  );

  UserService userService = UserService();

  Future<QueryResult> authGqlquery(options) async {
    try {
      var result = await client.query(options);
      if (result != null) {
        if (result.hasException != false) {
          var errMsg = result.exception.toString();

          logger.e(errMsg);

          if (errMsg.contains("JWTExpired")) {
            await refreshClient();
            Future.delayed(Duration(seconds: 1), () {
              logger.i("JWTExpired authGqlquery: " + errMsg);
            });
            result = await client.query(options);
          } else {
            logger.e(errMsg);

            Fluttertoast.showToast(
              msg: errMsg,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        }
      }
      return result;
    } catch (err) {
      logger.e(err.toString());
      throw new Error();
    }
  }

  Future<QueryResult> authGqlmutate(options) async {
    try {
      var result = await client.mutate(options);
      if (result != null) {
        if (result.hasException != false) {
          var errMsg = result.exception.toString();

          logger.e(errMsg);

          if (errMsg.contains("JWTExpired")) {
            await refreshClient();
            Future.delayed(Duration(seconds: 1), () {
              logger.i("JWTExpired authGqlmutate: " + errMsg);
            });
            result = await client.mutate(options);
          } else {
            logger.e(errMsg);
            Fluttertoast.showToast(
              msg: errMsg,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        }
      }
      return result;
    } catch (err) {
      logger.e(err.toString());
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

          if (errMsg.contains("JWTExpired")) {
            await refreshClient();
            Future.delayed(Duration(seconds: 1), () {
              logger.i("JWTExpired authGqlsubscribe: " + errMsg);
            });

            onError(error);
            refresh();
          } else {
            onError(error);
            logger.e(errMsg);
            Fluttertoast.showToast(
              msg: errMsg,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
      );
      return subscription;
    } catch (err) {
      logger.e(err.toString());
      throw new Error();
    }
  }

  refreshClient() async {
    try {
      if (!isRefreshing) {
        isRefreshing = true;

        Future.delayed(Duration(seconds: 1), () {
          logger.i("Trying to refresh client");
        });
        //set a public client so we can refresh tokens
        setPublicGraphQLClient();
        Future.delayed(Duration(seconds: 1), () {
          logger.i("Client sent to public");
        });

        var success = await UserService().exchangeRefreshToken();
        if (success) {
          Future.delayed(Duration(seconds: 1), () {
            logger.i("Token refreshed");
          });
          setPrivateGraphQLClient(UserService.token);
          Future.delayed(Duration(seconds: 1), () {
            logger.i("CLIENT SET TO PRIVATE");
          });
        } else {
          debugPrint("REFRESH TOKEN TIMED OUT: SIGNING OUT");
          logger.e("Refresh token timed out: Signing Out");
        }
        isRefreshing = false;
      }
    } catch (err) {
      logger.e(err.toString());
      throw new Error();
    }
  }

  static void setPrivateGraphQLClient(token) async {
    try {
      Link link;
      Link authws;

      final AuthLink _authLink = AuthLink(
        getToken: () async => 'Bearer ${UserService.token}',
      );

      final policies = Policies(
        cacheReread: CacheRereadPolicy.ignoreAll,
        fetch: FetchPolicy.noCache,
      );

      WebSocketLink _wsLink = WebSocketLink(
        ConfigSettings.HASURA_WEBSOCKET,
        config: SocketClientConfig(
          autoReconnect: true,
          inactivityTimeout: Duration(seconds: 60),
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
      link = Link.split(
        (request) => request.isSubscription,
        _wsLink,
        link,
      );

      final GraphQLClient aCLient = GraphQLClient(
        link: link,
        cache: cache,
        defaultPolicies: DefaultPolicies(
          subscribe: policies,
          watchQuery: policies,
          query: policies,
          mutate: policies,
        ),
      );

      client = aCLient;
    } catch (err) {
      debugPrint(err.toString());
      throw new Error();
    }
  }

  static void setPublicGraphQLClient() {
    var logger = Logger(
      printer: SimpleLogPrinter(),
      output: CustomOutput(),
    );

    final String URLBASE = ConfigSettings.HOOK_API_URL;

    Future.delayed(Duration(seconds: 1), () {
      logger.i(
        "Connecting to Hooks API: " +
            URLBASE.toString() +
            "\nConnecting to Hasura: " +
            ConfigSettings.HASURA_URL.toString() +
            "\nConnecting to Websocket: " +
            ConfigSettings.HASURA_WEBSOCKET.toString(),
      );
    });

    try {
      final policies = Policies(
        cacheReread: CacheRereadPolicy.ignoreAll,
        fetch: FetchPolicy.noCache,
      );

      final GraphQLClient aCLient = GraphQLClient(
        link: _httpLink,
        cache: cache,
        defaultPolicies: DefaultPolicies(
          subscribe: policies,
          query: policies,
          mutate: policies,
        ),
      );
      client = aCLient;
    } catch (err) {
      debugPrint(err.toString());
      throw new Error();
    }
  }
}
