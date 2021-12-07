import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

@immutable
abstract class ChannelListEvent extends Equatable {
  ChannelListEvent([List props = const []]) : super();
}

class LoadChannels extends ChannelListEvent {
  final String categorySlug;
  final int channelLimit;

  LoadChannels({required this.categorySlug, this.channelLimit: 15})
      : super([categorySlug, channelLimit]);

  @override
  String toString() => 'LoadChannels';

  @override
  List<Object> get props => [this.categorySlug, this.channelLimit];
}

class LoadMyLiveFollowedChannels extends ChannelListEvent {
  @override
  String toString() => 'LoadMyLiveFollowedChannels';

  @override
  List<Object> get props => [];
}

class LoadHomepageChannels extends ChannelListEvent {
  @override
  String toString() => 'LoadHomepageChannels';

  @override
  List<Object> get props => [];
}

@immutable
abstract class ChannelListState extends Equatable {
  ChannelListState([List props = const []]) : super();
}

class ChannelListLoading extends ChannelListState {
  @override
  String toString() => "ChannelListLoading";

  @override
  List<Object?> get props => [];
}

class ChannelListLoaded extends ChannelListState {
  final List<Channel> results;

  ChannelListLoaded({required this.results}) : super([results]);

  @override
  List<Object> get props => [results];
}

class ChannelListNotLoaded extends ChannelListState {
  final List<GraphQLError>? errors;

  ChannelListNotLoaded([this.errors]) : super([errors]);

  @override
  String toString() => 'ReposNotLoaded';

  @override
  List<Object?> get props => [this.errors];
}

class ChannelListBloc extends Bloc<ChannelListEvent, ChannelListState> {
  final GlimeshRepository glimeshRepository;

  List<Channel> channels = [];

  ChannelListBloc({required this.glimeshRepository})
      : super(ChannelListLoading());

  @override
  Stream<ChannelListState> mapEventToState(ChannelListEvent event) async* {
    try {
      if (event is LoadChannels) {
        yield* _loadChannels(event.categorySlug, event.channelLimit);
      } else if (event is LoadMyLiveFollowedChannels) {
        yield* _loadMyLiveFollowedChannels();
      } else if (event is LoadHomepageChannels) {
        yield* _loadHomepageChannels();
      } else {
        // New event, who dis?
      }
    } catch (_, stackTrace) {
      print('$_ $stackTrace');
      yield state;
    }
  }

  Stream<ChannelListState> _loadChannels(
      String categorySlug, int channelLimit) async* {
    try {
      yield ChannelListLoading();

      final queryResults =
          await this.glimeshRepository.getLiveChannels(categorySlug);

      if (queryResults.hasException) {
        yield ChannelListNotLoaded(queryResults.exception!.graphqlErrors);
        return;
      }

      final List<dynamic> channels =
          queryResults.data!['channels']['edges'] as List<dynamic>;

      final List<Channel> listOfChannels =
          channels.map(buildChannelFromJson).toList();

      // This is temporary to show my stream at the top :)
      listOfChannels.sort((a, b) => b.id.compareTo(a.id));

      yield ChannelListLoaded(results: listOfChannels);
    } catch (error) {
      print(error);
      yield ChannelListNotLoaded();
    }
  }

  Stream<ChannelListState> _loadMyLiveFollowedChannels() async* {
    try {
      yield ChannelListLoading();

      final queryResults =
          await this.glimeshRepository.getMyLiveFollowedChannels();

      if (queryResults.hasException) {
        yield ChannelListNotLoaded(queryResults.exception!.graphqlErrors);
        return;
      }

      final List<dynamic> channels = queryResults.data!['myself']
          ['followingLiveChannels']['edges'] as List<dynamic>;

      final List<Channel> listOfChannels =
          channels.map(buildChannelFromJson).toList();

      yield ChannelListLoaded(results: listOfChannels);
    } catch (error) {
      print(error);
      yield ChannelListNotLoaded();
    }
  }

  Stream<ChannelListState> _loadHomepageChannels() async* {
    try {
      yield ChannelListLoading();

      final queryResults = await this.glimeshRepository.getHomepageChannels();

      if (queryResults.hasException) {
        yield ChannelListNotLoaded(queryResults.exception!.graphqlErrors);
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

      yield ChannelListLoaded(results: listOfChannels);
    } catch (error, s) {
      print(error);
      print(s);
      yield ChannelListNotLoaded();
    }
  }

  Channel buildChannelFromJson(dynamic json) {
    return Channel(
      id: int.parse(json['node']['id']),
      title: json['node']['title'] as String,
      chatBackgroundUrl: json['node']['chatBgUrl'] as String,
      thumbnail: json['node']['stream']['thumbnailUrl'] as String,
      username: json['node']['streamer']['username'] as String,
      avatarUrl: json['node']['streamer']['avatarUrl'] as String,
      matureContent: json['node']['matureContent'] as bool,
      language: buildString(json['node']['language']),
      subcategory: buildSubcategoryFromJson(json['node']['subcategory']),
      tags: buildTagsFromJson(json['node']['tags']),
    );
  }

  String? buildString(dynamic input) {
    if (input == null) {
      return null;
    }

    return input as String;
  }

  Subcategory? buildSubcategoryFromJson(dynamic subcategory) {
    if (subcategory == null) {
      return null;
    }

    return Subcategory(name: subcategory["name"] as String);
  }

  List<Tag> buildTagsFromJson(List<dynamic> tags) {
    return tags.map((dynamic e) => Tag(name: e['name'] as String)).toList();
  }
}
