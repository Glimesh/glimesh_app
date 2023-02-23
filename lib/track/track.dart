library glimesh_app.track;

import 'package:plausible_analytics/plausible_analytics.dart';

// Conditionally loads mobile / web libraries based on compiled build
import 'package:glimesh_app/track/stub_track.dart'
    if (dart.library.io) 'package:glimesh_app/track/mobile_track.dart'
    if (dart.library.js) 'package:glimesh_app/track/web_track.dart';

const String serverUrl = "https://plausible.io";
const String domain = "app.glimesh.tv";

final userAgentBuilder = UserAgentBuilder.instance;

final track = Plausible(
  serverUrl,
  domain,
  userAgent: userAgentBuilder.build(),
);

abstract class UserAgentBuilder {
  static UserAgentBuilder? _instance;

  static UserAgentBuilder get instance {
    _instance ??= getUserAgentBuilder();
    return _instance!;
  }

  String build();
}
