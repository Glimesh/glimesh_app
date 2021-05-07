import 'package:oauth2/oauth2.dart' as oauth2;

Future<oauth2.Client> createOauthClient(
    String identifier, String secret) async {
  final endpoint = Uri.parse("https://glimesh.dev/api/oauth/token");

  return await oauth2.clientCredentialsGrant(
    endpoint,
    identifier,
    secret,
    scopes: ["public", "chat"],
    basicAuth: false,
  );
}
