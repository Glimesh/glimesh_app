library glimesh_app.track;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plausible_analytics/plausible_analytics.dart';

const String serverUrl = "https://plausible.io";
const String domain = "app.glimesh.tv";

final track = Plausible(
  serverUrl,
  domain,
  userAgent: UserAgentBuilder.build(),
);

class UserAgentBuilder {
  // Build to help Plausible figure out what our device usage is. Not perfect yet though!
  static String build() {
    String os = Platform.operatingSystem;
    String osVersion = Platform.operatingSystemVersion;
    String osString = "${os} ${osVersion}";

    if (Platform.isIOS) {
      if (UserAgentBuilder.isTablet()) {
        os = "iPad";
      } else {
        os = "iPhone";
      }
      osVersion = Platform.operatingSystemVersion
          .replaceAll('"', '')
          .replaceAll(".", "_");

      osString = "${os}; CPU ${os} ${osVersion} like Mac OS X";
    } else if (Platform.isAndroid) {
      os = "Android";
      osVersion = Platform.operatingSystemVersion
          .replaceAll('"', '')
          .replaceAll(".", "_");

      osString = "Linux; ${os} ${osVersion}";
    }

    return "Mozilla/5.0 (${osString}) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E217";
  }

  static bool isTablet() {
    if (WidgetsBinding.instance != null) {
      final data = MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
      return data.size.shortestSide > 600;
    }

    return false;
  }
}
