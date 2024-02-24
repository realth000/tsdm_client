part of 'models.dart';

/// Authenticated user.
///
/// [username], [uid] and [email] should have the same priority in identifying
/// the user.
///
/// * Though we may not know the all info above when trying to login.
/// * All the info above MUST be provided before save logged info info local
///   storage.
@MappableClass()
class User with UserMappable {
  /// Constructor.
  const User({
    this.username,
    this.uid,
    this.password,
    this.email,
  });

  /// Username.
  final String? username;

  /// Uid.
  final String? uid;

  /// Password.
  ///
  /// Never save this to local store.
  final String? password;

  /// Email address.
  final String? email;
}
