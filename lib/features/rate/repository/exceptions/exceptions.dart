import 'package:dart_mappable/dart_mappable.dart';

part '../../../../generated/features/rate/repository/exceptions/exceptions.mapper.dart';

/// Basic exception class of rate.
@MappableClass()
class RateFailedException
    with RateFailedExceptionMappable
    implements Exception {
  /// Constructor.
  const RateFailedException(this.reason);

  /// Failed reason string.
  final String reason;
}

/// Result of fetching rate window info.
@MappableClass()
sealed class RateInfoException
    with RateInfoExceptionMappable
    implements Exception {
  const RateInfoException();
}

/// Html info content not found in response.
/// This is not the "404 NOT FOUND".
@MappableClass()
final class RateInfoNotFound extends RateInfoException
    with RateInfoNotFoundMappable {
  /// Constructor.
  const RateInfoNotFound() : super();
}

/// The html body should contains the rate info is missing
/// in the response.
@MappableClass()
final class RateInfoHtmlBodyNotFound extends RateInfoException
    with RateInfoHtmlBodyNotFoundMappable {
  /// Constructor.
  const RateInfoHtmlBodyNotFound() : super();
}

/// Rate info html body is missing.
@MappableClass()
final class RateInfoDivCNodeNotFound extends RateInfoException
    with RateInfoDivCNodeNotFoundMappable {
  /// Constructor.
  const RateInfoDivCNodeNotFound() : super();
}

/// Rate window info body not found and error text not found.
///
/// This is a fallback exception after [RateInfoWithErrorException].
/// Because we encountered an error and no error text found.
@MappableClass()
final class RateInfoInvalidDivCNode extends RateInfoException
    with RateInfoInvalidDivCNodeMappable {
  /// Constructor.
  const RateInfoInvalidDivCNode() : super();
}

/// Rate failed but luckily we found the error text in response.
@MappableClass()
final class RateInfoWithErrorException extends RateInfoException
    with RateInfoWithErrorExceptionMappable {
  /// Constructor.
  const RateInfoWithErrorException(this.message) : super();

  /// Error text from the server side.
  final String message;
}
