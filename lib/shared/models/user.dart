part of 'models.dart';

/// Author of a thread.
///
/// Contains name and user page url.
@MappableClass()
class User with UserMappable {
  /// Constructor.
  const User({required this.name, required this.url, this.uid, this.avatarUrl});

  /// User name.
  final String name;

  /// User homepage url.
  final String url;

  /// User id.
  ///
  /// For somewhere we can not get user id, this can not be "required".
  final String? uid;

  /// User avatar, may be null.
  final String? avatarUrl;

  /// Check is valid user or not.
  bool isValid() {
    if (name.isEmpty || url.isEmpty) {
      return false;
    }
    return true;
  }

  /// Check is invalid user or not.
  bool isNotValid() => !isValid();
}
