import 'dart:async';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';

part 'exceptions.mapper.dart';

/// App wide wrapped exception
typedef SyncEither<T> = Either<AppException, T>;

/// App wide wrapped exception for future.
typedef AsyncEither<T> = TaskEither<AppException, T>;

/// App wide wrapped exception with void as value.
typedef SyncVoidEither = Either<AppException, void>;

/// App wide wrapped exception for future with void as value.
typedef AsyncVoidEither = TaskEither<AppException, void>;

/// Convenient `right(null)`
Either<L, void> rightVoid<L>() => Right<L, void>(null);

/// Functional programming operators on [AsyncEither] with generic type [T].
extension FPFutureExt<T> on AsyncEither<T> {
  /// Await and handle result.
  Future<void> handle(
    FutureOr<void> Function(AppException e) onLeft,
    FutureOr<void> Function(T v) onRight,
  ) async {
    switch (await run()) {
      case Left(:final value):
        onLeft(value);
      case Right(:final value):
        onRight(value);
    }
  }
}

/// Base class for all exceptions.
@MappableClass()
sealed class AppException with AppExceptionMappable implements Exception {
  AppException({
    this.message,
  }) : stackTrace = StackTrace.current;

  /// Message to print
  final String? message;

  /// Collected stack trace.
  late final StackTrace stackTrace;
}

/// Exception represents an error occurred in http request.
///
/// Usually the response status code is not 200.
@MappableClass()
final class HttpRequestFailedException extends AppException
    with HttpRequestFailedExceptionMappable {
  /// Constructor.
  HttpRequestFailedException(this.statusCode);

  /// Returned status code.
  final int? statusCode;
}

/// Exception represents that the SSL handshake process is terminated
/// abnormally.
///
/// This may happen in some bad network environment.
///
/// Till now we manually set the status code to 999 to indicate this error, but
/// it should be refactored to a more proper way.
@MappableClass()
final class HttpHandshakeFailedException extends AppException
    with HttpHandshakeFailedExceptionMappable {
  /// Constructor.
  HttpHandshakeFailedException(String message) : super(message: message);
}

/// The form hash used in login progress is not found.
@MappableClass()
final class LoginFormHashNotFoundException extends AppException
    with LoginFormHashNotFoundExceptionMappable {}

/// Found form hash, but it's not in the expect format.
@MappableClass()
final class LoginInvalidFormHashException extends AppException
    with LoginInvalidFormHashExceptionMappable {}

/// The login result message of login progress is not found.
///
/// Indicating that we do not know whether we logged in successful or not.
@MappableClass()
final class LoginMessageNotFoundException extends AppException
    with LoginMessageNotFoundExceptionMappable {}

/// The captcha user texted is incorrect.
@MappableClass()
final class LoginIncorrectCaptchaException extends AppException
    with LoginIncorrectCaptchaExceptionMappable {}

/// Incorrect password or account.
@MappableClass()
final class LoginInvalidCredentialException extends AppException
    with LoginInvalidCredentialExceptionMappable {}

/// Security question or its answer is incorrect.
@MappableClass()
final class LoginIncorrectSecurityQuestionException extends AppException
    with LoginIncorrectSecurityQuestionExceptionMappable {}

/// Reached the limit of login attempt.
///
/// Maybe locked in 20 minutes.
@MappableClass()
final class LoginAttemptLimitException extends AppException
    with LoginAttemptLimitExceptionMappable {}

/// User info not found when try to login after login seems success.
///
/// Now we should update the logged user info but this exception means we can
/// not found the logged user info.
@MappableClass()
final class LoginUserInfoNotFoundException extends AppException
    with LoginUserInfoNotFoundExceptionMappable {}

/// Some other exception that not recognized.
@MappableClass()
final class LoginOtherErrorException extends AppException
    with LoginOtherErrorExceptionMappable {
  /// Constructor.
  LoginOtherErrorException(String message) : super(message: message);
}

/// The form hash used to logout is not found.
@MappableClass()
final class LogoutFormHashNotFoundException extends AppException
    with LogoutFormHashNotFoundExceptionMappable {}

/// Failed to logout.
///
/// Nearly impossible to happen.
@MappableClass()
final class LogoutFailedException extends AppException
    with LogoutFailedExceptionMappable {}

/// Document contains chat data not found.
@MappableClass()
final class ChatDataDocumentNotFoundException extends AppException
    with ChatDataDocumentNotFoundExceptionMappable {}

/// Failed to load emoji
@MappableClass()
final class EmojiLoadFailedException extends AppException
    with EmojiLoadFailedExceptionMappable {}
