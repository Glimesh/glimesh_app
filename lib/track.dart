library glimesh_app.track;

import 'package:plausible_analytics/plausible_analytics.dart';

const String serverUrl = "https://plausible.io";
const String domain = "app.glimesh.tv";

final track = Plausible(serverUrl, domain);
