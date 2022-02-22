import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/auth.dart';
import 'package:glimesh_app/blocs/repos/channel_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/models.dart';

class ChannelScreen extends StatelessWidget {
  final Channel channel;

  ChannelScreen({Key? key, required this.channel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = AuthState.of(context);

    return BlocBuilder<ChannelBloc, ChannelState>(
        builder: (BuildContext context, ChannelState state) {
      if (state is ChannelLoading) {
        return Scaffold(body: Loading("Loading Stream"));
      }

      if (state is ChannelNotLoaded) {
        return Scaffold(body: Text("Error loading channels"));
      }

      if (state is ChannelReady) {
        final JanusEdgeRoute edgeRoute = state.edgeRoute;
        ChannelBloc bloc = BlocProvider.of<ChannelBloc>(context);

        print("ChannelReady");

        Widget chatWidget = Chat(channel: channel);

        Widget videoPlayer = Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: FTLPlayer(channel: channel, edgeUrl: edgeRoute.url),
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white70,
                ),
              ),
              onTap: () => Navigator.pop(context),
            )
          ],
        );
        Widget metadata = Container(
          child: StreamTitle(
            channel: channel,
            allowMetadata: true,
          ),
        );

        return Scaffold(
          body: SafeArea(
            child: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return _buildStacked(edgeRoute.url, videoPlayer, chatWidget);
                } else {
                  return _buildSidebar(edgeRoute.url, videoPlayer, chatWidget);
                }
              },
            ),
          ),
        );
      }

      return SizedBox();
    });
  }

  Widget _buildStacked(
    String edgeUrl,
    Widget videoPlayer,
    Widget chatWidget,
  ) {
    return Column(
      children: [
        videoPlayer,
        Container(
          child: StreamTitle(
            channel: channel,
            allowMetadata: true,
          ),
        ),
        Expanded(
          child: chatWidget,
        ),
      ],
    );
  }

  Widget _buildSidebar(
    String edgeUrl,
    Widget videoPlayer,
    Widget chatWidget,
  ) {
    return Row(children: [
      Expanded(
        flex: 9,
        child: Column(children: [
          videoPlayer,
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
        child: chatWidget,
      ),
    ]);
  }
}
