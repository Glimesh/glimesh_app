import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart';
import 'package:glimesh_app/graphql/queries/channels.dart' as channel_queries;
import 'package:glimesh_app/graphql/queries/chat.dart' as chat_queries;
import 'package:glimesh_app/graphql/queries/user.dart' as user_queries;

class GlimeshRepository {
  final GraphQLClient client;

  GlimeshRepository({required this.client});

  Future<QueryResult> getMyself() async {
    return client.query(QueryOptions(
      document: parseString(user_queries.getMyself),
    ));
  }

  Future<QueryResult> getUser(int userId) async {
    return client.query(QueryOptions(
      document: parseString(user_queries.getUser),
      variables: <String, dynamic>{"userId": userId},
    ));
  }

  Future<QueryResult> getLiveChannels(String categorySlug) async {
    return client.query(QueryOptions(
      document: parseString(channel_queries.queryLiveChannels),
      variables: <String, dynamic>{"categorySlug": categorySlug},
    ));
  }

  Future<QueryResult> getMyLiveFollowedChannels() async {
    return client.query(QueryOptions(
        document: parseString(channel_queries.queryLiveFollowedChannels)));
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
        document: parseString(chat_queries.chatMessagesSubscription),
        variables: <String, dynamic>{"channelId": channelId},
      ),
    );
  }

  Future<QueryResult> sendChatMessage(int channelId, String message) {
    return client.mutate(MutationOptions(
      document: parseString(chat_queries.sendChatMessageMutation),
      variables: <String, dynamic>{"channelId": channelId, "message": message},
    ));
  }
}