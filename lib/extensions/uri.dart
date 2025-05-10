import 'package:tsdm_client/instance.dart';

/// Extension methods on [Uri].
extension UriExt on Uri? {
  /// Get query parameters in [Uri] safely.
  ///
  /// Return null if any exception thrown in process, log an error if so.
  Map<String, String>? tryGetQueryParameters() {
    try {
      // Insane getter throwing exception.
      return this?.queryParameters;
    } on Exception catch (e, st) {
      talker.handle(e, st, 'failed to get query parameter from Uri "$this"');
      return null;
    }
  }
}
