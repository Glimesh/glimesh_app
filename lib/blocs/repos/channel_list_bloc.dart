import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

@immutable
abstract class ChannelListEvent extends Equatable {}

abstract class AlwaysRefreshingChannelListEvent extends ChannelListEvent {
  @override
  List<Object> get props => [Random().nextInt(1000)];
}

class LoadChannels extends AlwaysRefreshingChannelListEvent {
  final String categorySlug;
  final int channelLimit;

  LoadChannels({required this.categorySlug, this.channelLimit: 15});

  @override
  String toString() => 'LoadChannels';
}

class LoadMyLiveFollowedChannels extends AlwaysRefreshingChannelListEvent {
  @override
  String toString() => 'LoadMyLiveFollowedChannels';
}

class LoadHomepageChannels extends AlwaysRefreshingChannelListEvent {
  @override
  String toString() => 'LoadHomepageChannels';
}

@immutable
abstract class ChannelListState extends Equatable {}

class ChannelListLoading extends ChannelListState {
  @override
  String toString() => "ChannelListLoading";

  @override
  List<Object?> get props => [];
}

class ChannelListLoaded extends ChannelListState {
  final List<Channel> results;

  ChannelListLoaded({required this.results});

  @override
  List<Object> get props => results.map((e) => e.id).toList();
}

class ChannelListNotLoaded extends ChannelListState {
  final List<GraphQLError>? errors;

  ChannelListNotLoaded([this.errors]);

  @override
  String toString() => 'ReposNotLoaded';

  @override
  List<Object?> get props => [this.errors];
}

class ChannelListBloc extends Bloc<ChannelListEvent, ChannelListState> {
  final GlimeshRepository glimeshRepository;

  List<Channel> channels = [];

  ChannelListBloc({required this.glimeshRepository})
      : super(ChannelListLoading()) {
    on<LoadChannels>(_loadChannels);
    on<LoadMyLiveFollowedChannels>(_loadMyLiveFollowedChannels);
    on<LoadHomepageChannels>(_loadHomepageChannels);
  }

  _loadChannels(LoadChannels event, Emitter emit) async {
    emit(ChannelListLoading());

    print("inside");

    final queryResults =
        await this.glimeshRepository.getLiveChannels(event.categorySlug);

    if (queryResults.hasException) {
      print(queryResults.hasException);
      emit(ChannelListNotLoaded(queryResults.exception!.graphqlErrors));
      return;
    }

    final List<dynamic> channels =
        queryResults.data!['channels']['edges'] as List<dynamic>;

    final List<Channel> listOfChannels =
        channels.map(buildChannelFromJson).toList();

    listOfChannels.shuffle();

    print('map');
    listOfChannels.forEach((e) {
      print(e.id);
      print(e.title);
    });

    emit(ChannelListLoaded(results: listOfChannels));
  }

  _loadMyLiveFollowedChannels(
      LoadMyLiveFollowedChannels event, Emitter emit) async {
    emit(ChannelListLoading());

    final queryResults =
        await this.glimeshRepository.getMyLiveFollowedChannels();

    if (queryResults.hasException) {
      emit(ChannelListNotLoaded(queryResults.exception!.graphqlErrors));
      return;
    }

    final List<dynamic> channels = queryResults.data!['myself']
        ['followingLiveChannels']['edges'] as List<dynamic>;

    final List<Channel> listOfChannels =
        channels.map(buildChannelFromJson).toList();

    emit(ChannelListLoaded(results: listOfChannels));
  }

  _loadHomepageChannels(LoadHomepageChannels event, Emitter emit) async {
    emit(ChannelListLoading());

    final queryResults = await this.glimeshRepository.getHomepageChannels();

    if (queryResults.hasException) {
      emit(ChannelListNotLoaded(queryResults.exception!.graphqlErrors));
      return;
    }

    final List<dynamic> channels =
        queryResults.data!['homepageChannels']['edges'] as List<dynamic>;

    // filter and then map here because channels can stop streaming and still be on the homepage,
    // and this seemed like the best way instead of introducing nulls elsewhere.
    final List<Channel> listOfChannels = channels
        .where((c) => c['node']['stream'] != null)
        .map(buildChannelFromJson)
        .toList();

    listOfChannels.shuffle();

    emit(ChannelListLoaded(results: listOfChannels));
  }

  Channel buildChannelFromJson(dynamic json) {
    return Channel.buildFromJson(json['node']);
  }
}
