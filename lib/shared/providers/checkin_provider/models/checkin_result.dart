sealed class CheckinResult {
  const CheckinResult();
}

final class CheckinSuccess extends CheckinResult {
  const CheckinSuccess(this.message) : super();

  final String message;
}

final class CheckinNotAuthorized extends CheckinResult {
  const CheckinNotAuthorized() : super();
}

final class CheckinWebRequestFailed extends CheckinResult {
  const CheckinWebRequestFailed(this.statusCode) : super();

  final int statusCode;
}

final class CheckinFormHashNotFound extends CheckinResult {
  const CheckinFormHashNotFound() : super();
}

final class CheckinAlreadyChecked extends CheckinResult {
  const CheckinAlreadyChecked() : super();
}

final class CheckinEarlyInTime extends CheckinResult {
  const CheckinEarlyInTime() : super();
}

final class CheckinLateInTime extends CheckinResult {
  const CheckinLateInTime() : super();
}

final class CheckinOtherError extends CheckinResult {
  const CheckinOtherError(this.message) : super();

  final String message;
}
