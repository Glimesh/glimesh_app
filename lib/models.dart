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

  @override
  String toString() {
    return "User(id: $id, username: $username)";
  }
}

class Social {
  const Social({
    required this.platform,
    required this.username,
  });

  final String platform;
  final String username;
}

class MessageToken {
  const MessageToken({
    required this.tokenType,
    required this.text,
    this.src,
    this.url,
  });

  final String tokenType;
  final String text;
  final String? src;
  final String? url;
}

class MessageMetadata {
  const MessageMetadata({
    required this.admin,
    required this.moderator,
    required this.platformFounderSubscriber,
    required this.platformSupporterSubscriber,
    required this.streamer,
    required this.subscriber,
  });

  final bool admin;
  final bool moderator;
  final bool platformFounderSubscriber;
  final bool platformSupporterSubscriber;
  final bool streamer;
  final bool subscriber;
}

class ChatMessage {
  const ChatMessage({
    required this.username,
    required this.avatarUrl,
    required this.tokens,
    this.metadata,
    required this.isSystemMessage,
  });

  final String username;
  final String avatarUrl;
  final List<MessageToken> tokens;
  final MessageMetadata? metadata;
  final bool isSystemMessage;
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
    required this.user_id,
    required this.avatarUrl,
    required this.matureContent,
    required this.tags,
    this.language,
    this.subcategory,
  });

  final int id;
  final String title;
  final String thumbnail;
  final String chatBackgroundUrl;

  final String username;
  final int user_id;
  final String avatarUrl;

  final String? language;
  final bool matureContent;

  List<Tag> tags = [];
  final Subcategory? subcategory;
}

class JanusEdgeRoute {
  JanusEdgeRoute({required this.id, required this.url});

  final int id;
  final String url;
}
