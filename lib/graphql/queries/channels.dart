const String queryLiveChannels = r'''
query LiveChannels($categorySlug: String!) {
  channels(status: LIVE, categorySlug: $categorySlug) {
    edges {
      node {
        id
        title
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
            username
            avatarUrl
          }
        }
      }
    }
  }
}
''';