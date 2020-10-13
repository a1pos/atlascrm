import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'UserService.dart';

HttpLink _httpLink = HttpLink(
  uri: "https://busy-buzzard-29.hasura.app/v1/graphql",
);

InMemoryCache cache = InMemoryCache();
InMemoryCache cache2 = InMemoryCache();

// WebSocketLink _defWs = WebSocketLink(
//     url: "wss://busy-buzzard-29.hasura.app/v1/graphql",
//     config: SocketClientConfig(
//         autoReconnect: true, inactivityTimeout: Duration(seconds: 30)));

// final Link _defLink = _defWs.concat(_httpLink);

GraphQLClient client;
GraphQLClient wsClient;
UserService userService = UserService();
// (cache: cache, link: _defLink);

Future<QueryResult> authGqlQuery(options) async {
  var token = await userService.getToken();
  setPrivateGraphQLClient(token);
  var result = client.query(options);
  return result;
}

Future<QueryResult> authGqlMutate(options) async {
  var token = await userService.getToken();
  setPrivateGraphQLClient(token);
  var result = client.mutate(options);
  return result;
}

Future<Stream<FetchResult>> authGqlSubscribe(options) async {
  var token = await userService.getToken();
  setPrivateGraphQLClient(token);
  var result = client.subscribe(options);
  return result;
}

void setPrivateGraphQLClient(token) async {
  Link link;
  Link authws;

  final AuthLink _authLink = AuthLink(
    getToken: () async => 'Bearer $token',
  );

  WebSocketLink _wsLink = WebSocketLink(
      url: "wss://busy-buzzard-29.hasura.app/v1/graphql",
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
        initPayload: () {
          return {
            'headers': {'Authorization': 'Bearer $token'}
          };
        },
      ));

  // final Link _link = Link.from([_authLink, _httpLink, _wsLink]);
  link = _authLink.concat(_httpLink);
  authws = _wsLink.concat(_authLink);
  link = link.concat(authws);

  final GraphQLClient aCLient = GraphQLClient(link: link, cache: cache);
  final GraphQLClient bCLient = GraphQLClient(link: authws, cache: cache2);

  client = aCLient;
  wsClient = bCLient;
}

void setPublicGraphQLClient() {
  // WebSocketLink _wsLink = WebSocketLink(
  //     url: "wss://busy-buzzard-29.hasura.app/v1/graphql",
  //     config: SocketClientConfig(
  //         autoReconnect: true, inactivityTimeout: Duration(seconds: 30)));

  // final Link _link = _wsLink.concat(_httpLink);

  final GraphQLClient aCLient = GraphQLClient(link: _httpLink, cache: cache);
  client = aCLient;
}
