/// Global instance class for saving network inner errors for
/// later error handling.
///
/// MUST only used by error handler in http client (for save) and ui shows
/// network error (for load).
class NetErrorSaver {
  ///  Reserved error;
  String? _error;

  /// Clear current saved error;
  void clear() => _error = null;

  /// Get error
  String? error() => _error;

  /// Save error.
  // ignore: use_setters_to_change_properties
  void save(String? error) => _error = error;
}
