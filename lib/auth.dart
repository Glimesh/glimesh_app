import 'package:flutter/material.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/blocs/repos/auth_bloc.dart' as auth_bloc;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthState extends InheritedWidget {
  final bool authenticated;
  final bool anonymous;
  final GraphQLClient? client;
  final Widget child;
  final User? user;

  final Function(GraphQLClient) login;
  final VoidCallback logout;

  AuthState(
      {Key? key,
      required this.authenticated,
      required this.anonymous,
      required this.login,
      required this.logout,
      required this.child,
      required this.client,
      this.user})
      : super(key: key, child: child);

  static AuthState? of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<AuthState>());
  }

  @override
  bool updateShouldNotify(AuthState oldWidget) {
    return authenticated != oldWidget.authenticated;
  }
}

class AuthWrapper extends StatelessWidget {
  final Widget child;

  AuthWrapper({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<auth_bloc.AuthBloc, auth_bloc.AuthState>(
        builder: (BuildContext context, state) {
      if (state is auth_bloc.AuthFailure) {
        return const MaterialApp(
            home: Scaffold(
                body: Text(
                    "Failed to authenticate - check your internet connection and try again.")));
      }

      if (state is auth_bloc.AuthClientAcquired) return child;

      // state is AuthInitial, AuthLoading or else
      return MaterialApp(
          home: Scaffold(
              body: Padding(
                  padding: const EdgeInsets.only(top: 60, bottom: 60),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child:
                              Image.asset('assets/images/logo-with-text.png'),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 40, left: 40, right: 40),
                          child: Loading("Loading"),
                        ),
                      ),
                      _versionWidget(),
                    ],
                  ))));
    });
  }

  Widget _versionWidget() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                style: Theme.of(context).textTheme.caption,
              ),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}
