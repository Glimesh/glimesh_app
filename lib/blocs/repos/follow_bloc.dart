import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/models.dart';

/* Events */
@immutable
abstract class FollowEvent extends Equatable {}

class LoadFollowStatus extends FollowEvent {
  final int streamerId;
  final int userId;

  LoadFollowStatus({required this.streamerId, required this.userId});

  @override
  List<Object> get props => [this.streamerId, this.userId];
}

class FollowChannel extends FollowEvent {
  final int streamerId;
  final bool liveNotifications;

  FollowChannel({required this.streamerId, required this.liveNotifications});

  @override
  List<Object> get props => [this.streamerId, liveNotifications];
}

class UnfollowChannel extends FollowEvent {
  final int streamerId;

  UnfollowChannel({required this.streamerId});

  @override
  List<Object> get props => [this.streamerId];
}

/* State */
@immutable
abstract class FollowState extends Equatable {}

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

  FollowNotLoaded([this.errors]);

  @override
  List<Object?> get props => [this.errors];
}

/* Bloc */
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final GlimeshRepository glimeshRepository;

  FollowBloc({required this.glimeshRepository}) : super(FollowLoading()) {
    on<LoadFollowStatus>((event, emit) async {
      final queryResults = await this
          .glimeshRepository
          .getFollowers(event.streamerId, event.userId);

      if (queryResults.hasException) {
        if (queryResults.exception!.graphqlErrors.first.message ==
            "Could not find resource") {
          emit(ChannelNotFollowed());
          return;
        }

        print(queryResults.exception!.graphqlErrors);
        emit(FollowNotLoaded(queryResults.exception!.graphqlErrors));
        return;
      }

      int count = queryResults.data!['followers']['count'] as int;
      if (count > 0) {
        emit(ChannelFollowed());
      }
    });

    on<FollowChannel>((event, emit) async {
      final queryResults = await this
          .glimeshRepository
          .followUser(event.streamerId, event.liveNotifications);
      if (queryResults.hasException) {
        emit(FollowNotLoaded(queryResults.exception!.graphqlErrors));
        return;
      }
      emit(ChannelFollowed());
    });

    on<UnfollowChannel>((event, emit) async {
      final queryResults =
          await this.glimeshRepository.unfollowUser(event.streamerId);
      if (queryResults.hasException) {
        emit(FollowNotLoaded(queryResults.exception!.graphqlErrors));
        return;
      }
      emit(ChannelNotFollowed());
    });
  }
}
