import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

final tokenEndpoint = Uri.parse("https://glimesh.dev/api/oauth/token");
final authorizationEndpoint = Uri.parse("https://glimesh.dev/oauth/authorize");

Future<oauth2.Client> createOauthClient(String identifier) async {
  // If we don't have OAuth2 credentials yet, we need to get the resource owner
  // to authorize us. We're assuming here that we're a command-line application.
  var grant = oauth2.AuthorizationCodeGrant(
      identifier, authorizationEndpoint, tokenEndpoint,
      basicAuth: false);

  final redirectUrl = Uri.parse('tv.glimesh.app://login-callback');

// A URL on the authorization server (authorizationEndpoint with some additional
  // query parameters). Scopes and state can optionally be passed into this method.
  var authorizationUrl = grant
      .getAuthorizationUrl(redirectUrl, scopes: ["public", "email", "chat"]);

  // Redirect the resource owner to the authorization URL. Once the resource
  // owner has authorized, they'll be redirected to `redirectUrl` with an
  // authorization code. The `redirect` should cause the browser to redirect to
  // another URL which should also have a listener.
  //
  // `redirect` and `listen` are not shown implemented here. See below for the
  // details.
  StreamSubscription? _sub;

  await redirect(authorizationUrl);
  var responseUrl = await listen(_sub, redirectUrl);

  // We're done listening for links
  // _sub!.cancel();

  // Once the user is redirected to `redirectUrl`, pass the query parameters to
  // the AuthorizationCodeGrant. It will validate them andw extract the
  // authorization code to create a new Client.
  return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
}

redirect(Uri authorizationUrl) async {
  if (await canLaunch(authorizationUrl.toString())) {
    await launch(authorizationUrl.toString());
  }
}

Future<Uri> listen(StreamSubscription? _sub, Uri redirectUrl) async {
  var completer = new Completer<Uri>();

  _sub = uriLinkStream.listen((Uri? uri) {
    if (uri.toString().startsWith("tv.glimesh.app://")) {
      completer.complete(uri);
    }
  }, onError: (err) {
    // Handle exception by warning the user their action did not succeed
    completer.completeError(err);
  });

  return completer.future;
}
