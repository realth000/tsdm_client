part of 'models.dart';

/// User info used in login progress.
///
/// Before or during login, we may not have complete user info:
///
/// * Username
/// * Uid
/// * Email
///
/// Use this model to store that state.
@MappableClass()
final class UserLoginInfo with UserLoginInfoMappable {
  /// Constructor.
  const UserLoginInfo({
    required this.username,
    required this.uid,
    required this.email,
  });

  /// Username.
  final String? username;

  /// User id.
  final int? uid;

  /// User email.
  final String? email;

  /// Check if info is completed.
  bool get isComplete => username != null && uid != null && email != null;
}
