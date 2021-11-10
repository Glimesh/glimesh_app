import 'package:flutter/material.dart';

class User {
  const User({
    required this.id,
    required this.username,
  });

  final int id;
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
  final String avatarUrl;

  final String? language;
  final bool matureContent;

  List<Tag> tags = [];
  final Subcategory? subcategory;
}
