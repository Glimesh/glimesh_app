const String queryLiveChannels = r'''
query LiveChannels($categorySlug: String!) {
  channels(status: LIVE, categorySlug: $categorySlug) {
    id
    title
    stream {
      thumbnail 
    }
    streamer {
			username 
    }
  }
}
''';
