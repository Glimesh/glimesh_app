import 'package:oauth2/oauth2.dart' as oauth2;

Future<oauth2.Client> createOauthClient(
    String identifier, String secret) async {
  final authorizationEndpoint =
      Uri.parse("https://glimesh.dev/api/oauth/token");

  var client = await oauth2.clientCredentialsGrant(
    authorizationEndpoint,
    identifier,
    secret,
    scopes: ["public", "chat"],
    basicAuth: false,
  );

  return client;
}
