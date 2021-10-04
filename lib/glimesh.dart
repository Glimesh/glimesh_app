import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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

  if (kIsWeb) {
    final currentUri = Uri.base;

// Generate the URL redirection to our static.html page
    redirectUrl = Uri(
      host: currentUri.host,
      scheme: currentUri.scheme,
      port: currentUri.port,
      path: '/auth-redirect.html',
    ).toString();

    print("using web");
    print(redirectUrl);
  }

  var grant = oauth2.AuthorizationCodeGrant(
      identifier, authorizationEndpoint, tokenEndpoint,
      basicAuth: false);

  final redirectUri = Uri.parse(redirectUrl);

  var authorizationUrl = grant
      .getAuthorizationUrl(redirectUri, scopes: ["public", "email", "chat"]);

  print(kIsWeb);
  Uri responseUrl;
  if (kIsWeb) {
    responseUrl = await authorizeForWeb(authorizationUrl);
  } else {
    responseUrl = await authorizeForMobile(authorizationUrl, redirectUri);
  }

  // We're done listening for links
  // _sub!.cancel();

  var client =
      await grant.handleAuthorizationResponse(responseUrl.queryParameters);
  prefs.setString(authenticationKey, client.credentials.toJson());

  // Once the user is redirected to `redirectUrl`, pass the query parameters to
  // the AuthorizationCodeGrant. It will validate them andw extract the
  // authorization code to create a new Client.
  return client;
}

redirect(Uri authorizationUrl) async {
  if (await canLaunch(authorizationUrl.toString())) {
    await launch(authorizationUrl.toString());
  }
}

Future<Uri> authorizeForWeb(Uri authorizationUrl) async {
  var completer = new Completer<Uri>();

  html.WindowBase _popupWin = html.window.open(authorizationUrl.toString(),
      "Glimesh Auth", "width=800, height=900, scrollbars=yes");

  html.window.onMessage.listen((event) {
    /// If the event contains the token it means the user is authenticated.
    if (event.data.toString().contains('code=')) {
      _popupWin.close();

      completer.complete(Uri.parse(event.data));
    }
  });

  return completer.future;
}

Future<Uri> authorizeForMobile(Uri authorizationUrl, Uri redirectUri) async {
  var completer = new Completer<Uri>();

  await redirect(authorizationUrl);

  StreamSubscription? _sub;
  _sub = uriLinkStream.listen((Uri? uri) {
    if (uri.toString().startsWith(redirectUri.toString())) {
      _sub!.cancel();
      completer.complete(uri);
    }
  }, onError: (err) {
    _sub!.cancel();
    completer.completeError(err);
  });

  return completer.future;
}
