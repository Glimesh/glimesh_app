import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocBuilder<ChannelBloc, ChannelState>(
        builder: (BuildContext context, ChannelState state) {
      print("BlocBuilder $state");
      if (state is ChannelLoading) {
        return Scaffold(
          body: SafeArea(
            child: _backButtonContainer(context, Loading("Loading Stream")),
          ),
        );
      }

      if (state is ChannelNotLoaded) {
        return Scaffold(
          body: SafeArea(
            child: _backButtonContainer(
              context,
              Center(
                child: Text("Error loading channels"),
              ),
            ),
          ),
        );
      }

      if (state is ChannelReady) {
        final JanusEdgeRoute edgeRoute = state.edgeRoute;

        Widget chatWidget = Chat(channel: channel);
        Widget videoWidget = Stack(
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

        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                print("rebuild orientation");

                if (constraints.maxWidth < 992) {
                  print("showing stacked");
                  return _buildStacked(videoWidget, chatWidget);
                } else if (constraints.maxWidth < constraints.maxHeight) {
                  print("showing video only");
                  // Mobile phone but landscape?
                  return videoWidget;
                } else {
                  print("showing sidebar");
                  return _buildSidebar(videoWidget, chatWidget);
                }
              },
            ),
          ),
        );
      }

      return SizedBox();
    });
  }

  Widget _backButtonContainer(BuildContext context, Widget child) {
    return Stack(
      children: [
        child,
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
  }

  Widget _buildStacked(
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
