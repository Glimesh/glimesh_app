import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthState extends InheritedWidget {
  final bool authenticated;
  final GraphQLClient? client;
  final Widget child;

  final Function(GraphQLClient) login;
  final VoidCallback logout;

  AuthState(
      {Key? key,
      required this.authenticated,
      required this.login,
      required this.logout,
      required this.child,
      required this.client})
      : super(key: key, child: child);

  static AuthState? of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<AuthState>());
  }

  @override
  bool updateShouldNotify(AuthState oldWidget) {
    return client != oldWidget.client;
  }
}
