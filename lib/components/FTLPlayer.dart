import 'package:flutter/material.dart';
import 'package:janus_client/JanusClient.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FTLPlayer extends StatefulWidget {
  @override
  _FTLPlayerState createState() => _FTLPlayerState();
}

class _FTLPlayerState extends State<FTLPlayer> {
  JanusClient? janus;
  RestJanusTransport? rest;
  JanusSession? session;
  JanusPlugin? plugin;
  Map<int, JanusPlugin> subscriberHandles = {};

  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  List<dynamic> streams = [];
  int? selectedStreamId;
  bool _loading = true;

  StateSetter? _setState;

  watchChannel(int channelId) {
    plugin!.send(data: {"request": "watch", "channelId": channelId});
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
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
    print(session!.sessionId);
    plugin = await session!.attach("janus.plugin.ftl");
    await this.watchChannel(1417);
    print('got handleId');
    print(plugin!.handleId);
    plugin!.remoteStream.listen((event) {
      if (event != null) {
        _remoteRenderer.srcObject = event;
      }
    });
    plugin!.messages.listen((even) async {
      print('got onmsg');
      print(even);

      if (even.jsep != null) {
        debugPrint("Handling SDP as well..." + even.jsep.toString());
        await plugin!.handleRemoteJsep(even.jsep);
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
    // TODO: implement initState
    super.initState();
    initJanusClient();
  }

  Future<void> cleanUpAndBack() async {
    plugin!.send(data: {"request": "stop"});
  }

  destroy() async {
    // await plugin!.dispose();
    session!.dispose();
    Navigator.of(context).pop();
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
                    Text("Loading FTL Stream..")
                  ],
                ),
              )
            : Padding(padding: EdgeInsets.zero),
      ],
    );
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
  }
}
