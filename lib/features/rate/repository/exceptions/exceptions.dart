/// Basic exception classs of rate.
class RateFailedException implements Exception {
  /// Constructor.
  const RateFailedException(this.reason);

  /// Failed reason stirng.
  final String reason;

  @override
  String toString() => 'RateFailedException: $reason';
}

/// Result of fetching rate window info.
sealed class RateInfoException implements Exception {
  const RateInfoException._();
}

/// Html info content not found in response.
/// This is not the "404 NOT FOUND".
final class RateInfoNotFound extends RateInfoException {
  /// Constructor.
  const RateInfoNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoNotFound';
}

/// The html body should contains the rate info is missing
/// in the response.
final class RateInfoHtmlBodyNotFound extends RateInfoException {
  /// Constructor.
  const RateInfoHtmlBodyNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoHtmlBodyNotFound';
}

/// Rate info html body is missing.
final class RateInfoDivCNodeNotFound extends RateInfoException {
  /// Constructor.
  const RateInfoDivCNodeNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoDivCNodeNotFound';
}

/// Rate window info body not found and error text not found.
///
/// This is a fallback exception after [RateInfoWithErrorException].
/// Because we encountered an error and no error text found.
final class RateInfoInvalidDivCNode extends RateInfoException {
  /// Constructor.
  const RateInfoInvalidDivCNode() : super._();

  @override
  String toString() => 'RateFetchInfoInvalidCNode';
}

/// Rate failed but luckily we found the error text in response.
final class RateInfoWithErrorException extends RateInfoException {
  /// Constructor.
  const RateInfoWithErrorException(this.message) : super._();

  /// Error text from the server side.
  final String message;
}
