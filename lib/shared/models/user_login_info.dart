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
@MappableClass(
  generateMethods: GenerateMethods.encode |
      GenerateMethods.decode |
      GenerateMethods.copy |
      GenerateMethods.equals,
)
final class UserLoginInfo with UserLoginInfoMappable {
  /// Constructor.
  const UserLoginInfo({
    required this.username,
    required this.uid,
    // required this.email,
  });

  /// Username.
  final String? username;

  /// User id.
  final int? uid;

  // /// User email.
  // final String? email;

  /// Check if info is completed.
  bool get isComplete => username != null && uid != null /* && email != null*/;

  /// Check if all fields in user info is empty.
  ///
  /// Usually in some wrong state where we lost user info.
  bool get isEmpty => username == null && uid == null /* && email == null*/;

  @override
  String toString() {
    // Do NOT print detail.
    return 'UserLoginInfo{ '
        'username=${username?.obscured()}, '
        'uid=${uid == null ? "null" : "$uid".obscured(4)}, ';
    //'email=${email?.obscured()}}';
  }
}
