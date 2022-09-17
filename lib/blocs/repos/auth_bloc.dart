import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

enum ClientType {
  anonymous,
  authenticated,
}

@immutable
abstract class AuthEvent extends Equatable {}

class AppLoaded extends AuthEvent {
  AppLoaded() : super();

  @override
  List<Object?> get props => [];
}

class UserLoggedIn extends AuthEvent {
  final GraphQLClient client;

  UserLoggedIn({required this.client}) : super();

  @override
  List<Object?> get props => [client];
}

class UserLoggedOut extends AuthEvent {
  UserLoggedOut() : super();

  @override
  List<Object?> get props => [];
}

@immutable
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthClientAcquired extends AuthState {
  final ClientType clientType;
  final GraphQLClient client;
  final User? user;

  AuthClientAcquired(
      {required this.clientType, required this.client, this.user});

  @override
  List<Object?> get props => [clientType, client, user];

  bool isAnon() {
    return clientType == ClientType.anonymous;
  }

  bool isAuthenticated() {
    return clientType == ClientType.authenticated;
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppLoaded>((event, emit) async {});

    on<UserLoggedIn>((event, emit) async {});

    on<UserLoggedOut>((event, emit) async {});
  }
}
