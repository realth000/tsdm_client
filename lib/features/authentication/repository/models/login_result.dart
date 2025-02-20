part of 'models.dart';

/// Extra info when login.
@MappableClass()
final class LoginValue with LoginValueMappable {
  /// Constructor.
  const LoginValue({this.username, this.userGroup, this.uid});

  /// username
  final String? username;

  /// User group.
  @MappableField(key: 'usergroup')
  final String? userGroup;

  /// User id.
  final String? uid;
}

/// Extra info when login.
///
/// Not as important as [LoginValue].
@MappableClass()
final class LoginExtra with LoginExtraMappable {
  /// Constructor.
  const LoginExtra({this.showDialog, this.locationTime, this.extraJs});

  /// Value is "1"
  @MappableField(key: 'showdialog')
  final String? showDialog;

  /// Value is "1"
  @MappableField(key: 'locationtime')
  final String? locationTime;

  /// Value is empty.
  @MappableField(key: 'extrajs')
  final String? extraJs;
}

/// Login request result
@MappableClass()
final class LoginResult with LoginResultMappable {
  /// Constructor.
  const LoginResult({required this.status, required this.message, required this.values, this.extra});

  /// Message means login success.
  static const messageSuccess = 'location_login_succeed_mobile';

  /// Message means incorrect username or password.
  static const messageLoginInvalid = 'login_invalid';

  /// Message means incorrect captcha answer in challenge.
  static const messageCaptchaError = 'err_login_captcha_invalid';

  /// Login result status.
  ///
  /// Zero values means login succeeded.
  final int status;

  /// Extra message for login status.
  ///
  /// May be message:
  ///
  /// * [messageSuccess]
  /// * [messageLoginInvalid]
  /// * [messageCaptchaError]
  /// * Other status.
  final String message;

  /// Extra info
  final LoginExtra? extra;

  /// Extra info including user info.
  final LoginValue? values;
}
