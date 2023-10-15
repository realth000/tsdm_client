// TODO: Construct from html node.
/// Author of a thread.
///
/// Contains name and user page url.
class User {
  /// Freezed constructor.
  User({
    required this.name,
    required this.url,
    this.uid,
    this.avatarUrl,
  });

  /// User name.
  String name;

  /// User homepage url.
  String url;

  /// User id.
  ///
  /// For somewhere we can not get user id, this can not be "required".
  String? uid;

  /// User avatar, may be null.
  String? avatarUrl;

  bool isValid() {
    if (name.isEmpty || url.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'User{ $name, $url, $uid, $avatarUrl }';
  }
}
