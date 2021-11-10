import 'package:flutter/material.dart';
import 'package:janus_client/JanusClient.dart';
import 'package:janus_client/JanusClient.dart';
import 'package:janus_client/JanusPlugin.dart';
import 'package:janus_client/JanusSession.dart';
import 'package:janus_client/JanusTransport.dart';
import 'package:janus_client/JanusWebRTCHandle.dart';
import 'package:janus_client/WebRTCHandle.dart';
import 'package:janus_client/shelf.dart';
import 'package:janus_client/utils.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:glimesh_app/models.dart';
import 'package:flutter_incall/flutter_incall.dart';

class FTLPlayer extends StatefulWidget {
  final Channel channel;

  const FTLPlayer({Key? key, required this.channel}) : super(key: key);

  @override
  _FTLPlayerState createState() => _FTLPlayerState();
}

class _FTLPlayerState extends State<FTLPlayer> {
  JanusClient? janus;
  RestJanusTransport? rest;
  JanusSession? session;
  JanusPlugin? plugin;

  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
  IncallManager incall = new IncallManager();

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
        url: 'https://do-nyc3-edge1.kjfk.live.glimesh.tv/janus',
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
    // plugin!.remoteStream!.getAudioTracks()[0].enableSpeakerphone(true);
    // await plugin!.remoteStream!.first.then(
    // (value) => {value.getAudioTracks().first.enableSpeakerphone(true)});

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
    try {
      plugin!.send(data: {"request": "stop"});

      plugin!.dispose();
      session!.dispose();
      plugin!.localStream = null;
      plugin!.remoteStream = null;
      _remoteRenderer.srcObject = null;
      _remoteRenderer.dispose();
    } catch (e) {
      print(e.toString());
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Future: https://pub.dev/packages/audio_service

    // _remoteRenderer.audioOutput = "something";
    // navigator.mediaDevices.enumerateDevices().then((list) {
    //   for (var device in list) {
    //     print(device.label);
    //     print(device.kind);
    //     print("------");
    //   }
    // });

    incall.setKeepScreenOn(true);
    incall.setSpeakerphoneOn(true);

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
                    Text("Loading FTL Stream")
                  ],
                ),
              )
            : Padding(padding: EdgeInsets.zero),
      ],
    );
  }
}
