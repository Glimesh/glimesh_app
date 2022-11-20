import 'dart:async';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:glimesh_app/auth/handshake.dart';

AuthHandshake getHandshake() => MobileHandshake();

class MobileHandshake extends AuthHandshake {
  String redirectUrl() {
    return String.fromEnvironment("GLIMESH_REDIRECT_URL",
        defaultValue: "tv.glimesh.app://login-callback");
  }

  Future<Uri> authorize(Uri authorizationUrl) async {
    var completer = new Completer<Uri>();
    final result = await FlutterWebAuth.authenticate(
        url: authorizationUrl.toString(), callbackUrlScheme: "tv.glimesh.app");

    if (result.toString().startsWith(redirectUrl())) {
      completer.complete(Uri.parse(result));
    } else {
      completer.completeError("invalid redirect");
    }

    return completer.future;
  }
}
