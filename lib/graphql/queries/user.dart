const String getMyself = r'''
query GetMyself {
  myself {
    id
    username
  }
}
''';

const String getUser = r'''
query GetUser($username: String!) {
  user(username: $username) {
    id
    username
  }
}
''';
