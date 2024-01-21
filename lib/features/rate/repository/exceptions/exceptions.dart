class RateFailedException implements Exception {
  const RateFailedException(this.reason);

  final String reason;

  @override
  String toString() => 'RateFailedException: $reason';
}

/// Result of fetching rate window info.
sealed class RateInfoException implements Exception {
  const RateInfoException._();
}

final class RateInfoWaiting extends RateInfoException {
  const RateInfoWaiting() : super._();
}

/// Http request error in fetching rate window info.
final class RateInfoBadHttpResp extends RateInfoException {
  const RateInfoBadHttpResp(this.code) : super._();

  final String code;

  @override
  String toString() => 'RateFetchInfoBadHttpResp { code=$code }';
}

/// Html info content not found in response.
/// This is not the "404 NOT FOUND".
final class RateInfoNotFound extends RateInfoException {
  const RateInfoNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoNotFound';
}

final class RateInfoHtmlBodyNotFound extends RateInfoException {
  const RateInfoHtmlBodyNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoHtmlBodyNotFound';
}

final class RateInfoDivCNodeNotFound extends RateInfoException {
  const RateInfoDivCNodeNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoDivCNodeNotFound';
}

final class RateInfoInvalidDivCNode extends RateInfoException {
  const RateInfoInvalidDivCNode() : super._();

  @override
  String toString() => 'RateFetchInfoInvalidCNode';
}
