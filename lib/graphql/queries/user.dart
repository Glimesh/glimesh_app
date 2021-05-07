const String getMyself = r'''
query GetMyself {
  myself {
    id
    username
  }
}
''';

const String getUser = r'''
query GetUser($userId: ID!) {
  user(id: $userId) {
    id
    username
  }
}
''';
