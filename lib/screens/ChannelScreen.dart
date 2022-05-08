import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/channel_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/components/MatureWarning.dart';
import 'package:glimesh_app/models.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class ChannelScreen extends StatefulWidget {
  final Channel channel;

  const ChannelScreen({Key? key, required this.channel}) : super(key: key);

  @override
  State<ChannelScreen> createState() => _ChannelScreenState(channel: channel);
}

class _ChannelScreenState extends State<ChannelScreen> {
  final Channel channel;
  bool isChatOnlyMode = false;
  bool showControls = true;

  _ChannelScreenState({required this.channel}) : super();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelBloc, ChannelState>(
        builder: (BuildContext context, ChannelState state) {
      print("BlocBuilder $state");
      if (state is ChannelLoading) {
        return Scaffold(
          body: SafeArea(
            child: _backButtonContainer(
                context, Loading(context.t("Loading Stream"))),
          ),
        );
      }

      if (state is ChannelShowMatureWarning) {
        return Scaffold(
          body: SafeArea(
            child: _backButtonContainer(
              context,
              MatureWarning(
                onAccept: () {
                  context
                      .read<ChannelBloc>()
                      .add(WatchChannel(channelId: channel.id));
                },
              ),
              darken: true,
            ),
          ),
        );
      }

      if (state is ChannelNotLoaded) {
        return Scaffold(
          body: SafeArea(
            child: _backButtonContainer(
              context,
              Center(
                child: Text(context.t("Error loading channels")),
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
            InkWell(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FTLPlayer(channel: channel, edgeUrl: edgeRoute.url),
              ),
              onTap: () {
                setState(() {
                  showControls = !showControls;
                });

                Future.delayed(const Duration(seconds: 10), () {
                  setState(() {
                    showControls = false;
                  });
                });
              },
            ),
            _controlsContainer(context),
          ],
        );

        if (isChatOnlyMode) {
          return _buildChatOnlyMode(chatWidget);
        }

        return Scaffold(
          // appBar here with 0 height just to make the background of the status bar black
          appBar: AppBar(toolbarHeight: 0.0),
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

  Widget _backButtonContainer(BuildContext context, Widget child,
      {bool darken = false}) {
    // On dark mode, there's no point in darkening it
    if (Theme.of(context).brightness == Brightness.dark) {
      darken = false;
    }

    return Stack(
      children: [
        child,
        InkWell(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.chevron_left,
              color: darken ? Colors.black87 : Colors.white70,
            ),
          ),
          onTap: () => Navigator.pop(context),
        )
      ],
    );
  }

  Widget _controlsContainer(BuildContext context) {
    return Visibility(
        visible: showControls,
        child: Container(
          color: Colors.black45,
          child: Row(children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.chevron_left)),
            Spacer(),
            IconButton(
                onPressed: () {
                  setState(() {
                    isChatOnlyMode = true;
                  });
                },
                icon: Icon(Icons.chat)),
          ]),
        ));
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

  Widget _buildChatOnlyMode(Widget chatWidget) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.t("Chat-Only Mode")),
          actions: [
            Padding(
              child: ElevatedButton(
                child: Text(context.t("Exit Chat-Only Mode")),
                onPressed: () {
                  setState(() {
                    isChatOnlyMode = false;
                  });
                },
              ),
              padding: EdgeInsets.all(8),
            )
          ],
        ),
        body: Column(children: [
          Container(child: StreamTitle(channel: channel, allowMetadata: true)),
          Expanded(child: chatWidget),
        ]));
  }
}
