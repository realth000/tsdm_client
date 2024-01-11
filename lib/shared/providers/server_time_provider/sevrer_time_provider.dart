import 'package:tsdm_client/extensions/string.dart';
import 'package:universal_html/html.dart' as uh;

/// Provider used to save the server time.
///
/// This provider exists because the server side has some time gap:
/// Time is newer than standard time.
class ServerTimeProvider {
  ServerTimeProvider({DateTime? serverDatetime})
      : _serverDatetime = serverDatetime ?? DateTime.now();

  DateTime get time => _serverDatetime;

  DateTime _serverDatetime;

  /// Parse and save server [DateTime] from html [document].
  ///
  /// Will not update server time if no time found in document.
  /// Instead of updating [DateTime.now], do nothing ensures the negative times are never known.
  DateTime updateServerTimeWithDocument(uh.Document document) {
    final parsedTime = document
        .querySelector('p.xs0')
        ?.childNodes
        .elementAtOrNull(0)
        ?.text
        ?.split(',')
        .lastOrNull
        ?.trim()
        .parseToDateTimeUtc8();
    if (parsedTime != null) {
      _serverDatetime = parsedTime;
    }

    return _serverDatetime;
  }
}
