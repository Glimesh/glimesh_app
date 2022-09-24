import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

@immutable
abstract class ChatMessagesEvent extends Equatable {}

class LoadChatMessages extends ChatMessagesEvent {
  final int channelId;

  LoadChatMessages({required this.channelId});

  @override
  List<Object> get props => [this.channelId];
}

class NewChatMessage extends ChatMessagesEvent {
  final ChatMessage chatMessage;

  NewChatMessage({required this.chatMessage});

  @override
  List<Object> get props => [chatMessage];
}

class SendChatMessage extends ChatMessagesEvent {
  final int channelId;
  final String message;

  SendChatMessage({required this.channelId, required this.message});

  @override
  List<Object> get props => [this.channelId, message];
}

/* State */
@immutable
abstract class ChatMessagesState extends Equatable {}

class ChatMessagesLoading extends ChatMessagesState {
  @override
  String toString() => "ChatMessagesLoading";

  @override
  List<Object?> get props => [];
}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<ChatMessage> messages;
  final int count;

  ChatMessagesLoaded({required this.messages, required this.count});

  @override
  List<Object?> get props => [count, messages];
}

class NewChatMessageLoaded extends ChatMessagesState {
  NewChatMessageLoaded(this.message);

  final ChatMessage message;

  @override
  List<Object?> get props => [message];
}

class ChatSubscriptionLoaded extends ChatMessagesState {
  final Stream<List<ChatMessage>> chatMessageSubscription;

  ChatSubscriptionLoaded({required this.chatMessageSubscription});

  @override
  List<Object> get props => [chatMessageSubscription];
}

class ChatMessagesNotLoaded extends ChatMessagesState {
  final List<GraphQLError>? errors;

  ChatMessagesNotLoaded([this.errors]);

  @override
  String toString() => 'ChatMessagesNotLoaded';

  @override
  List<Object?> get props => [this.errors];
}

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GlimeshRepository glimeshRepository;

  StreamSubscription<QueryResult>? subscriptionListener;

  List<ChatMessage> chatMessages = [];

  ChatMessagesBloc({required this.glimeshRepository})
      : super(ChatMessagesLoading()) {
    on<LoadChatMessages>((event, emit) async {
      // Load some existing chat messages
      final queryResults =
          await this.glimeshRepository.getSomeChatMessages(event.channelId);
      if (queryResults.hasException) {
        print(queryResults.exception!.graphqlErrors);
        emit(ChatMessagesNotLoaded(queryResults.exception!.graphqlErrors));
        return;
      }

      final List<dynamic> messages = queryResults.data!['channel']
          ['chatMessages']['edges'] as List<dynamic>;

      final List<ChatMessage> existingChatMessages = messages
          .map((dynamic e) => ChatMessage(
              username: e['node']['user']['username'] as String,
              avatarUrl: e['node']['user']['avatarUrl'] as String,
              isSystemMessage: e['node']['isFollowedMessage'] ||
                  e['node']['isSubscriptionMessage'],
              tokens: _buildMessageTokensFromJson(e['node']['tokens']),
              metadata: _buildMessageMetadataFromJson(e['node']['metadata'])))
          .toList();
      chatMessages = existingChatMessages.reversed.toList();

      emit(
        ChatMessagesLoaded(count: chatMessages.length, messages: chatMessages),
      );

      // Subscribe for more updates
      Stream<QueryResult> subscription =
          this.glimeshRepository.subscribeToChatMessages(event.channelId);

      await emit.onEach(subscription, onData: (QueryResult event) {
        dynamic data = event.data!['chatMessage'] as dynamic;

        ChatMessage chatMessage = ChatMessage(
            username: data['user']['username'] as String,
            avatarUrl: data['user']['avatarUrl'] as String,
            isSystemMessage: data['isFollowedMessage'] ||
                data['isSubscriptionMessage'],
            tokens: _buildMessageTokensFromJson(data['tokens']),
            metadata: _buildMessageMetadataFromJson(data['metadata']));

        // Send new chat messages as new events
        add(NewChatMessage(chatMessage: chatMessage));
      });
    });

    on<NewChatMessage>((event, emit) async {
      // In the future we should make this more efficient...
      chatMessages.insert(0, event.chatMessage);
      emit(ChatMessagesLoaded(
        count: chatMessages.length,
        messages: chatMessages,
      ));
    });

    on<SendChatMessage>((event, emit) async {
      // Currently this doesn't yield anything back since the subscription handler will automatically get it back from the server
      // TODO: What we should add is yielding an error when it fails to send.
      this.glimeshRepository.sendChatMessage(event.channelId, event.message);
    });
  }

  List<MessageToken> _buildMessageTokensFromJson(List<dynamic> json) {
    final List<MessageToken> tokens = json
        .map((dynamic token) => MessageToken(
              tokenType: token['type'] as String,
              text: token['text'] as String,
              src: token['src'] as String?,
              url: token['url'] as String?,
            ))
        .toList();

    return tokens;
  }

  MessageMetadata? _buildMessageMetadataFromJson(dynamic json) {
    if (json == null) return null;

    return MessageMetadata(
      admin: json['admin'],
      moderator: json['moderator'],
      platformFounderSubscriber: json['platformFounderSubscriber'],
      platformSupporterSubscriber: json['platformSupporterSubscriber'],
      streamer: json['streamer'],
      subscriber: json['subscriber'],
    );
  }
}
