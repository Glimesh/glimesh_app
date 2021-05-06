const String queryLiveChannels = r'''
query LiveChannels($categorySlug: String!) {
  channels(status: LIVE, categorySlug: $categorySlug) {
    edges {
      node {
        id
        title
        chatBgUrl
        stream {
          thumbnailUrl
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
