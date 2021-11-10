import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/models.dart';

class ChannelScreen extends StatefulWidget {
  final Channel channel;

  ChannelScreen({Key? key, required this.channel}) : super(key: key);

  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  ChatMessagesBloc? chatMessageBloc;

  @override
  void initState() {
    super.initState();

    if (chatMessageBloc == null) {
      chatMessageBloc = BlocProvider.of<ChatMessagesBloc>(context);

      chatMessageBloc!.add(LoadChatMessages(channelId: widget.channel.id));
    }
  }

  @override
  void dispose() {
    chatMessageBloc!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (chatMessageBloc != null) {
      return ChannelWidget(
        channel: widget.channel,
        chatMessagesBloc: chatMessageBloc!,
      );
    } else {
      return Text("Loading");
    }
  }
}

// Chat messages appear multiple times because this is a stateless widget and multiple LoadChatMessage events are sent
class ChannelWidget extends StatelessWidget {
  final Channel channel;
  final ChatMessagesBloc chatMessagesBloc;
  final bool debug = false;

  ChannelWidget({required this.channel, required this.chatMessagesBloc});

  Widget build(BuildContext context) {
    bool horizontalTablet = MediaQuery.of(context).size.width > 992;

    return Scaffold(
      body: SafeArea(
        child: horizontalTablet ? _buildSidebar() : _buildStacked(),
      ),
    );
  }

  Widget _buildStacked() {
    return Column(
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
          ),
        ),
        ChatInput(onSubmit: (message) {
          chatMessagesBloc.glimeshRepository
              .sendChatMessage(channel.id, message);
        }),
      ],
    );
  }

  Widget _buildSidebar() {
    return Row(children: [
      Expanded(
        flex: 9,
        child: Column(children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: debug
                ? Center(
                    child: Image.network(channel.thumbnail),
                  )
                : FTLPlayer(channel: channel),
          ),
          Container(child: StreamTitle(channel: channel)),
        ]),
      ),
      Expanded(
        flex: 3,
        child: Column(
          children: [
            Expanded(
              child: Chat(
                channel: channel,
              ),
            ),
            ChatInput(onSubmit: (message) {
              chatMessagesBloc.glimeshRepository
                  .sendChatMessage(channel.id, message);
            })
          ],
        ),
      ),
    ]);
  }
}
