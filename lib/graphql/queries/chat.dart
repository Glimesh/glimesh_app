const String getSomeChatMessages = r'''
query GetSomeChatMessages($channelId: ID!) {
  channel(id: $channelId) {
    chatMessages(last: 5) {
      edges {
        node {
          id
		  isFollowedMessage
		  isSubscriptionMessage
          tokens {
            type
            ...on EmoteToken {
              src
            }
            text
          }
          user {
            username
            avatarUrl
          }
		  metadata {
			admin
			moderator
			platformFounderSubscriber
			platformSupporterSubscriber
			streamer
			subscriber
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
	isFollowedMessage
	isSubscriptionMessage
    tokens {
      type
      ... on EmoteToken {
        src
      }
      text
    }
    user {
      username
      avatarUrl
    }
	metadata {
	  admin
	  moderator
	  platformFounderSubscriber
	  platformSupporterSubscriber
	  streamer
	  subscriber
	}
  }
}
''';

const String sendChatMessageMutation = r'''
mutation SendChatMessage($channelId: ID!, $message: String!) {
  createChatMessage(channelId: $channelId, message: { message: $message }) {
    id
  } 
}
''';
