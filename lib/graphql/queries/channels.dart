const String queryLiveChannels = r'''
query LiveChannels {
  channels(status:LIVE) {
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