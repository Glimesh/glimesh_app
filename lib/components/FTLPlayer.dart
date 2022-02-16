import 'package:flutter/material.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:janus_streaming_client/JanusClient.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:glimesh_app/models.dart';
import 'package:wakelock/wakelock.dart';
import 'package:logging/logging.dart';

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
    await _setupSpeakerphone();
  }

  _setupSpeakerphone() async {
    if (plugin != null && plugin!.remoteStream != null) {
      plugin!.remoteStream!.forEach((stream) {
        stream.getAudioTracks()[0].enableSpeakerphone(true);
      });

      // MediaStream? remoteStream = await plugin!.remoteStream!.first;
      // if (remoteStream.active != null && remoteStream.active!) {
      //   print("!! Enabling speakerphone !!");
      //   remoteStream.getAudioTracks()[0].enableSpeakerphone(true);
      // }
    }
  }

  initJanusClient() async {
    setState(() {
      rest = RestJanusTransport(
        url: widget.edgeUrl,
      );
      janus = JanusClient(
        transport: rest,
        iceServers: [],
        loggerLevel: Level.WARNING,
      );
    });

    session = await janus!.createSession();
    plugin = await session!.attach("janus.plugin.ftl");
    await this.watchChannel(widget.channel.id);

    plugin!.remoteStream!.listen((event) {
      if (event != null) {
        _remoteRenderer.srcObject = event;
      }
    });

    plugin!.messages!.listen((event) async {
      if (event.jsep != null) {
        await plugin!.handleRemoteJsep(event.jsep!);
        RTCSessionDescription answer = await plugin!.createAnswer();
        plugin!.send(data: {"request": "start"}, jsep: answer);

        await _setupSpeakerphone();

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

    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();

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
        _loading ? Loading("Loading Video") : Padding(padding: EdgeInsets.zero),
      ],
    );
  }
}
