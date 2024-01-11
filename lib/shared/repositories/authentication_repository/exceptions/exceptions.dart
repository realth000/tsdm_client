sealed class LoginException implements Exception {}

final class LoginMessageNotFoundException implements LoginException {}

final class LoginIncorrectCaptchaException implements LoginException {}

final class LoginInvalidCredentialException implements LoginException {}

final class LoginIncorrectSecurityQuestionException implements LoginException {}

final class LoginAttemptLimitException implements LoginException {}

final class LoginUserInfoNotFoundException implements LoginException {}

final class LoginOtherErrorException implements LoginException {
  LoginOtherErrorException(this.message);

  final String message;
}

sealed class LogoutException implements Exception {}

final class LogoutFormHashNotFoundException implements LogoutException {}

final class LogoutFailedException implements LogoutException {}
