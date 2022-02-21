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

const String isFollowing = r'''
query IsFollowing($streamerId: ID!, $userId: ID!) {
  followers(streamerId: $streamerId, userId: $userId, first: 1) {
    count
  } 
}
''';
const String followUser = r'''
mutation FollowUser($streamerId: ID!, $liveNotifications: Boolean) {
  follow(streamerId: $streamerId, liveNotifications: $liveNotifications) {
    id
    hasLiveNotifications
  } 
}
''';
const String unfollowUser = r'''
mutation UnfollowUser($streamerId: ID!) {
  unfollow(streamerId: $streamerId) {
    id
  } 
}
''';
