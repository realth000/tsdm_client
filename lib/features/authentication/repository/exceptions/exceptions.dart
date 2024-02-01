/// Basic exception class of login
sealed class LoginException implements Exception {}

/// The form hash used in login progress is not found.
final class LoginFormHashNotFoundException implements LoginException {}

/// Found form hash, but it's not in the expect format.
final class LoginInvalidFormHashException implements LoginException {}

/// The login result message of login progress is not found.
///
/// Indicating that we do not know whether we logged in successful or not.
final class LoginMessageNotFoundException implements LoginException {}

/// The captcha user texted is incorrect.
final class LoginIncorrectCaptchaException implements LoginException {}

/// Incorrect password or account.
final class LoginInvalidCredentialException implements LoginException {}

/// Security question or its answer is incorrect.
final class LoginIncorrectSecurityQuestionException implements LoginException {}

/// Reached the limit of login attempt.
///
/// Maybe locked in 20 minutes.
final class LoginAttemptLimitException implements LoginException {}

/// User info not found when try to login after login seems success.
///
/// Now we should update the logged user info but this exception means we can
/// not found the logged user info.
final class LoginUserInfoNotFoundException implements LoginException {}

/// Some other exception that not recognized.
final class LoginOtherErrorException implements LoginException {
  /// Constructor.
  LoginOtherErrorException(this.message);

  /// Message to describe the error.
  final String message;
}

/// Basic exception class of logout.
sealed class LogoutException implements Exception {}

/// The form hash used to logout is not found.
final class LogoutFormHashNotFoundException implements LogoutException {}

/// Failed to logout.
///
/// Nearly impossible to happen.
final class LogoutFailedException implements LogoutException {}
