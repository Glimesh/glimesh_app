import 'package:flutter/material.dart';

class User {
  User({
    required this.id,
    required this.username,
    this.teamRole,
    required this.avatarUrl,
    required this.countFollowers,
    required this.countFollowing,
    this.profileContentMd,
    this.socialDiscord,
    this.socialGuilded,
    this.socialYoutube,
    this.socialInstagram,
    required this.socials,
  });

  final int id;
  final String username;
  final String? teamRole;
  final String avatarUrl;
  final int countFollowers;
  final int countFollowing;
  final String? profileContentMd;
  final String? socialDiscord;
  final String? socialGuilded;
  final String? socialYoutube;
  final String? socialInstagram;
  List<Social> socials;
}

class Social {
  const Social({
    required this.platform,
    required this.username,
  });

  final String platform;
  final String username;
}

class ChatMessage {
  const ChatMessage({
    required this.username,
    required this.message,
    required this.avatarUrl,
  });

  final String username;
  final String avatarUrl;
  final String message;
}

class Category {
  String name;
  String slug;
  IconData icon;

  Category({
    required this.name,
    required this.slug,
    this.icon = Icons.question_answer,
  });
}

class Subcategory {
  const Subcategory({required this.name});

  final String name;
}

class Tag {
  const Tag({required this.name});

  final String name;
}

class Channel {
  Channel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.chatBackgroundUrl,
    required this.username,
    required this.avatarUrl,
    required this.language,
    required this.matureContent,
    required this.tags,
    this.subcategory,
  });

  final int id;
  final String title;
  final String thumbnail;
  final String chatBackgroundUrl;

  final String username;
  final String avatarUrl;

  final String language;
  final bool matureContent;

  List<Tag> tags = [];
  final Subcategory? subcategory;
}
