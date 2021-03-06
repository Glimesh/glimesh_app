import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:janus_streaming_client/JanusClient.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:glimesh_app/models.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
  bool _errored = false;
  bool _fatalErrored = false;
  int _seconds = 0;

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
      // plugin!.remoteStream!.forEach((stream) {
      //   stream.getAudioTracks()[0].enableSpeakerphone(true);
      // });

      // MediaStream? remoteStream = await plugin!.remoteStream!.first;
      // if (remoteStream.active != null && remoteStream.active!) {
      //   print("!! Enabling speakerphone !!");
      //   remoteStream.getAudioTracks()[0].enableSpeakerphone(true);
      // }
    }
  }

  initJanusClient() async {
    print("init janus client");
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

    try {
      session = await janus!.createSession();
      plugin = await session!.attach("janus.plugin.ftl");
    } catch (error) {
      print(error);
      await Sentry.captureMessage(
          "Failed to attach session / plugin in FTLPlayer");

      if (mounted) {
        setState(() {
          _errored = true;
          _loading = false;
        });
      }
      return;
    }
    await this.watchChannel(widget.channel.id);

    plugin!.remoteStream!.listen((event) {
      if (event != null) {
        _remoteRenderer.srcObject = event;
      }
    });

    plugin!.messages!.listen((event) async {
      if (event.jsep != null) {
        try {
          await plugin!.handleRemoteJsep(event.jsep!);
          RTCSessionDescription answer = await plugin!.createAnswer();
          plugin!.send(data: {"request": "start"}, jsep: answer);

          await _setupSpeakerphone();

          setState(() {
            _errored = false;
            _loading = false;
            _seconds = 0;
          });
        } catch (error) {
          // We can likely retry loading this stream with initJanusClient();
          print(error);
          await Sentry.captureMessage("Failed to handle plugin answer");

          if (mounted) {
            setState(() {
              _errored = true;
              _loading = false;
              _seconds = 0;
            });
          }
          return;
        }
      }
    });

    Timer.periodic(Duration(seconds: 1), (innerTimer) async {
      if (mounted == false) {
        return;
      }

      // if we don't have a videoHeight after 10 seconds, assume we errored due to VPN or similar.
      setState(() {
        _seconds += 1;
      });
      if (_seconds > 10 && _remoteRenderer.videoHeight == 0) {
        print("Video loading for greater than 10 seconds, aborting");
        await Sentry.captureMessage(
            "Video loading for greater than 10 seconds, aborting");

        innerTimer.cancel();
        stopVideo();

        setState(() {
          _fatalErrored = true;
          _loading = false;
        });
      }

      // Check to see if Janus lost connection without telling us
      if (plugin != null && plugin!.pollingActive == false) {
        print("Polling has failed without telling us, resetting the widget");
        await Sentry.captureMessage(
            "Polling has failed without telling us, resetting the widget");
        innerTimer.cancel();

        if (mounted) {
          // If we're not mounted, we can just forget about it
          initJanusClient();
        }
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
    if (Wakelock.enabled == true) {
      Wakelock.disable();
    }

    if (plugin != null) {
      stopVideo();
    }

    if (session != null) {
      session!.dispose();
    }

    _remoteRenderer.srcObject = null;
    _remoteRenderer.dispose();

    super.dispose();
  }

  void stopVideo() {
    plugin!.send(data: {"request": "stop"});
    plugin!.remoteStream = null;
    plugin!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _fatalErrored
        ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                "Error loading video, please disable any VPNs or other software that could negatively impact WebRTC video and then try again.",
                textAlign: TextAlign.center,
              ),
            ),
          )
        : Stack(
            children: [
              // Background layers that the video will take over when properly loaded
              Image.network(widget.channel.thumbnail),
              Container(
                decoration: BoxDecoration(color: Colors.black45),
                child: Loading("Loading Video"),
              ),
              _errored
                  ? Center(
                      child: Text("Error loading video, please try again."),
                    )
                  : RTCVideoView(
                      _remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
              _loading
                  ? Loading("Loading Video")
                  : Padding(padding: EdgeInsets.zero),
            ],
          );
  }
}
