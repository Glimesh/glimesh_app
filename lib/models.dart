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

class Channel {
  const Channel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.chatBackgroundUrl,
    required this.username,
    required this.avatarUrl,
  });

  final int id;
  final String title;
  final String thumbnail;
  final String chatBackgroundUrl;

  final String username;
  final String avatarUrl;
}
