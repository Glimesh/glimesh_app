import 'dart:html' show window;
import 'package:glimesh_app/track/track.dart';

UserAgentBuilder getUserAgentBuilder() => WebAgentBuilder();

class WebAgentBuilder extends UserAgentBuilder {
  // Pull the user agent directly from the window
  String build() {
    return window.navigator.userAgent;
  }
}
