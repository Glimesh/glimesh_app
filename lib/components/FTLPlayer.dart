import 'package:flutter/material.dart';
import 'package:janus_client/JanusClient.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:glimesh_app/models.dart';

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
  Map<int, JanusPlugin> subscriberHandles = {};

  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

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
        url: 'https://janus-dev/janus',
      );
      janus = JanusClient(transport: rest, iceServers: []);
    });
    session = await janus!.createSession();
    print(session!.sessionId);
    plugin = await session!.attach("janus.plugin.ftl");
    await this.watchChannel(widget.channel.id);
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

  Future<void> cleanUpAndBack() async {}

  @override
  void dispose() {
    print("!! DISPOSE CALLED !!");

    plugin!.send(data: {"request": "stop"});

    plugin!.dispose();
    session!.dispose();
    plugin!.remoteStream = null;
    _remoteRenderer.srcObject = null;
    _remoteRenderer.dispose();

    super.dispose();
  }

  // @override
  // void deactivate() {
  //   super.deactivate();

  //   plugin!.send(data: {"request": "stop"});

  //   _remoteRenderer.dispose();
  //   session!.dispose();
  // }

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
}
