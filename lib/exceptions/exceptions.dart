import 'dart:async';
import 'dart:io' if (dart.library.js) 'package:web/web.dart';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/shared/models/models.dart';

part 'exceptions.mapper.dart';

/// App wide wrapped exception
typedef SyncEither<T> = Either<AppException, T>;

/// App wide wrapped exception for future.
typedef AsyncEither<T> = TaskEither<AppException, T>;

/// App wide wrapped exception with void as value.
typedef SyncVoidEither = Either<AppException, void>;

/// App wide wrapped exception for future with void as value.
typedef AsyncVoidEither = TaskEither<AppException, void>;

/// App wide wrapped async result that never fails.
typedef VoidTask = Task<void>;

/// App wide wrapped left builder for [TaskEither].
TaskEither<L, R> taskLeft<L, R>(L l) => TaskEither<L, R>.left(l);

/// App wide wrapped right builder for [TaskEither].
TaskEither<L, R> taskRight<L, R>(R r) => TaskEither<L, R>.right(r);

/// Convenient `right(null)`
Either<L, void> rightVoid<L>() => Right<L, void>(null);

/// Functional programming operators on [AsyncEither] with generic type [T].
extension FPFutureExt<T> on AsyncEither<T> {
  /// Await and handle result.
  Future<void> handle(FutureOr<void> Function(AppException e) onLeft, FutureOr<void> Function(T v) onRight) async {
    switch (await run()) {
      case Left(:final value):
        onLeft(value);
      case Right(:final value):
        onRight(value);
    }
  }
}

/// Map http request result.
extension FPHttpExt on AsyncEither<Response<dynamic>> {
  /// * Return error if any.
  /// * Return `HttpRequestFailedException` when status code is not 200.
  /// * Return result called on [onOk] when ok.
  AsyncEither<T> mapHttp<T>(T Function(Response<dynamic> resp) onOk) => AsyncEither(
    () async => switch (await run()) {
      Left(:final value) => left(value),
      Right(:final value) when value.statusCode != HttpStatus.ok => left(HttpRequestFailedException(value.statusCode)),
      Right(:final value) => right(onOk(value)),
    },
  );

  /// * Return error if any.
  /// * Return `HttpRequestFailedException` when status code is not 200.
  /// * Return result called on [onOk] when ok.
  AsyncEither<T> andThenHttp<T>(AsyncEither<T> Function(Response<dynamic> resp) onOk) => AsyncEither(
    () async => switch (await run()) {
      Left(:final value) => left(value),
      Right(:final value) when value.statusCode != HttpStatus.ok => left(HttpRequestFailedException(value.statusCode)),
      Right(:final value) => await onOk(value).run(),
    },
  );
}

/// Base class for all exceptions.
@MappableClass()
sealed class AppException with AppExceptionMappable implements Exception {
  AppException({this.message}) : stackTrace = StackTrace.current;

  /// Message to print
  final String? message;

  /// Collected stack trace.
  late final StackTrace stackTrace;
}

/// Exception represents an error occurred in http request.
///
/// Usually the response status code is not 200.
@MappableClass()
final class HttpRequestFailedException extends AppException with HttpRequestFailedExceptionMappable {
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
final class HttpHandshakeFailedException extends AppException with HttpHandshakeFailedExceptionMappable {
  /// Constructor.
  HttpHandshakeFailedException(String message, {this.statusCode, this.headers}) : super(message: message);

  /// Optional status code.
  final int? statusCode;

  /// Optional response headers.
  final Headers? headers;
}

/// The form hash used in login progress is not found.
@MappableClass()
final class LoginFormHashNotFoundException extends AppException with LoginFormHashNotFoundExceptionMappable {}

/// Found form hash, but it's not in the expect format.
@MappableClass()
final class LoginInvalidFormHashException extends AppException with LoginInvalidFormHashExceptionMappable {}

/// The login result message of login progress is not found.
///
/// Indicating that we do not know whether we logged in successful or not.
@MappableClass()
final class LoginMessageNotFoundException extends AppException with LoginMessageNotFoundExceptionMappable {}

/// The captcha user texted is incorrect.
@MappableClass()
final class LoginIncorrectCaptchaException extends AppException with LoginIncorrectCaptchaExceptionMappable {}

/// Incorrect password or account.
@MappableClass()
final class LoginInvalidCredentialException extends AppException with LoginInvalidCredentialExceptionMappable {}

/// Security question or its answer is incorrect.
@MappableClass()
final class LoginIncorrectSecurityQuestionException extends AppException
    with LoginIncorrectSecurityQuestionExceptionMappable {}

/// Reached the limit of login attempt.
///
/// Maybe locked in 20 minutes.
@MappableClass()
final class LoginAttemptLimitException extends AppException with LoginAttemptLimitExceptionMappable {}

/// User info not found when try to login after login seems success.
///
/// Now we should update the logged user info but this exception means we can
/// not found the logged user info.
@MappableClass()
final class LoginUserInfoNotFoundException extends AppException with LoginUserInfoNotFoundExceptionMappable {}

/// Some other exception that not recognized.
@MappableClass()
final class LoginOtherErrorException extends AppException with LoginOtherErrorExceptionMappable {
  /// Constructor.
  LoginOtherErrorException(String message) : super(message: message);
}

/// Incomplete user info parsed from html document in login progress.
///
/// This means either an unexpected html doc change, or not authorized.
@MappableClass()
final class LoginUserInfoIncompleteException extends AppException with LoginUserInfoIncompleteExceptionMappable {}

/// Failed to switch to user.
@MappableClass()
final class SwitchUserNotAuthedException extends AppException with SwitchUserNotAuthedExceptionMappable {}

/// The form hash used to logout is not found.
@MappableClass()
final class LogoutFormHashNotFoundException extends AppException with LogoutFormHashNotFoundExceptionMappable {}

/// Failed to logout.
///
/// Nearly impossible to happen.
@MappableClass()
final class LogoutFailedException extends AppException with LogoutFailedExceptionMappable {}

/// Document contains chat data not found.
@MappableClass()
final class ChatDataDocumentNotFoundException extends AppException with ChatDataDocumentNotFoundExceptionMappable {}

/// Failed to load emoji
@MappableClass()
final class EmojiLoadFailedException extends AppException with EmojiLoadFailedExceptionMappable {}

/// Failed to upload edit result.
@MappableClass()
final class PostEditFailedToUploadResult extends AppException with PostEditFailedToUploadResultMappable {
  /// Constructor.
  PostEditFailedToUploadResult(this.errorText);

  /// Html element contains the error message.
  final String errorText;
}

/// Failed to parse purchase info because the parameter in
/// confirm info is incorrect.
@MappableClass()
final class PurchaseInfoInvalidParameterCountException extends AppException
    with PurchaseInfoInvalidParameterCountExceptionMappable {}

/// Confirm info is incomplete.
@MappableClass()
final class PurchaseInfoIncompleteException extends AppException with PurchaseInfoIncompleteExceptionMappable {}

/// Some info that need to display in the confirm process is invalid.
///
/// Maybe invalid username or uid.
@MappableClass()
final class PurchaseInfoInvalidNoticeException extends AppException with PurchaseInfoInvalidNoticeExceptionMappable {}

/// Failed to do the purchase action.
@MappableClass()
final class PurchaseActionFailedException extends AppException with PurchaseActionFailedExceptionMappable {}

/// Basic exception class of rate.
@MappableClass()
class RateFailedException extends AppException with RateFailedExceptionMappable {
  /// Constructor.
  RateFailedException(this.reason);

  /// Failed reason string.
  final String reason;
}

/// Result of fetching rate window info.
@MappableClass()
sealed class RateInfoException extends AppException with RateInfoExceptionMappable {
  RateInfoException();
}

/// Html info content not found in response.
/// This is not the "404 NOT FOUND".
@MappableClass()
final class RateInfoNotFound extends AppException with RateInfoNotFoundMappable {
  /// Constructor.
  RateInfoNotFound();
}

/// The html body should contains the rate info is missing
/// in the response.
@MappableClass()
final class RateInfoHtmlBodyNotFound extends AppException with RateInfoHtmlBodyNotFoundMappable {
  /// Constructor.
  RateInfoHtmlBodyNotFound();
}

/// Rate info html body is missing.
@MappableClass()
final class RateInfoDivCNodeNotFound extends AppException with RateInfoDivCNodeNotFoundMappable {
  /// Constructor.
  RateInfoDivCNodeNotFound();
}

/// Rate window info body not found and error text not found.
///
/// This is a fallback exception after [RateInfoWithErrorException].
/// Because we encountered an error and no error text found.
@MappableClass()
final class RateInfoInvalidDivCNode extends AppException with RateInfoInvalidDivCNodeMappable {
  /// Constructor.
  RateInfoInvalidDivCNode();
}

/// Rate failed but luckily we found the error text in response.
@MappableClass()
final class RateInfoWithErrorException extends AppException with RateInfoWithErrorExceptionMappable {
  /// Constructor.
  RateInfoWithErrorException(String message) : super(message: message);
}

/// Need to login when trying to fetch profile page.
///
/// Used in profile feature.
@MappableClass()
final class ProfileNeedLoginException extends AppException with ProfileNeedLoginExceptionMappable {
  /// Constructor.
  ProfileNeedLoginException();
}

/// Status field not found in profile response.
@MappableClass()
final class ProfileStatusNotFoundException extends AppException with ProfileStatusNotFoundExceptionMappable {
  /// Constructor.
  ProfileStatusNotFoundException();
}

/// Status field is unrecognized in profile response.
@MappableClass()
final class ProfileStatusUnknownException extends AppException with ProfileStatusUnknownExceptionMappable {
  /// Constructor.
  ProfileStatusUnknownException(this.status);

  /// The unrecognized status message.
  final String status;
}

/// Failed to fetch parameters used in replying to a post.
@MappableClass()
class ReplyToPostFetchParameterFailedException extends AppException
    with ReplyToPostFetchParameterFailedExceptionMappable {}

/// Reply to a post, but no successful result found in response.
@MappableClass()
class ReplyToPostResultFailedException extends AppException with ReplyToPostResultFailedExceptionMappable {}

/// Reply to thread, but no successful result found in response.
@MappableClass()
class ReplyToThreadResultFailedException extends AppException with ReplyToThreadResultFailedExceptionMappable {}

/// Reply personal message, but failed in response.
@MappableClass()
class ReplyPersonalMessageFailedException extends AppException with ReplyPersonalMessageFailedExceptionMappable {
  /// Constructor.
  ReplyPersonalMessageFailedException(String message) : super(message: message);
}

/// Failed to publish a thread.
///
/// Server returned unexpected status code.
@MappableClass()
final class ThreadPublishFailedException extends AppException with ThreadPublishFailedExceptionMappable {
  /// Constructor.
  ThreadPublishFailedException(this.code, {super.message});

  /// Unexpected http status code.
  final int code;
}

/// Thread published, but the redirect location of published thread page
/// is not found in the response header.
@MappableClass()
final class ThreadPublishLocationNotFoundException extends AppException
    with ThreadPublishLocationNotFoundExceptionMappable {}

/// User not found when trying to operate on that user's notification.
@MappableClass()
final class NotificationUserNotFound extends AppException with NotificationUserNotFoundMappable {}

/// Notification not found in bloc.
@MappableClass()
final class NotificationNotFound extends AppException with NotificationNotFoundMappable {}

/// Cookie not found in storage when doing auto checkin for user [userInfo].
///
/// Means a checkin failure.
@MappableClass()
final class AutoCheckinCookieNotFound extends AppException with AutoCheckinCookieNotFoundMappable {
  /// Constructor.
  AutoCheckinCookieNotFound(this.userInfo);

  /// Whos cookie not found.
  final UserLoginInfo userInfo;
}

/// Invalid response in an image upload action.
///
/// The response data can not be parsed as known data.
@MappableClass()
final class ImageUploadInvalidResponse extends AppException with ImageUploadInvalidResponseMappable {}

/// Failed to upload image.
///
/// Unlike [ImageUploadInvalidResponse], the response data is successfully
/// parsed to known format, but the message carried indicates an error.
@MappableClass()
final class ImageUploadFailed extends AppException with ImageUploadFailedMappable {
  /// Constructor.
  ImageUploadFailed(String message) : super(message: message);
}

/// Failed to parse packet detail table
@MappableClass()
final class PacketDetailParseFailed extends AppException with PacketDetailParseFailedMappable {
  // Super not const.
  // ignore: prefer_const_constructor_declarations
  /// Constructor.
  PacketDetailParseFailed(this.tid, String message) : super(message: message);

  /// Thread id.
  final int tid;
}

/// Server responded an error, likely the client side sent an invalid request.
@MappableClass()
final class ServerRespFailure extends AppException with ServerRespFailureMappable {
  // Super not const.
  // ignore: prefer_const_constructor_declarations
  /// Constructor.
  ServerRespFailure({required this.status, required super.message});

  /// Non zero status code.
  final int? status;
}

/// Failed to do the switch user group action.
@MappableClass()
final class SwitchUserGroupFailed extends AppException with SwitchUserGroupFailedMappable {
  /// Constructor.
  SwitchUserGroupFailed(String message) : super(message: message);
}

/// Failed to find the avatar url.
@MappableClass()
final class EditAvatarUrlNotFound extends AppException with EditAvatarUrlNotFoundMappable {
  /// Constructor.
  EditAvatarUrlNotFound() : super(message: 'avatar url not found');
}
