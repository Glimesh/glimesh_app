import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart';
import 'package:glimesh_app/graphql/queries/channels.dart' as queries;

class GlimeshRepository {
  final GraphQLClient client;

  GlimeshRepository({required this.client});

  Future<QueryResult> getLiveChannels() async {
    final WatchQueryOptions _options = WatchQueryOptions(
      document: parseString(queries.queryLiveChannels),
      variables: <String, dynamic>{},
      pollInterval: Duration(seconds: 10),
      fetchResults: true,
    );

    return await client.query(_options);
  }
}
