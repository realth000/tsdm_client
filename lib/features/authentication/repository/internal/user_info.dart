/// User info used in repo.
class UserInfo {
  /// Constructor.
  const UserInfo({required this.uid, required this.username});

  /// User id.
  final String uid;

  /// User name.
  final String username;

  @override
  String toString() {
    return 'UserInfo { uid=$uid, username=$username }';
  }
}
