import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

@immutable
abstract class ChatMessagesEvent extends Equatable {
  ChatMessagesEvent([List props = const []]) : super();
}

class LoadChatMessages extends ChatMessagesEvent {
  final int channelId;

  LoadChatMessages({required this.channelId}) : super([channelId]);

  @override
  String toString() => 'LoadChatMessages';

  @override
  List<Object> get props => [this.channelId];
}

class NewChatMessage extends ChatMessagesEvent {
  final ChatMessage chatMessage;

  NewChatMessage({required this.chatMessage}) : super([chatMessage]);

  @override
  String toString() => 'NewChatMessage';

  @override
  List<Object> get props => [chatMessage];
}

@immutable
abstract class ChatMessagesState extends Equatable {
  ChatMessagesState([List props = const []]) : super();
}

class ChatMessage {
  const ChatMessage({
    required this.username,
    required this.message
  });

  final String username;
  final String message;
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


  ChatSubscriptionLoaded({required this.chatMessageSubscription}) : super([chatMessageSubscription]);

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

  ChatMessagesBloc({required this.glimeshRepository}): super(ChatMessagesLoading());

  @override
  Stream<ChatMessagesState> mapEventToState(ChatMessagesEvent event) async* {
    try {
      if (event is LoadChatMessages) {
        // Load some existing chat messages
        // final queryResults = await this.glimeshRepository.getSomeChatMessages(event.channelId);
        //
        // if (!queryResults.hasException) {
        //   final List<dynamic> messages = queryResults.data!['channel']['chatMessages'] as List<dynamic>;
        //
        //   final List<ChatMessage> existingChatMessages = messages.map((dynamic e) =>
        //       ChatMessage(
        //           username: e['user']['username'] as String,
        //           message: e['message'] as String
        //       )).toList();
        //
        //   chatMessages = existingChatMessages;
        //   _controller.add(chatMessages);
        // }
        //
        chatMessages = [
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
          ChatMessage(username: "clone1018", message: "Some test message"),
        ];
        _controller.add(chatMessages.reversed.toList());

        // Subscribe for more updates
        Stream<QueryResult> subscription = this.glimeshRepository.subscribeToChatMessages(event.channelId);

        subscription.listen((event) {
          dynamic data = event.data!['chatMessage'] as dynamic;

          ChatMessage chatMessage = ChatMessage(
              username: data['user']['username'] as String,
              message: data['message'] as String
          );

          chatMessages.add(chatMessage);

          // Introducing the slowest thing on the planet!
          _controller.add(chatMessages.reversed.toList());
        });

        yield ChatSubscriptionLoaded(chatMessageSubscription: chatMessagesStream);
      } else {
        print(event);
        // New event, who dis?
      }
    } catch (_, stackTrace) {
      print('$_ $stackTrace');
      yield state;
    }
  }

  Future<void> close() {
    _controller.close();

    return super.close();
  }
}