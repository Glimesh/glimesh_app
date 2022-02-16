import 'dart:async';
import 'package:gql_phoenix_link/gql_phoenix_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glimesh_app/auth/handshake.dart';

mixin Anonymous {}
class AnonymousGraphQLClient = GraphQLClient with Anonymous;

const clientID =
    String.fromEnvironment('GLIMESH_CLIENT_ID', defaultValue: 'FAKE_VALUE');
const glimeshApiUrl = String.fromEnvironment("GLIMESH_API_URL",
    defaultValue: "https://glimesh.test");
const glimeshWsApiUrl = String.fromEnvironment("GLIMESH_WS_API_URL",
    defaultValue: "wss://glimesh.test");

class Glimesh {
  static Future<GraphQLClient> anonymousClient() async {
    final _socketUrl =
        "$glimeshWsApiUrl/api/graph/websocket?vsn=2.0.0&client_id=$clientID";
    final channel = PhoenixLink.createChannel(websocketUri: _socketUrl);
    final PhoenixLink _phoenixLink = PhoenixLink(channel: await channel);

    return AnonymousGraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _phoenixLink,
    );
  }

  static Future<GraphQLClient> client() async {
    final oauthClient = await createOauthClient();
    final token = oauthClient.credentials.accessToken;

    print("Got access token: " + token);

    final _socketUrl =
        "$glimeshWsApiUrl/api/graph/websocket?vsn=2.0.0&token=$token";
    final channel = PhoenixLink.createChannel(websocketUri: _socketUrl);
    final PhoenixLink _phoenixLink = PhoenixLink(channel: await channel);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _phoenixLink,
    );
  }

  static Future<oauth2.Client> createOauthClient() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenEndpoint = Uri.parse("$glimeshApiUrl/api/oauth/token");
    final authorizationEndpoint = Uri.parse("$glimeshApiUrl/oauth/authorize");
    final authenticationKey = "auth-$glimeshApiUrl";

    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (prefs.containsKey(authenticationKey)) {
      var credentials =
          oauth2.Credentials.fromJson(prefs.getString(authenticationKey)!);

      if (credentials.isExpired) {
        prefs.remove(authenticationKey);
        return createOauthClient();
      }

      return oauth2.Client(credentials, identifier: clientID);
    }

    final handshaker = AuthHandshake.instance;
    if (handshaker == null) {
      throw new Exception("No auth handshake instance found");
    }

    final redirectUri = Uri.parse(handshaker.redirectUrl());

    final grant = oauth2.AuthorizationCodeGrant(
        clientID, authorizationEndpoint, tokenEndpoint,
        basicAuth: false);

    final authorizationUrl = grant.getAuthorizationUrl(redirectUri,
        scopes: ["public", "email", "chat", "follow"]);

    Uri responseUrl = await handshaker.authorize(authorizationUrl);

    var client =
        await grant.handleAuthorizationResponse(responseUrl.queryParameters);
    prefs.setString(authenticationKey, client.credentials.toJson());

    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them andw extract the
    // authorization code to create a new Client.
    return client;
  }

  static Future<bool> deleteOauthClient() async {
    final prefs = await SharedPreferences.getInstance();
    final authenticationKey = "auth-$glimeshApiUrl";

    if (prefs.containsKey(authenticationKey)) {
      return prefs.remove(authenticationKey);
    }

    return false;
  }

  static Future<String?> getGlimeshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final authenticationKey = "auth-$glimeshApiUrl";

    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (prefs.containsKey(authenticationKey)) {
      var credentials =
          oauth2.Credentials.fromJson(prefs.getString(authenticationKey)!);

      if (credentials.isExpired) {
        prefs.remove(authenticationKey);
        return null;
      }

      return credentials.accessToken;
    }

    return null;
  }
}
