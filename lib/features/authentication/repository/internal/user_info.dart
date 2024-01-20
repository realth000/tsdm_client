/// User info used in repo.
class UserInfo {
  const UserInfo({required this.uid, required this.username});

  final String uid;
  final String username;

  @override
  String toString() {
    return 'UserInfo { uid=$uid, username=$username }';
  }
}
