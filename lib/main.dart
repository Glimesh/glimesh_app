import 'dart:io';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:glimesh_app/blocs/repos/auth_bloc.dart';
import 'package:glimesh_app/blocs/repos/channel_bloc.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/blocs/repos/follow_bloc.dart';
import 'package:glimesh_app/blocs/repos/settings_bloc.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/screens/AppScreen.dart';
import 'package:glimesh_app/screens/CategoryListScreen.dart';
import 'package:glimesh_app/track.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
// import 'package:workmanager/workmanager.dart';

import 'package:glimesh_app/screens/LoginScreen.dart';
import 'package:glimesh_app/screens/ChannelListScreen.dart';
import 'package:glimesh_app/screens/ProfileScreen.dart';
import 'package:glimesh_app/components/AuthWrapper.dart';
import 'package:glimesh_app/blocs/repos/user_bloc.dart';
import 'package:glimesh_app/screens/ChannelScreen.dart';
import 'package:glimesh_app/screens/SettingsScreen.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/i18n.dart';

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
    appRunner: () => runApp(GlimeshApp()),
  );
}

class GlimeshApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routes = <String, WidgetBuilder>{
      '/login': (context) => LoginScreen(),
      '/settings': (context) => SettingsScreen()
    };

    print("New State for MaterialApp");

    return MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(create: (BuildContext context) {
            var bloc = SettingsBloc();
            bloc.add(InitSettingsData());
            return bloc;
          }),
          BlocProvider<AuthBloc>(create: (BuildContext context) {
            var bloc = AuthBloc();
            bloc.add(AppLoaded());
            return bloc;
          }),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, _) => MaterialApp(
              title: 'Glimesh Alpha',
              routes: routes,
              onGenerateRoute: _generateRoutes,
              localizationsDelegates: [
                GettextLocalizationsDelegate(defaultLanguage: 'en'),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              locale: context.select((SettingsBloc bloc) => bloc.currentLocale),
              supportedLocales: supportedLocales,
              theme: ThemeData(
                  brightness: Brightness.light,
                  appBarTheme: AppBarTheme(
                      color: Colors.white, foregroundColor: Colors.black),
                  textTheme:
                      TextTheme(headline4: TextStyle(color: Colors.black))),
              darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  canvasColor: Color(0xff060818),
                  bottomAppBarColor: Color(0xff0e1726),
                  appBarTheme: AppBarTheme(color: Colors.black),
                  textTheme:
                      TextTheme(headline4: TextStyle(color: Colors.white))),
              themeMode:
                  context.select((SettingsBloc bloc) => bloc.currentTheme),
              home: AuthWrapper(child: AppScreen(title: "Glimesh"))),
        ));
  }

  MaterialPageRoute? _generateRoutes(RouteSettings settings) {
    // events screen (for when events get added to the API)
    if (settings.name == '/events') {
      // for future expansion
      return null;
    }

    // category screen
    if (settings.name?.startsWith('/streams') ?? false) {
      final categorySlug = settings.name!.split('/')[2];
      final category = categories[categorySlug];

      if (category == null) return null;

      return MaterialPageRoute(
          builder: (_) =>
              AuthWrapper(child: ChannelListScreen(category: category)));
    }

    // profile screen
    if (settings.name?.endsWith('/profile') ?? false) {
      final String username = settings.name!.split('/')[1];

      track.event(page: "${username}/profile");

      return MaterialPageRoute(
        builder: (_) => AuthWrapper(
            child: BlocBuilder<AuthBloc, AuthState>(
                builder: (_, state) => BlocProvider(
                    create: (_) => UserBloc(
                        glimeshRepository: GlimeshRepository(
                            client: (state as AuthClientAcquired).client)),
                    child: UserProfileScreen(username: username)))),
      );
    }

    if (settings.name == '/channel') {
      final Channel channel = settings.arguments as Channel;

      return MaterialPageRoute(
          builder: (_) => AuthWrapper(
                child: BlocBuilder<AuthBloc, AuthState>(builder: (_, state) {
                  var authState = state as AuthClientAcquired;

                  final GlimeshRepository repo =
                      GlimeshRepository(client: authState.client);
                  final ChannelBloc bloc = ChannelBloc(
                    glimeshRepository: repo,
                  );

                  return _buildChannel(channel, bloc, repo, authState);
                }),
              ));
    }

    // otherwise, assume that this is a channel for deep link purposes.
    final String username = settings.name!.split('/')[1];
    return MaterialPageRoute(
        builder: (_) => AuthWrapper(child: BlocBuilder<AuthBloc, AuthState>(
              builder: (_, state) {
                var authState = state as AuthClientAcquired;

                final GlimeshRepository repo =
                    GlimeshRepository(client: authState.client);
                final ChannelBloc bloc = ChannelBloc(
                  glimeshRepository: repo,
                );

                var queryFuture = repo.getChannelFromUsername(username);

                return FutureBuilder(
                    future: queryFuture,
                    builder: (context, AsyncSnapshot<QueryResult> snap) {
                      if (snap.hasData) {
                        Channel channel =
                            Channel.buildFromJson(snap.data!.data!['channel']);
                        // how do we refactor this mess?
                        return _buildChannel(channel, bloc, repo, authState);
                      }

                      if (snap.hasError) {
                        print(snap.error);
                      }

                      return Scaffold(
                          body: Loading(context.t("Loading Stream")));
                    });
              },
            )));
  }

  Widget _buildChannel(
      Channel channel,
      ChannelBloc channelBloc,
      GlimeshRepository repo,
      AuthClientAcquired authState,
      ) {
    track.event(page: channel.username);

    return MultiBlocProvider(providers: [
      BlocProvider<ChannelBloc>(
        create: (context) => channelBloc
          ..add(ShowMatureWarning(
              channel: channel, settingsBloc: context.read<SettingsBloc>())),
      ),
      BlocProvider<ChatMessagesBloc>(
        create: (context) => ChatMessagesBloc(glimeshRepository: repo)
          ..add(LoadChatMessages(channelId: channel.id)),
      ),
      BlocProvider<FollowBloc>(
        create: (context) {
          FollowBloc followBloc = FollowBloc(glimeshRepository: repo);
          // If we're authenticated, show the initial bloc status
          if (authState.isAuthenticated()) {
            followBloc.add(LoadFollowStatus(
              streamerId: channel.user_id,
              userId: authState.user!.id,
            ));
          }
          return followBloc;
        },
      ),
    ], child: ChannelScreen(channel: channel));
  }
}
