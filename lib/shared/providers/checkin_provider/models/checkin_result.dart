/// Basic checkin result.
sealed class CheckinResult {
  /// Constructor.
  const CheckinResult();
}

/// Succeed.
final class CheckinSuccess extends CheckinResult {
  /// Constructor.
  const CheckinSuccess(this.message) : super();

  /// Message carried.
  final String message;
}

/// User is not authorized.
final class CheckinNotAuthorized extends CheckinResult {
  /// Constructor.
  const CheckinNotAuthorized() : super();
}

/// Failed to make the checkin web request.
final class CheckinWebRequestFailed extends CheckinResult {
  /// Constructor.
  const CheckinWebRequestFailed(this.statusCode) : super();

  /// Response status code.
  final int? statusCode;
}

/// Form hash used in checkin request is not found.
final class CheckinFormHashNotFound extends CheckinResult {
  /// Constructor.
  const CheckinFormHashNotFound() : super();
}

/// Already checked today.
final class CheckinAlreadyChecked extends CheckinResult {
  /// Constructor.
  const CheckinAlreadyChecked() : super();
}

/// Not in the allowed checkin time: too early
final class CheckinEarlyInTime extends CheckinResult {
  /// Constructor.
  const CheckinEarlyInTime() : super();
}

/// Not in the allowed checkin time: too late
final class CheckinLateInTime extends CheckinResult {
  /// Constructor.
  const CheckinLateInTime() : super();
}

/// Some other error that not specialized.
final class CheckinOtherError extends CheckinResult {
  /// Constructor.
  const CheckinOtherError(this.message) : super();

  /// Error message.
  final String message;
}
