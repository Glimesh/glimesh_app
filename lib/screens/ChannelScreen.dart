import 'package:flutter/material.dart';
import 'package:gql_phoenix_link/gql_phoenix_link.dart';
import 'package:phoenix_socket/phoenix_socket.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:glimesh_app/glimesh.dart';
import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/components/Loading.dart';

class JanusEdgeRoute {
  JanusEdgeRoute({required this.id, required this.url});

  final int id;
  final String url;
}

class ChannelScreen extends StatefulWidget {
  final Channel channel;

  ChannelScreen({Key? key, required this.channel}) : super(key: key);

  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  ChatMessagesBloc? chatMessagesBloc;
  late GraphQLClient client;
  late PhoenixChannel channel;
  late GlimeshRepository repository;

  Future<JanusEdgeRoute> _watchChannel(int channelId) async {
    const glimeshWsApiUrl = String.fromEnvironment("GLIMESH_WS_API_URL",
        defaultValue: "wss://glimesh.test");
    String? token = await getGlimeshToken();
    final _socketUrl =
        "$glimeshWsApiUrl/api/graph/websocket?vsn=2.0.0&token=$token";
    channel = await PhoenixLink.createChannel(websocketUri: _socketUrl);
    final PhoenixLink _phoenixLink = PhoenixLink(channel: channel);

    client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _phoenixLink,
    );

    repository = GlimeshRepository(client: client);
    chatMessagesBloc = ChatMessagesBloc(
      glimeshRepository: repository,
    );

    chatMessagesBloc!.add(LoadChatMessages(channelId: widget.channel.id));

    final queryResults = await repository.watchChannel(widget.channel.id, "US");

    final dynamic janusEdge = queryResults.data!['watchChannel'] as dynamic;
    return JanusEdgeRoute(
      id: int.parse(janusEdge['id']),
      url: janusEdge['url'] as String,
    );
  }

  JanusEdgeRoute? edgeRoute;

  @override
  void initState() {
    super.initState();

    if (edgeRoute == null) {
      _watchChannel(widget.channel.id).then((JanusEdgeRoute edge) => {
            setState(() {
              edgeRoute = edge;
            })
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool horizontalTablet = MediaQuery.of(context).size.width > 992;

    return Scaffold(
        body: SafeArea(
            child: edgeRoute == null
                ? Loading("Loading Stream")
                : horizontalTablet
                    ? _buildSidebar(edgeRoute!.url)
                    : _buildStacked(edgeRoute!.url)));
  }

  Widget _buildStacked(String edgeUrl) {
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: FTLPlayer(channel: widget.channel, edgeUrl: edgeUrl),
            ),
            InkWell(
              child: Icon(Icons.chevron_left),
              onTap: () => Navigator.pop(context),
            )
          ],
        ),
        Container(
          child: StreamTitle(
            channel: widget.channel,
            allowMetadata: true,
          ),
        ),
        Expanded(
          child: Chat(
            channel: widget.channel,
            chatMessagesBloc: chatMessagesBloc!,
          ),
        ),
        ChatInput(onSubmit: (message) {
          repository.sendChatMessage(widget.channel.id, message);
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
            child: FTLPlayer(channel: widget.channel, edgeUrl: edgeUrl),
          ),
          Container(
            child: StreamTitle(
              channel: widget.channel,
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
                channel: widget.channel,
                chatMessagesBloc: chatMessagesBloc!,
              ),
            ),
            ChatInput(onSubmit: (message) {
              repository.sendChatMessage(widget.channel.id, message);
            })
          ],
        ),
      ),
    ]);
  }

  @override
  void deactivate() {
    print("widget deactivate");
    channel.close();
    if (chatMessagesBloc != null) {
      chatMessagesBloc!.close();
    }

    super.deactivate();
  }
}
