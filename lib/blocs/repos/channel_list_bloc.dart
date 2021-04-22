import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

@immutable
abstract class ChannelListState extends Equatable {
  ChannelListState([List props = const []]) : super();
}

class Channel {
  const Channel(
      {required this.id, required this.title, required this.thumbnail});

  final int id;
  final String title;
  final String thumbnail;
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
    print("got here");
    try {
      if (event is LoadChannels) {
        yield* _mapChannelsToState(event.categorySlug, event.channelLimit);
      } else {
        // New event, who dis?
      }
    } catch (_, stackTrace) {
      print('$_ $stackTrace');
      yield state;
    }
  }

  Stream<ChannelListState> _mapChannelsToState(
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
          queryResults.data!['channels'] as List<dynamic>;

      final List<Channel> listOfChannels = channels
          .map((dynamic e) => Channel(
              id: int.parse(e['id']),
              title: e['title'] as String,
              thumbnail: e['stream']['thumbnail'] as String))
          .toList();

      listOfChannels.sort((a, b) => a.id.compareTo(b.id));

      yield ChannelListLoaded(results: listOfChannels);
    } catch (error) {
      print(error);
      yield ChannelListNotLoaded();
    }
  }
}
