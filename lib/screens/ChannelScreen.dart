import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/channel_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/models.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class ChannelScreen extends StatelessWidget {
  final Channel channel;

  ChannelScreen({Key? key, required this.channel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelBloc, ChannelState>(
        builder: (BuildContext context, ChannelState state) {
      if (state is ChannelLoading) {
        return Scaffold(body: Loading(context.t("Loading Stream")));
      }

      if (state is ChannelNotLoaded) {
        return Scaffold(body: Text(context.t("Error loading channels")));
      }

      if (state is ChannelReady) {
        final JanusEdgeRoute edgeRoute = state.edgeRoute;

        Widget chatWidget = Chat(channel: channel);

        return Scaffold(
          body: SafeArea(
            child: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return _buildStacked(
                    _videoPlayer(context, edgeRoute.url),
                    chatWidget,
                  );
                } else {
                  double width = MediaQuery.of(context).size.width;
                  // 1000 is arbitrary...
                  if (width < 1000) {
                    return _videoPlayer(context, edgeRoute.url,
                        forceAspectRatio: false);
                  } else {
                    return _buildSidebar(
                        _videoPlayer(context, edgeRoute.url), chatWidget);
                  }
                }
              },
            ),
          ),
        );
      }

      return SizedBox();
    });
  }

  Widget _videoPlayer(context, url, {forceAspectRatio = true}) {
    Widget ftlPlayer = FTLPlayer(channel: channel, edgeUrl: url);
    Widget videoChild = forceAspectRatio
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: ftlPlayer,
          )
        : Center(child: ftlPlayer);
    final Widget subtree = Stack(
      children: [
        videoChild,
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

    return subtree;
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
