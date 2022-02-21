import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/models.dart';

/* Events */
@immutable
abstract class ChannelEvent extends Equatable {
  ChannelEvent([List props = const []]) : super();
}

class LoadChannel extends ChannelEvent {
  final int channelId;

  LoadChannel({required this.channelId}) : super([channelId]);

  @override
  List<Object> get props => [this.channelId];
}

class WatchChannel extends ChannelEvent {
  final int channelId;

  WatchChannel({required this.channelId}) : super([channelId]);

  @override
  List<Object> get props => [this.channelId];
}

class SendChatMessage extends ChannelEvent {
  final int channelId;
  final String message;

  SendChatMessage({required this.channelId, required this.message})
      : super([channelId, message]);

  @override
  List<Object> get props => [this.channelId, message];
}

/* State */
@immutable
abstract class ChannelState extends Equatable {
  ChannelState([List props = const []]) : super();
}

class ChannelLoading extends ChannelState {
  @override
  List<Object?> get props => [];
}

// ChannelLoaded is for actually fetching a channel
class ChannelLoaded extends ChannelState {
  final User channel;

  ChannelLoaded({required this.channel}) : super([channel]);

  @override
  List<Object> get props => [channel];
}

// ChannelReady is for when we're ready to play the video
class ChannelReady extends ChannelState {
  final JanusEdgeRoute edgeRoute;
  final Stream<List<ChatMessage>> chatMessagesStream;

  ChannelReady({required this.edgeRoute, required this.chatMessagesStream})
      : super([edgeRoute, chatMessagesStream]);

  @override
  List<Object> get props => [edgeRoute];
}

class ChannelNotLoaded extends ChannelState {
  final List<GraphQLError>? errors;

  ChannelNotLoaded([this.errors]) : super([errors]);

  @override
  List<Object?> get props => [this.errors];
}

/* Bloc */
class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  final GlimeshRepository glimeshRepository;

  ChannelBloc({required this.glimeshRepository}) : super(ChannelLoading());

  List<ChatMessage> chatMessages = [];

  final _controller = StreamController<List<ChatMessage>>();
  Stream<List<ChatMessage>> get chatMessagesStream =>
      _controller.stream.asBroadcastStream();

  @override
  Stream<ChannelState> mapEventToState(ChannelEvent event) async* {
    try {
      print("ChannelBloc.mapEventToState($event)");
      if (event is WatchChannel) {
        print("Event is WatchChannel");

        JanusEdgeRoute edgeRoute = await watchChannel(event.channelId);
        Stream<QueryResult> subscription =
            this.glimeshRepository.subscribeToChatMessages(event.channelId);

        final queryResults =
            await this.glimeshRepository.getSomeChatMessages(event.channelId);

        if (!queryResults.hasException) {
          final List<dynamic> messages = queryResults.data!['channel']
              ['chatMessages']['edges'] as List<dynamic>;

          final List<ChatMessage> existingChatMessages = messages
              .map((dynamic e) => ChatMessage(
                    username: e['node']['user']['username'] as String,
                    avatarUrl: e['node']['user']['avatarUrl'] as String,
                    tokens: _buildMessageTokensFromJson(e['node']['tokens']),
                  ))
              .toList();

          chatMessages = existingChatMessages.reversed.toList();
          _controller.add(chatMessages);
        }

        subscription.listen((event) {
          dynamic data = event.data!['chatMessage'] as dynamic;

          ChatMessage chatMessage = ChatMessage(
            username: data['user']['username'] as String,
            avatarUrl: data['user']['avatarUrl'] as String,
            tokens: _buildMessageTokensFromJson(data['tokens']),
          );

          chatMessages.insert(0, chatMessage);

          // Introducing the slowest thing on the planet!
          // chatMessagesStream.
          _controller.add(chatMessages);
          // _controller.add(chatMessages.reversed.toList());
        });

        yield ChannelReady(
          edgeRoute: edgeRoute,
          chatMessagesStream: chatMessagesStream,
        );
      } else if (event is SendChatMessage) {
        // Currently this doesn't yield anything back since the subscription handler will automatically get it back from the server
        // TODO: What we should add is yielding an error when it fails to send.
        this.glimeshRepository.sendChatMessage(event.channelId, event.message);
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

  Future<JanusEdgeRoute> watchChannel(int channelId) async {
    QueryResult res =
        await this.glimeshRepository.watchChannel(channelId, "US");

    return _buildJanusEdgeRouteFromJson(res.data!['watchChannel']);
  }

  List<MessageToken> _buildMessageTokensFromJson(List<dynamic> json) {
    final List<MessageToken> tokens = json
        .map((dynamic token) => MessageToken(
              tokenType: token['type'] as String,
              text: token['text'] as String,
              src: token['src'] as String?,
            ))
        .toList();

    return tokens;
  }

  JanusEdgeRoute _buildJanusEdgeRouteFromJson(dynamic json) {
    return JanusEdgeRoute(
      id: int.parse(json['id']),
      url: json['url'] as String,
    );
  }
}
