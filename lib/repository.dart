import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart';
import 'package:glimesh_app/graphql/queries/channels.dart' as channel_queries;
import 'package:glimesh_app/graphql/queries/chat.dart' as chat_queries;

class GlimeshRepository {
  final GraphQLClient client;

  GlimeshRepository({required this.client});

  Future<QueryResult> getLiveChannels(String categorySlug) async {
    // final WatchQueryOptions _options = WatchQueryOptions(
    //   document: parseString(channel_queries.queryLiveChannels),
    //   variables: <String, dynamic>{},
    //   pollInterval: Duration(seconds: 10),
    //   fetchResults: true,
    // );
    //
    // return await client.query(_options);
    return client.query(QueryOptions(
      document: parseString(channel_queries.queryLiveChannels),
      variables: <String, dynamic>{"categorySlug": categorySlug},
    ));
  }

  Future<QueryResult> getSomeChatMessages(int channelId) {
    return client.query(QueryOptions(
      document: parseString(chat_queries.getSomeChatMessages),
      variables: <String, dynamic>{"channelId": channelId},
    ));
  }

  Stream<QueryResult> subscribeToChatMessages(int channelId) {
    return client.subscribe(
      SubscriptionOptions(
        operationName: "ChatMessages",
        document: parseString(chat_queries.chatMessages),
        variables: <String, dynamic>{"channelId": channelId},
      ),
    );
  }
}
