import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// ValueNotifier<GraphQLClient> client = ValueNotifier(
final GraphQLClient client = GraphQLClient(
  cache: InMemoryCache(),
  link: HttpLink(uri: 'https://busy-buzzard-29.hasura.app/v1/graphql'),
);
// );
