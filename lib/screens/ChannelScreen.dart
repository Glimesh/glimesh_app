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

class JanusEdgeRoute {
  JanusEdgeRoute({required this.id, required this.url});

  final int id;
  final String url;
}

// Chat messages appear multiple times because this is a stateless widget and multiple LoadChatMessage events are sent
class ChannelWidget extends StatelessWidget {
  final Channel channel;
  final ChatMessagesBloc chatMessagesBloc;
  final bool debug = false;

  ChannelWidget({required this.channel, required this.chatMessagesBloc});

  Future<JanusEdgeRoute> watchChannel(int channelId) async {
    // Todo: Move this to a real bloc
    final queryResults =
        await chatMessagesBloc.glimeshRepository.watchChannel(channel.id, "US");

    final dynamic janus_edge = queryResults.data!['watchChannel'] as dynamic;
    return JanusEdgeRoute(
      id: int.parse(janus_edge['id']),
      url: janus_edge['url'] as String,
    );
  }

  Widget build(BuildContext context) {
    bool horizontalTablet = MediaQuery.of(context).size.width > 992;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: watchChannel(channel.id),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              print(snapshot);
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return horizontalTablet
                      ? _buildSidebar(snapshot.data.url)
                      : _buildStacked(snapshot.data.url);
                default:
                  return const SizedBox();
              }
            }),
      ),
    );
  }

  Widget _buildStacked(String edgeUrl) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: debug
              ? Center(
                  child: Image.network(channel.thumbnail),
                )
              : FTLPlayer(channel: channel, edgeUrl: edgeUrl),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: StreamTitle(
              channel: channel,
              allowMetadata: true,
            ),
          ),
        ),
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

  Widget _buildSidebar(String edgeUrl) {
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
                : FTLPlayer(channel: channel, edgeUrl: edgeUrl),
          ),
          Container(
            child: StreamTitle(
              channel: channel,
              allowMetadata: true,
            ),
          ),
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
