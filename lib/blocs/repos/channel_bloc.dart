import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/models.dart';

/* Events */
@immutable
abstract class ChannelEvent extends Equatable {}

class LoadChannel extends ChannelEvent {
  final int channelId;

  LoadChannel({required this.channelId});

  @override
  List<Object> get props => [this.channelId];
}

class WatchChannel extends ChannelEvent {
  final int channelId;

  WatchChannel({required this.channelId});

  @override
  List<Object> get props => [this.channelId];
}

/* State */
@immutable
abstract class ChannelState extends Equatable {}

class ChannelLoading extends ChannelState {
  @override
  List<Object?> get props => [];
}

// ChannelLoaded is for actually fetching a channel
class ChannelLoaded extends ChannelState {
  final User channel;

  ChannelLoaded({required this.channel});

  @override
  List<Object> get props => [channel];
}

// ChannelReady is for when we're ready to play the video
class ChannelReady extends ChannelState {
  final JanusEdgeRoute edgeRoute;

  ChannelReady({required this.edgeRoute});

  @override
  List<Object> get props => [edgeRoute];
}

class ChannelNotLoaded extends ChannelState {
  final List<GraphQLError>? errors;

  ChannelNotLoaded([this.errors]);

  @override
  List<Object?> get props => [this.errors];
}

/* Bloc */
class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  final GlimeshRepository glimeshRepository;

  ChannelBloc({required this.glimeshRepository}) : super(ChannelLoading()) {
    on<WatchChannel>((event, emit) async {
      JanusEdgeRoute edgeRoute = await watchChannel(event.channelId);
      emit(ChannelReady(
        edgeRoute: edgeRoute,
      ));
    });
  }

  Future<JanusEdgeRoute> watchChannel(int channelId) async {
    QueryResult res =
        await this.glimeshRepository.watchChannel(channelId, "US");

    return _buildJanusEdgeRouteFromJson(res.data!['watchChannel']);
  }

  JanusEdgeRoute _buildJanusEdgeRouteFromJson(dynamic json) {
    return JanusEdgeRoute(
      id: int.parse(json['id']),
      url: json['url'] as String,
    );
  }
}
