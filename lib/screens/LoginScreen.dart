import 'package:flutter/material.dart';
import 'package:glimesh_app/glimesh.dart';
import 'package:glimesh_app/auth.dart';
import 'package:gql_phoenix_link/gql_phoenix_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class LoginScreen extends StatelessWidget {
  AuthState? authState;

  Future<GraphQLClient> _client() async {
    const clientID =
        String.fromEnvironment('GLIMESH_CLIENT_ID', defaultValue: 'FAKE_VALUE');
    const glimeshApiUrl = String.fromEnvironment("GLIMESH_API_URL",
        defaultValue: "https://glimesh.test");
    const glimeshWsApiUrl = String.fromEnvironment("GLIMESH_WS_API_URL",
        defaultValue: "wss://glimesh.test");

    final oauthClient = await createOauthClient(glimeshApiUrl, clientID);
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

  @override
  Widget build(BuildContext context) {
    authState = AuthState.of(context);
    bool horizontalTablet = MediaQuery.of(context).size.width > 992;

    return Scaffold(
      body: SafeArea(
        child: horizontalTablet
            ? _buildHorizontal(context)
            : _buildVertical(context),
      ),
    );
  }

  Widget _buildVertical(context) {
    // Column(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: <Widget>[
    //           Image.asset('assets/images/logo-with-text.png'),
    //           ElevatedButton(
    //               onPressed: () async {
    //                 GraphQLClient client = await _client();
    //                 authState!.login(client);
    //               },
    //               child: const Text("Login"))
    //         ],
    //       ),
    return Padding(
        padding: EdgeInsets.only(top: 60, bottom: 60),
        child: Column(
          children: [
            Expanded(
              child: _logo(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 40, left: 40, right: 40),
                child: _loginButton(context, true),
              ),
            ),
          ],
        ));
  }

  Widget _buildHorizontal(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _logo(),
        ),
        Expanded(
          child: _loginButton(context, false),
        ),
      ],
    );
  }

  Widget _logo() {
    return Image.asset('assets/images/logo-with-text.png');
  }

  Widget _loginButton(context, bool center) {
    if (authState == null) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            "Next-Gen Live Streaming!",
            style: Theme.of(context).textTheme.headline4,
            // style: TextStyle(fontSize: 20),
            maxLines: 1,
          ),
          AutoSizeText(
            "The first live streaming platform built around truly real time interactivity. Our streams are warp speed, our chat is blazing, and our community is thriving.",
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: center ? TextAlign.center : TextAlign.left,
          ),
          Padding(padding: EdgeInsets.only(top: 60)),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                GraphQLClient client = await _client();
                authState!.login(client);
              },
              child: const Text("Login"),
            ),
          )
        ],
      ),
    );
  }
}
