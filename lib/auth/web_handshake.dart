import 'dart:html' as html;
import 'dart:async';
import 'package:glimesh_app/auth/handshake.dart';

AuthHandshake getHandshake() => WebHandshake();

class WebHandshake extends AuthHandshake {
  String redirectUrl() {
    final currentUri = Uri.base;

    return Uri(
      host: currentUri.host,
      scheme: currentUri.scheme,
      port: currentUri.port,
      path: '/auth-redirect.html',
    ).toString();
  }

  Future<Uri> authorize(Uri authorizationUrl) async {
    var completer = new Completer<Uri>();

    html.WindowBase _popupWin = html.window.open(authorizationUrl.toString(),
        "Glimesh Auth", "width=800, height=900, scrollbars=yes");

    html.window.onMessage.listen((event) {
      /// If the event contains the token it means the user is authenticated.
      if (event.data.toString().contains('code=')) {
        _popupWin.close();

        completer.complete(Uri.parse(event.data));
      }
    });

    return completer.future;
  }
}
