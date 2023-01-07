import 'dart:async';
import 'package:flutter/material.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<QueryResult> getUser(String userName) async {
    return client.query(QueryOptions(
      document: parseString(user_queries.getUser),
      variables: <String, dynamic>{"username": userName},
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

  Future<QueryResult> getHomepageChannels() async {
    return client.query(QueryOptions(
        document: parseString(channel_queries.queryHomepageChannels)));
  }

  Future<QueryResult> getChannelFromUsername(String username) async {
    return client.query(QueryOptions(
        document: parseString(channel_queries.queryChannelFromUsername), variables: {"username": username}));
  }

  // fetchPolicy is set the noCache here due to issue #950 on graphql-flutter
  // which seems to be causing issues with fragments?
  // also, this fixes having old chat messages shown, which is nice
  Future<QueryResult> getSomeChatMessages(int channelId) {
    return client.query(QueryOptions(
      document: parseString(chat_queries.getSomeChatMessages),
      variables: <String, dynamic>{"channelId": channelId},
      fetchPolicy: FetchPolicy.noCache,
    ));
  }

  Stream<QueryResult> subscribeToChatMessages(int channelId) {
    return client.subscribe(
      SubscriptionOptions(
        operationName: "ChatMessages",
        document: parseString(chat_queries.chatMessagesSubscription),
        variables: <String, dynamic>{"channelId": channelId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
  }

  Future<QueryResult> sendChatMessage(int channelId, String message) {
    return client.mutate(MutationOptions(
      document: parseString(chat_queries.sendChatMessageMutation),
      variables: <String, dynamic>{"channelId": channelId, "message": message},
    ));
  }

  Future<QueryResult> watchChannel(int channelId, String country) {
    return client.mutate(MutationOptions(
      document: parseString(channel_queries.watchChannel),
      variables: <String, dynamic>{"channelId": channelId, "country": country},
    ));
  }

  // Follows
  Future<QueryResult> getFollowers(int streamerId, int userId) {
    return client.query(QueryOptions(
      document: parseString(user_queries.isFollowing),
      variables: <String, dynamic>{"streamerId": streamerId, "userId": userId},
      fetchPolicy: FetchPolicy.noCache,
    ));
  }

  Future<QueryResult> followUser(int streamerId, bool liveNotifications) {
    return client.mutate(MutationOptions(
      document: parseString(user_queries.followUser),
      variables: <String, dynamic>{
        "streamerId": streamerId,
        "liveNotifications": liveNotifications
      },
    ));
  }

  Future<QueryResult> unfollowUser(int streamerId) {
    return client.mutate(MutationOptions(
      document: parseString(user_queries.unfollowUser),
      variables: <String, dynamic>{"streamerId": streamerId},
    ));
  }
}

class SettingsRepository {
  final SharedPreferences prefs;
  SettingsRepository({required this.prefs});

  Future<ThemeMode> getTheme() async {
    // get the theme, or default to the system theme
    var theme_idx = prefs.getInt("settings.theme") ?? 0;

    return ThemeMode.values[theme_idx];
  }

  setTheme(ThemeMode theme) async {
    await prefs.setInt("settings.theme", theme.index);
  }

  Future<Locale?> getLocale() async {
    var locale_lang = prefs.getString("settings.locale.lang");
    var locale_script = prefs.getString("settings.locale.script");
    var locale_country = prefs.getString("settings.locale.country");

    if (locale_lang == null) return null;

    return Locale.fromSubtags(
        languageCode: locale_lang,
        scriptCode: locale_script,
        countryCode: locale_country);
  }

  setLocale(Locale locale) async {
    prefs.setString("settings.locale.lang", locale.languageCode);

    var locale_script = locale.scriptCode;
    var locale_country = locale.countryCode;

    locale_script == null
        ? prefs.remove("settings.locale.script")
        : prefs.setString("settings.locale.script", locale_script);
    locale_country == null
        ? prefs.remove("settings.locale.country")
        : prefs.setString("settings.locale.country", locale_country);
  }

  Future<bool> getShouldBypassMatureWarning() async {
    return prefs.getBool("settings.bypassMatureWarning") ?? false;
  }

  setShouldBypassMatureWarning(bool value) async {
    prefs.setBool("settings.bypassMatureWarning", value);
  }
}
