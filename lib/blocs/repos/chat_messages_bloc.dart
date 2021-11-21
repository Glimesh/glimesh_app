import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

@immutable
abstract class ChatMessagesEvent extends Equatable {
  ChatMessagesEvent([List props = const []]) : super();
}

class LoadChatMessages extends ChatMessagesEvent {
  final int channelId;

  LoadChatMessages({required this.channelId}) : super([channelId]);

  @override
  List<Object> get props => [this.channelId];
}

class NewChatMessage extends ChatMessagesEvent {
  final ChatMessage chatMessage;

  NewChatMessage({required this.chatMessage}) : super([chatMessage]);

  @override
  List<Object> get props => [chatMessage];
}

@immutable
abstract class ChatMessagesState extends Equatable {
  ChatMessagesState([List props = const []]) : super();
}

class ChatMessagesLoading extends ChatMessagesState {
  @override
  String toString() => "ChatMessagesLoading";

  @override
  List<Object?> get props => [];
}

class ChatMessagesLoaded extends ChatMessagesState {
  @override
  String toString() => "ChatMessagesLoaded";

  @override
  List<Object?> get props => [];
}

class ChatSubscriptionLoaded extends ChatMessagesState {
  final Stream<List<ChatMessage>> chatMessageSubscription;

  ChatSubscriptionLoaded({required this.chatMessageSubscription})
      : super([chatMessageSubscription]);

  @override
  List<Object> get props => [chatMessageSubscription];
}

class ChatMessagesNotLoaded extends ChatMessagesState {
  final List<GraphQLError>? errors;

  ChatMessagesNotLoaded([this.errors]) : super([errors]);

  @override
  String toString() => 'ChatMessagesNotLoaded';

  @override
  List<Object?> get props => [this.errors];
}

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GlimeshRepository glimeshRepository;

  final _controller = StreamController<List<ChatMessage>>();
  Stream<List<ChatMessage>> get chatMessagesStream => _controller.stream;

  List<ChatMessage> chatMessages = [];

  ChatMessagesBloc({required this.glimeshRepository})
      : super(ChatMessagesLoading());

  StreamSubscription<QueryResult>? subscriptionListener;

  @override
  Stream<ChatMessagesState> mapEventToState(ChatMessagesEvent event) async* {
    try {
      if (event is LoadChatMessages) {
        // Load some existing chat messages
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

        // Subscribe for more updates
        Stream<QueryResult> subscription =
            this.glimeshRepository.subscribeToChatMessages(event.channelId);

        subscriptionListener = subscription.listen((event) {
          dynamic data = event.data!['chatMessage'] as dynamic;

          ChatMessage chatMessage = ChatMessage(
            username: data['user']['username'] as String,
            avatarUrl: data['user']['avatarUrl'] as String,
            tokens: _buildMessageTokensFromJson(data['tokens']),
          );

          chatMessages.add(chatMessage);

          // Introducing the slowest thing on the planet!
          _controller.add(chatMessages.reversed.toList());
        });

        yield ChatSubscriptionLoaded(
            chatMessageSubscription: chatMessagesStream);
      } else {
        print(event);
        // New event, who dis?
      }
    } catch (_, stackTrace) {
      print('$_ $stackTrace');
      yield state;
    }
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

  Future<void> close() {
    _controller.close();

    subscriptionListener!.cancel();

    return super.close();
  }
}
