import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

@immutable
abstract class UserEvent extends Equatable {}

class LoadMyself extends UserEvent {
  LoadMyself() : super();

  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {
  final String username;

  LoadUser({required this.username});

  @override
  List<Object> get props => [this.username];
}

@immutable
abstract class UserState extends Equatable {}

class UserLoading extends UserState {
  @override
  List<Object?> get props => [];
}

class UserLoaded extends UserState {
  final User user;

  UserLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

class UserNotLoaded extends UserState {
  final List<GraphQLError>? errors;

  UserNotLoaded([this.errors]);

  @override
  List<Object?> get props => [this.errors];
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final GlimeshRepository glimeshRepository;

  UserBloc({required this.glimeshRepository}) : super(UserLoading()) {
    on<LoadMyself>((event, emit) async {
      final queryResults = await this.glimeshRepository.getMyself();

      if (queryResults.hasException) {
        print(queryResults.exception!.graphqlErrors);
        emit(UserNotLoaded(queryResults.exception!.graphqlErrors));
        return;
      }

      final dynamic user = queryResults.data!['myself'] as dynamic;
      emit(UserLoaded(user: buildUserFromJson(user)));
    });

    on<LoadUser>((event, emit) async {
      final queryResults = await this.glimeshRepository.getUser(event.username);

      if (queryResults.hasException) {
        emit(UserNotLoaded(queryResults.exception!.graphqlErrors));
        return;
      }

      final dynamic user = queryResults.data!['user'] as dynamic;

      emit(UserLoaded(user: buildUserFromJson(user)));
    });
  }

  User buildUserFromJson(dynamic json) {
    return User(
      id: int.parse(json['id']),
      username: json['username'] as String,
      teamRole: json['teamRole'] as String?,
      avatarUrl: json['avatarUrl'] as String,
      countFollowers: json['countFollowers'] as int,
      countFollowing: json['countFollowing'] as int,
      profileContentMd: json['profileContentMd'] as String?,
      socialDiscord: json['socialDiscord'] as String?,
      socialGuilded: json['socialGuilded'] as String?,
      socialYoutube: json['socialYoutube'] as String?,
      socialInstagram: json['socialInstagram'] as String?,
      socials: buildSocialsFromJson(json['socials']),
    );
  }

  List<Social> buildSocialsFromJson(dynamic json) {
    List<Social> socials = [];

    for (var js in json) {
      socials.add(Social(
        platform: js['platform'] as String,
        username: js['username'] as String,
      ));
    }

    return socials;
  }
}
