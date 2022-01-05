import 'package:flutter/material.dart';
import 'package:janus_streaming_client/JanusClient.dart';
import 'package:janus_streaming_client/JanusPlugin.dart';
import 'package:janus_streaming_client/JanusSession.dart';
import 'package:janus_streaming_client/JanusTransport.dart';
import 'package:janus_streaming_client/shelf.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:glimesh_app/models.dart';

class FTLPlayer extends StatefulWidget {
  final Channel channel;
  final String edgeUrl;

  const FTLPlayer({Key? key, required this.channel, required this.edgeUrl})
      : super(key: key);

  @override
  _FTLPlayerState createState() => _FTLPlayerState();
}

class _FTLPlayerState extends State<FTLPlayer> {
  JanusClient? janus;
  RestJanusTransport? rest;
  JanusSession? session;
  JanusPlugin? plugin;

  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  bool _loading = true;

  watchChannel(int channelId) {
    plugin!.send(data: {"request": "watch", "channelId": channelId});
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _remoteRenderer.initialize();
  }

  initJanusClient() async {
    setState(() {
      rest = RestJanusTransport(
        url: widget.edgeUrl,
      );
      janus = JanusClient(transport: rest, iceServers: []);
    });

    session = await janus!.createSession();
    plugin = await session!.attach("janus.plugin.ftl");
    await this.watchChannel(widget.channel.id);

    plugin!.remoteStream!.listen((event) {
      if (event != null) {
        _remoteRenderer.srcObject = event;
      }
    });

    plugin!.messages!.listen((even) async {
      if (even.jsep != null) {
        await plugin!.handleRemoteJsep(even.jsep!);
        RTCSessionDescription answer = await plugin!.createAnswer();
        plugin!.send(data: {"request": "start"}, jsep: answer);

        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initJanusClient();
  }

  @override
  void dispose() {
    plugin!.send(data: {"request": "stop"});

    plugin!.dispose();
    session!.dispose();
    plugin!.remoteStream = null;
    _remoteRenderer.srcObject = null;
    _remoteRenderer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RTCVideoView(
          _remoteRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        ),
        _loading
            ? Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Padding(padding: EdgeInsets.all(10)),
                    Text("Loading Stream...")
                  ],
                ),
              )
            : Padding(padding: EdgeInsets.zero),
      ],
    );
  }
}
