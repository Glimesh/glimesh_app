import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/models.dart';

/* Events */
@immutable
abstract class FollowEvent extends Equatable {
  FollowEvent([List props = const []]) : super();
}

class LoadFollowStatus extends FollowEvent {
  final int streamerId;
  final int userId;

  LoadFollowStatus({required this.streamerId, required this.userId})
      : super([streamerId, userId]);

  @override
  List<Object> get props => [this.streamerId, this.userId];
}

class FollowChannel extends FollowEvent {
  final int streamerId;
  final bool liveNotifications;

  FollowChannel({required this.streamerId, required this.liveNotifications})
      : super([streamerId, liveNotifications]);

  @override
  List<Object> get props => [this.streamerId, liveNotifications];
}

class UnfollowChannel extends FollowEvent {
  final int streamerId;

  UnfollowChannel({required this.streamerId}) : super([streamerId]);

  @override
  List<Object> get props => [this.streamerId];
}

/* State */
@immutable
abstract class FollowState extends Equatable {
  FollowState([List props = const []]) : super();
}

class ChannelFollowed extends FollowState {
  @override
  List<Object?> get props => [];
}

// ChannelLoaded is for actually fetching a channel
class ChannelNotFollowed extends FollowState {
  @override
  List<Object> get props => [];
}

class FollowLoading extends FollowState {
  @override
  List<Object?> get props => [];
}

class FollowNotLoaded extends FollowState {
  final List<GraphQLError>? errors;

  FollowNotLoaded([this.errors]) : super([errors]);

  @override
  List<Object?> get props => [this.errors];
}

/* Bloc */
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final GlimeshRepository glimeshRepository;

  FollowBloc({required this.glimeshRepository}) : super(FollowLoading());

  @override
  Stream<FollowState> mapEventToState(FollowEvent event) async* {
    try {
      print(event);
      if (event is LoadFollowStatus) {
        final queryResults = await this
            .glimeshRepository
            .getFollowers(event.streamerId, event.userId);

        if (queryResults.hasException) {
          if (queryResults.exception!.graphqlErrors.first.message ==
              "Could not find resource") {
            yield ChannelNotFollowed();
            return;
          }

          print(queryResults.exception!.graphqlErrors);
          yield FollowNotLoaded(queryResults.exception!.graphqlErrors);
          return;
        }

        yield ChannelFollowed();
      } else if (event is FollowChannel) {
        // TODO: Error handling
        this
            .glimeshRepository
            .followUser(event.streamerId, event.liveNotifications);
        yield ChannelFollowed();
      } else if (event is UnfollowChannel) {
        // TODO: Error handling
        this.glimeshRepository.unfollowUser(event.streamerId);
        yield ChannelNotFollowed();
      } else {
        // else if (event is LoadChannel) {
        //   yield* _mapUserToState(event.username);
        // }
        // New event, who dis?
      }
    } catch (_, stackTrace) {
      print('$_ $stackTrace');
      yield state;
    }
  }
}
