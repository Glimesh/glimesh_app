const String getSomeChatMessages = r'''
query GetSomeChatMessages($channelId: ID!) {
  channel(id: $channelId) {
    chatMessages {
      id
      message
      user { username }
    }
  }
}
''';

const String chatMessages = r'''
subscription ChatMessages($channelId: ID!) {
  chatMessage(channelId: $channelId) {
    message
    user {
      username
    }
  }
}
''';