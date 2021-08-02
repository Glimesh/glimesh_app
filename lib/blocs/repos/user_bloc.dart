import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

@immutable
abstract class UserEvent extends Equatable {
  UserEvent([List props = const []]) : super();
}

class LoadMyself extends UserEvent {
  LoadMyself() : super();

  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {
  final int id;

  LoadUser({required this.id}) : super([id]);

  @override
  List<Object> get props => [this.id];
}

@immutable
abstract class UserState extends Equatable {
  UserState([List props = const []]) : super();
}

class UserLoading extends UserState {
  @override
  List<Object?> get props => [];
}

class UserLoaded extends UserState {
  final User user;

  UserLoaded({required this.user}) : super([user]);

  @override
  List<Object> get props => [user];
}

class UserNotLoaded extends UserState {
  final List<GraphQLError>? errors;

  UserNotLoaded([this.errors]) : super([errors]);

  @override
  List<Object?> get props => [this.errors];
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final GlimeshRepository glimeshRepository;

  UserBloc({required this.glimeshRepository}) : super(UserLoading());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    try {
      if (event is LoadMyself) {
        yield* _mapMyselfToState();
      } else if (event is LoadUser) {
        yield* _mapUserToState(event.id);
      } else {
        // New event, who dis?
      }
    } catch (_, stackTrace) {
      print('$_ $stackTrace');
      yield state;
    }
  }

  Stream<UserState> _mapMyselfToState() async* {
    try {
      yield UserLoading();

      final queryResults = await this.glimeshRepository.getMyself();

      if (queryResults.hasException) {
        print(queryResults.exception!.graphqlErrors);
        yield UserNotLoaded(queryResults.exception!.graphqlErrors);
        return;
      }

      final dynamic user = queryResults.data!['myself'] as dynamic;
      yield UserLoaded(user: buildUserFromJson(user));
    } catch (error) {
      print(error);
      yield UserNotLoaded();
    }
  }

  Stream<UserState> _mapUserToState(int userId) async* {
    try {
      yield UserLoading();

      final queryResults = await this.glimeshRepository.getUser(userId);

      if (queryResults.hasException) {
        yield UserNotLoaded(queryResults.exception!.graphqlErrors);
        return;
      }

      final dynamic user = queryResults.data!['user'] as dynamic;

      yield UserLoaded(user: buildUserFromJson(user));
    } catch (error) {
      yield UserNotLoaded();
    }
  }

  User buildUserFromJson(dynamic json) {
    return User(
      id: int.parse(json['id']),
      username: json['username'] as String,
    );
  }
}