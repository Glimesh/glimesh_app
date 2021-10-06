import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

import 'package:glimesh_app/auth/handshake.dart';

AuthHandshake getHandshake() => MobileHandshake();

class MobileHandshake extends AuthHandshake {
  _redirect(Uri authorizationUrl) async {
    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    }
  }

  String redirectUrl() {
    return String.fromEnvironment("GLIMESH_REDIRECT_URL",
        defaultValue: "tv.glimesh.app://login-callback");
  }

  Future<Uri> authorize(Uri authorizationUrl) async {
    var completer = new Completer<Uri>();

    await _redirect(authorizationUrl);

    StreamSubscription? _sub;
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri.toString().startsWith(redirectUrl())) {
        _sub!.cancel();
        completer.complete(uri);
      }
    }, onError: (err) {
      _sub!.cancel();
      completer.completeError(err);
    });

    return completer.future;
  }
}
