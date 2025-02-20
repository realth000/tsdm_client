part of 'models.dart';

/// Basic checkin result.
@MappableClass()
sealed class CheckinResult with CheckinResultMappable {
  /// Constructor.
  const CheckinResult();

  /// Parse to text message.
  static String message(BuildContext context, CheckinResult result) {
    final tr = context.t.profilePage.checkin;
    return switch (result) {
      CheckinResultSuccess() => tr.success(msg: result.message),
      CheckinResultNotAuthorized() => tr.failedNotAuthorized,
      CheckinResultWebRequestFailed() => tr.failedNotAuthorized,
      CheckinResultFormHashNotFound() => tr.failedFormHashNotFound,
      CheckinResultAlreadyChecked() => tr.failedAlreadyCheckedIn,
      CheckinResultEarlyInTime() => tr.failedEarlyInTime,
      CheckinResultLateInTime() => tr.failedLateInTime,
      CheckinResultOtherError() => tr.failedOtherError(err: result.message),
    };
  }
}

/// Succeed.
@MappableClass()
final class CheckinResultSuccess extends CheckinResult with CheckinResultSuccessMappable {
  /// Constructor.
  const CheckinResultSuccess(this.message) : super();

  /// Message carried.
  final String message;
}

/// User is not authorized.
@MappableClass()
final class CheckinResultNotAuthorized extends CheckinResult with CheckinResultNotAuthorizedMappable {
  /// Constructor.
  const CheckinResultNotAuthorized() : super();
}

/// Failed to make the checkin web request.
@MappableClass()
final class CheckinResultWebRequestFailed extends CheckinResult with CheckinResultWebRequestFailedMappable {
  /// Constructor.
  const CheckinResultWebRequestFailed(this.statusCode) : super();

  /// Response status code.
  final int? statusCode;
}

/// Form hash used in checkin request is not found.
@MappableClass()
final class CheckinResultFormHashNotFound extends CheckinResult with CheckinResultFormHashNotFoundMappable {
  /// Constructor.
  const CheckinResultFormHashNotFound() : super();
}

/// Already checked today.
@MappableClass()
final class CheckinResultAlreadyChecked extends CheckinResult with CheckinResultAlreadyCheckedMappable {
  /// Constructor.
  const CheckinResultAlreadyChecked() : super();
}

/// Not in the allowed checkin time: too early
@MappableClass()
final class CheckinResultEarlyInTime extends CheckinResult with CheckinResultEarlyInTimeMappable {
  /// Constructor.
  const CheckinResultEarlyInTime() : super();
}

/// Not in the allowed checkin time: too late
@MappableClass()
final class CheckinResultLateInTime extends CheckinResult with CheckinResultLateInTimeMappable {
  /// Constructor.
  const CheckinResultLateInTime() : super();
}

/// Some other error that not specialized.
@MappableClass()
final class CheckinResultOtherError extends CheckinResult with CheckinResultOtherErrorMappable {
  /// Constructor.
  const CheckinResultOtherError(this.message) : super();

  /// Error message.
  final String message;
}
