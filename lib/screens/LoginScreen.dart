import 'package:flutter/material.dart';
import 'package:glimesh_app/glimesh.dart';
import 'package:glimesh_app/auth.dart';
import 'package:gql_phoenix_link/gql_phoenix_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginScreen extends StatelessWidget {
  Future<GraphQLClient> _client() async {
    const CLIENT_ID =
        String.fromEnvironment('GLIMESH_CLIENT_ID', defaultValue: 'FAKE_VALUE');

    final oauthClient = await createOauthClient(CLIENT_ID);
    final token = oauthClient.credentials.accessToken;

    print("Got access token: " + token);

    final _socketUrl =
        'wss://glimesh.dev/api/graph/websocket?vsn=2.0.0&token=$token';
    final channel = PhoenixLink.createChannel(websocketUri: _socketUrl);
    final PhoenixLink _phoenixLink = PhoenixLink(channel: await channel);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _phoenixLink,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = AuthState.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 120, bottom: 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Image.asset('assets/images/logo-with-text.png'),
              ElevatedButton(
                  onPressed: () async {
                    GraphQLClient client = await _client();
                    authState!.login(client);
                  },
                  child: const Text("Login"))
            ],
          ),
        ),
      ),
    );
  }
}
