import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
// (cache: cache, link: _defLink);

setPrivateGraphQLClient(token) {
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

setPublicGraphQLClient() {
  // WebSocketLink _wsLink = WebSocketLink(
  //     url: "wss://busy-buzzard-29.hasura.app/v1/graphql",
  //     config: SocketClientConfig(
  //         autoReconnect: true, inactivityTimeout: Duration(seconds: 30)));

  // final Link _link = _wsLink.concat(_httpLink);

  final GraphQLClient aCLient = GraphQLClient(link: _httpLink, cache: cache);
  client = aCLient;
}
