const String queryLiveChannels = r'''
query LiveChannels($categorySlug: String!) {
  channels(status: LIVE, categorySlug: $categorySlug) {
    edges {
      node {
        id
        title
        backend
        chatBgUrl
        language
        matureContent
        
        stream {
          thumbnailUrl
        }

        subcategory {
          name
        }

        tags {
          name
        }

        streamer {
          id
          username
          avatarUrl
        }
      }
    }
  }
}

''';

const String queryLiveFollowedChannels = r'''
query GetMyself {
  myself {
    followingLiveChannels(first: 5) {
      edges {
        node {
          id
          title
          backend
          chatBgUrl
          language
          matureContent
          
          stream {
            thumbnailUrl
          }

          subcategory {
            name
          }

          tags {
            name
          }

          streamer {
            id
            username
            avatarUrl
          }
        }
      }
    }
  }
}
''';

const String queryHomepageChannels = r'''
query GetHomepageChannels {
  homepageChannels{
    edges {
      node {
        id
        title
        backend
        chatBgUrl
        language
        matureContent

        stream {
          thumbnailUrl
        }

        subcategory {
          name
        }

        tags {
          name
        }

        streamer {
          id
          username
          avatarUrl
        }
      }
    }
  }
}
''';

const String watchChannel = r'''
mutation WatchChannel($channelId: ID!, $country: String!) {
  watchChannel(channelId: $channelId, country: $country) {
    id
    url
  } 
}
''';
