// Conditionally loads mobile / web libraries based on compiled build
import 'package:glimesh_app/auth/stub_handshake.dart'
    if (dart.library.io) 'package:glimesh_app/auth/mobile_handshake.dart'
    if (dart.library.js) 'package:glimesh_app/auth/web_handshake.dart';

abstract class AuthHandshake {
  static AuthHandshake? _instance;

  static AuthHandshake? get instance {
    _instance ??= getHandshake();
    return _instance;
  }

  Future<Uri> authorize(Uri authorizationUrl, Uri redirectUri);
}
