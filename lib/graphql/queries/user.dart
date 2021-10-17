const String getMyself = r'''
query GetMyself {
  myself {
    id
    username
	teamRole
	avatarUrl
	countFollowers
	countFollowing
	profileContentMd
	socialDiscord
	socialGuilded
	socialYoutube
	socialInstagram
	socials {
		platform
		username
	}
  }
}
''';

const String getUser = r'''
query GetUser($username: String!) {
  user(username: $username) {
    id
    username
	teamRole
	avatarUrl
	countFollowers
	countFollowing
	profileContentMd
	socialDiscord
	socialGuilded
	socialYoutube
	socialInstagram
	socials {
		platform
		username
	}
  }
}
''';
