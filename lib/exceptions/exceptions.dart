/// Exception represents an error occurred in http request.
///
/// Usually the response status code is not 200.
class HttpRequestFailedException implements Exception {
  /// Constructor.
  const HttpRequestFailedException(this.statusCode);

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
class HttpHandshakeFailedException implements Exception {
  /// Constructor.
  const HttpHandshakeFailedException(this.message);

  /// Error message.
  final String message;
}

/// Invalid settings's key (aka name) when accessing settings values:
/// setting values or getting values.
class InvalidSettingsKeyException implements Exception {
  /// Constructor.
  const InvalidSettingsKeyException(this.message);

  /// Error message.
  final String message;
}
