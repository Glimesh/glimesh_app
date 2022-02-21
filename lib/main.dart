import 'dart:io';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/channel_bloc.dart';
import 'package:glimesh_app/blocs/repos/follow_bloc.dart';
import 'package:glimesh_app/screens/AppScreen.dart';
import 'package:gql_phoenix_link/gql_phoenix_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:workmanager/workmanager.dart';

import 'package:glimesh_app/screens/LoginScreen.dart';
import 'package:glimesh_app/screens/ChannelListScreen.dart';
import 'package:glimesh_app/screens/ProfileScreen.dart';
import 'package:glimesh_app/auth.dart';
import 'package:glimesh_app/blocs/repos/user_bloc.dart';
import 'package:glimesh_app/screens/ChannelScreen.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/glimesh.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// const checkLiveFollowedStreamsTask = "checkLiveFollowedStreamsTask";

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     print("Native called background task: $task");
//     return Future.value(true);
//   });
// }

Future<void> main() async {
  if (Foundation.kDebugMode) {
    HttpOverrides.global = new MyHttpOverrides();
  }

  // Workmanager().initialize(
  //   callbackDispatcher,
  //   isInDebugMode: true,
  // );
  // Workmanager().registerOneOffTask("1", "simpleTask");
  // Workmanager().registerPeriodicTask(
  //   "5",
  //   checkLiveFollowedStreamsTask,
  //   existingWorkPolicy: ExistingWorkPolicy.replace,
  //   frequency: Duration(minutes: 15), //when should it check the link
  //   initialDelay:
  //       Duration(seconds: 5), //duration before showing the notification
  //   constraints: Constraints(
  //     // connected or metered mark the task as requiring internet
  //     networkType: NetworkType.connected,
  //   ),
  // );
  // await Workmanager.registerPeriodicTask("5", checkLiveFollowedStreamsTask,
  //     existingWorkPolicy: ExistingWorkPolicy.replace,
  //     frequency: Duration(minutes: 15), //when should it check the link
  //     initialDelay:
  //         Duration(seconds: 5), //duration before showing the notification
  //     constraints: Constraints(
  //       networkType: NetworkType.connected,
  //     ));

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://45aff967b80a4b7ba9052619a2fc2012@o966048.ingest.sentry.io/5996892';
    },
    appRunner: () => runApp(AuthWidget()),
  );
}

class AuthWidget extends StatefulWidget {
  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  bool authenticated = false;
  bool anonymous = false;
  User? user;
  GraphQLClient? client;

  @override
  void initState() {
    super.initState();

    _checkExistingAuth();
  }

  _checkExistingAuth() async {
    // Check if we have a saved token
    String? clientToken = await Glimesh.getGlimeshToken();
    if (clientToken == null) {
      // If not use an anonymous client
      _setupAnonymousClient();
    } else {
      // If so set auth state and bypass
      _setupAuthenticatedClient();
    }
  }

  _setupAnonymousClient() async {
    client = await Glimesh.anonymousClient();
    setState(() {
      client = client;
      authenticated = false;
      anonymous = true;
    });
  }

  _setupAuthenticatedClient() async {
    client = await Glimesh.client();

    _fetchUserAndUpdate(client!);
  }

  login(GraphQLClient newClient) async {
    _fetchUserAndUpdate(newClient);
  }

  _fetchUserAndUpdate(GraphQLClient client) async {
    // This disgusting mess should be refactored...
    GlimeshRepository repo = GlimeshRepository(client: client);
    UserBloc bloc = UserBloc(glimeshRepository: repo);
    final queryResults = await repo.getMyself();

    if (queryResults.hasException) {
      print(queryResults.exception!.graphqlErrors);
      return;
    }

    final dynamic userRaw = queryResults.data!['myself'] as dynamic;
    User newUser = bloc.buildUserFromJson(userRaw);
    print(newUser);

    setState(() {
      client = client;
      authenticated = true;
      anonymous = false;
      user = newUser;
    });
  }

  logout() async {
    setState(() {
      authenticated = false;
      anonymous = false;
      client = null;
    });

    _deleteClient();
    _setupAnonymousClient();
  }

  void _deleteClient() {
    if (client != null && client!.link is PhoenixLink) {
      PhoenixLink link = client!.link as PhoenixLink;
      link.channel.close();
    }
    Glimesh.deleteOauthClient();
  }

  @override
  Widget build(BuildContext context) {
    return AuthState(
      authenticated: authenticated,
      anonymous: anonymous,
      client: client,
      login: login,
      logout: logout,
      user: user,
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
      '/channels': (context) => ChannelListScreen(),
      '/login': (context) => LoginScreen()
    };

    final generateRoutes = (settings) {
      if (settings.name == '/channel') {
        final Channel channel = settings.arguments as Channel;
        final GlimeshRepository repo =
            GlimeshRepository(client: authState!.client!);
        final ChannelBloc bloc = ChannelBloc(
          glimeshRepository: repo,
        );

        bloc.add(WatchChannel(channelId: channel.id));
        print("WatchChannel BlocProvider build");

        return MaterialPageRoute(
          builder: (context) {
            print("MaterialPageRoute build");
            return MultiBlocProvider(
              providers: [
                BlocProvider<ChannelBloc>(create: (context) => bloc),
                BlocProvider<FollowBloc>(
                    create: (context) => FollowBloc(glimeshRepository: repo)),
              ],
              child: ChannelScreen(channel: channel),
            );
          },
        );
      }

      if (settings.name == '/profile') {
        final String username = settings.arguments as String;

        return MaterialPageRoute(
          builder: (context) {
            return BlocProvider(
              create: (context) => UserBloc(
                glimeshRepository:
                    GlimeshRepository(client: authState!.client!),
              ),
              child: UserProfileScreen(username: username),
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
      home: authState!.client != null
          ? AppScreen(title: "Glimesh")
          : Padding(padding: EdgeInsets.zero),
    );
  }
}
