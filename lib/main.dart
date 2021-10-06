import 'package:flutter/material.dart';
import 'package:glimesh_app/screens/AppScreen.dart';
import 'dart:io';

import 'package:glimesh_app/screens/LoginScreen.dart';
import 'package:glimesh_app/screens/ChannelListScreen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/auth.dart';

import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/screens/ChannelScreen.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/repository.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  // This should only be done in development. Gotta figure out how to toggle it.
  HttpOverrides.global = new MyHttpOverrides();

  runApp(AuthWidget());
}

class AuthWidget extends StatefulWidget {
  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  bool authenticated = false;
  GraphQLClient? client;

  void login(GraphQLClient newClient) {
    setState(() {
      client = newClient;
      authenticated = true;
    });
  }

  void logout() {
    setState(() {
      authenticated = false;
      client = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthState(
      authenticated: authenticated,
      client: client,
      login: login,
      logout: logout,
      child: GlimeshApp(),
    );
  }
}

class GlimeshApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = AuthState.of(context);

    final whiteTextTheme = Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        );

    final routes = <String, WidgetBuilder>{
      '/channels': (context) => ChannelListScreen()
    };

    final generateRoutes = (settings) {
      if (settings.name == '/channel') {
        final Channel channel = settings.arguments as Channel;

        return MaterialPageRoute(
          builder: (context) {
            return BlocProvider(
              create: (context) => ChatMessagesBloc(
                glimeshRepository:
                    GlimeshRepository(client: authState!.client!),
              ),
              child: ChannelScreen(channel: channel),
            );
          },
        );
      }

      // Fail if we're missing any routes.
      assert(false, 'Need to implement ${settings.name}');
      return null;
    };

    return MaterialApp(
      title: 'Glimesh Alpha',
      routes: routes,
      onGenerateRoute: generateRoutes,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xff060818),
        canvasColor: Color(0xff060818),
        bottomAppBarColor: Color(0xff0e1726),
        textTheme: whiteTextTheme,
      ),
      themeMode: ThemeMode.dark,
      home: authState!.authenticated
          ? AppScreen(client: authState.client!, title: "Glimesh")
          : LoginScreen(),
    );
  }
}
