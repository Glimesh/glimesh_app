const String getSomeChatMessages = r'''
query GetSomeChatMessages($channelId: ID!) {
  channel(id: $channelId) {
    chatMessages(last: 5) {
      edges {
        node {
          id
          message
          user {
            username
            avatarUrl
          }
        }
      }
    }
  }
}
''';

const String chatMessagesSubscription = r'''
subscription ChatMessages($channelId: ID!) {
  chatMessage(channelId: $channelId) {
    message
    user {
      username
      avatarUrl
    }
  }
}
''';
