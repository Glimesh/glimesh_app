import 'dart:async';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glimesh_app/auth/handshake.dart';

Future<oauth2.Client> createOauthClient(
    String apiUrl, String redirectUrl, String identifier) async {
  final prefs = await SharedPreferences.getInstance();
  final tokenEndpoint = Uri.parse("$apiUrl/api/oauth/token");
  final authorizationEndpoint = Uri.parse("$apiUrl/oauth/authorize");
  final authenticationKey = "auth-$apiUrl";

  // If the OAuth2 credentials have already been saved from a previous run, we
  // just want to reload them.
  if (prefs.containsKey(authenticationKey)) {
    var credentials =
        oauth2.Credentials.fromJson(prefs.getString(authenticationKey)!);

    if (credentials.isExpired) {
      prefs.remove(authenticationKey);
      return createOauthClient(apiUrl, redirectUrl, identifier);
    }

    return oauth2.Client(credentials, identifier: identifier);
  }

  final redirectUri = Uri.parse(redirectUrl);

  final grant = oauth2.AuthorizationCodeGrant(
      identifier, authorizationEndpoint, tokenEndpoint,
      basicAuth: false);

  final authorizationUrl = grant
      .getAuthorizationUrl(redirectUri, scopes: ["public", "email", "chat"]);

  final handshaker = AuthHandshake.instance;
  Uri responseUrl = await handshaker!.authorize(authorizationUrl, redirectUri);

  var client =
      await grant.handleAuthorizationResponse(responseUrl.queryParameters);
  prefs.setString(authenticationKey, client.credentials.toJson());

  // Once the user is redirected to `redirectUrl`, pass the query parameters to
  // the AuthorizationCodeGrant. It will validate them andw extract the
  // authorization code to create a new Client.
  return client;
}
