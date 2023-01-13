import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:glimesh_app/models.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;

class WHEPPlayer extends StatefulWidget {
  final Channel channel;
  final String edgeUrl;

  const WHEPPlayer({Key? key, required this.channel, required this.edgeUrl})
      : super(key: key);

  @override
  _WHEPPlayerState createState() => _WHEPPlayerState();
}

class _WHEPPlayerState extends State<WHEPPlayer> {
  RTCPeerConnection? pc;
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  bool _loading = true;
  bool _errored = false;
  bool _fatalErrored = false;
  String _errorMessage = "";
  int _seconds = 0;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _remoteRenderer.initialize();
  }

  initConnection() async {
    log("Init peer connection");
    pc = await createPeerConnection({});
    if (pc == null) {
      return;
    }
    pc!.onTrack = (event) {
      _remoteRenderer.srcObject = event.streams[0];
      setState(() {
        _fatalErrored = false;
        _errored = false;
        _loading = false;
      });
    };

    var endpoint =
        Uri.https("live.glimesh.tv", "v1/whep/endpoint/${widget.channel.id}");
    log("POST ${endpoint.toString()}");
    var response = await http.post(
      endpoint,
      headers: {"Accept": "application/sdp"},
      body: "",
    );
    if (response.statusCode == 307) {
      var location = response.headers["location"]!;
      log("POST ${location}");
      // Kinda sucks that this is hardcoded, need to loop it... One hop for now only.
      var response2 = await http.post(
        Uri.parse(location),
        headers: {"Accept": "application/sdp"},
        body: "",
      );

      log("${response2.statusCode} ${response2.body}");
      response = response2;
    }
    log("${response.statusCode} ${response.body}");
    if (response.statusCode != 201 ||
        response.headers.containsKey("location") == false) {
      if (mounted) {
        setState(() {
          _fatalErrored = true;
          _loading = false;
          _errorMessage = "WebRTC failed to negotiate offer from server.";
        });
      }
      return;
    }

    var offer = response.body;
    var sdp = RTCSessionDescription(offer, "offer");
    await pc!.setRemoteDescription(sdp);
    log("after setRemoteDescription");

    var answer = await pc!.createAnswer();
    await pc!.setLocalDescription(answer);
    log("after setLocalDescription");

    var answerEndpoint = Uri.parse(response.headers["location"]!);
    log("PATCH ${answerEndpoint}");
    var answerResponse = await http.patch(
      answerEndpoint,
      headers: {"Accept": "application/sdp"},
      body: answer.sdp,
    );
    log("${answerResponse.statusCode} ${answerResponse.body}");
    if (answerResponse.statusCode != 204) {
      if (mounted) {
        setState(() {
          _fatalErrored = true;
          _loading = false;
          _errorMessage = "WebRTC failed to negotiate answer with server.";
        });
      }
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    initConnection();

    Wakelock.enable();
  }

  @override
  void dispose() {
    if (Wakelock.enabled == true) {
      Wakelock.disable();
    }

    if (pc != null) {
      pc!.close();
    }

    _remoteRenderer.srcObject = null;
    _remoteRenderer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _fatalErrored
        ? Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                "Error loading video, please disable any VPNs or other software that could negatively impact WebRTC video and then try again. $_errorMessage",
                textAlign: TextAlign.center,
              ),
            ),
          )
        : Stack(
            children: [
              // Background layers that the video will take over when properly loaded
              _loading
                  ? Image.network(widget.channel.thumbnail)
                  : Padding(padding: EdgeInsets.zero),
              Container(
                decoration: BoxDecoration(color: Colors.black45),
                child: Loading("Loading Video"),
              ),
              _errored
                  ? Center(
                      child: Text(
                          "Error loading video, please try again. $_errorMessage"),
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
