import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';

class ChannelScreen extends StatefulWidget {
  final Channel channel;

  ChannelScreen({Key? key, required this.channel}) : super(key: key);

  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<ChatMessagesBloc>(context)
        .add(LoadChatMessages(channelId: widget.channel.id));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChannelWidget(channel: widget.channel);
  }
}

// Chat messages appear multiple times because this is a stateless widget and multiple LoadChatMessage events are sent
class ChannelWidget extends StatelessWidget {
  final Channel channel;

  ChannelWidget({required this.channel});

  Widget build(BuildContext context) {
    ChatMessagesBloc chatMessageBloc =
        BlocProvider.of<ChatMessagesBloc>(context);

    bool debug = true;

    return Scaffold(
      appBar: AppBar(title: Text("${channel.username}'s Channel")),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: debug
                ? Center(
                    child: Image.network(channel.thumbnail),
                  )
                : FTLPlayer(channel: channel),
          ),
          Container(child: StreamTitle(channel: channel)),
          Expanded(
            child: Chat(
              channel: channel,
              bloc: chatMessageBloc,
            ),
          ),
          ChatInput(onSubmit: (message) {
            chatMessageBloc.glimeshRepository
                .sendChatMessage(channel.id, message);
          }),
        ],
      ),
    );
  }
}
