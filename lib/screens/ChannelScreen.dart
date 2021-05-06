import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/channel_list_bloc.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../repository.dart';

class ChannelScreen extends StatelessWidget {
  final GraphQLClient client;

  const ChannelScreen({required this.client}) : super();

  @override
  Widget build(BuildContext context) {
    Channel channel = ModalRoute.of(context)!.settings.arguments as Channel;

    return BlocProvider(
      create: (context) => ChatMessagesBloc(
        glimeshRepository: GlimeshRepository(client: client),
      ),
      child: ChannelWidget(channel: channel),
    );
  }
}

// Chat messages appear multiple times because this is a stateless widget and multiple LoadChatMessage events are sent
class ChannelWidget extends StatelessWidget {
  // ChannelWidget({Key? key, Channel? channel}) : super(key: key);
  final Channel channel;

  ChannelWidget({required this.channel});

  Widget build(BuildContext context) {
    BlocProvider.of<ChatMessagesBloc>(context)
        .add(LoadChatMessages(channelId: channel.id));

    bool debug = true;

    return Scaffold(
        appBar: AppBar(title: Text(channel.title)),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: debug
                  ? Center(
                      child: Image.network(
                          "https://glimesh.tv/images/stream-not-started-09759810c3e9ebedf236f1b173f5d51e.jpg?vsn=d"),
                    )
                  : FTLPlayer(channel: channel),
            ),
            Container(child: StreamTitle(channel: channel)),
            Expanded(
              child: Chat(
                channel: channel,
                bloc: BlocProvider.of<ChatMessagesBloc>(context),
              ),
            ),
            ChatInput(),
          ],
        ));
  }
}
