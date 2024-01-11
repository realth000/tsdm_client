class HttpRequestFailedException implements Exception {
  const HttpRequestFailedException(this.statusCode);

  final int statusCode;
}

class HttpHandshakeFailedException implements Exception {
  const HttpHandshakeFailedException(this.message);

  final String message;
}
