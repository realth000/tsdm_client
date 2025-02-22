part of 'models.dart';

/// An item, or call it an action, in the thread operation changelog.
@MappableClass()
final class OperationLogItem with OperationLogItemMappable {
  /// Constructor.
  const OperationLogItem({required this.username, required this.action, required this.time, required this.duration});

  /// Build an instance from a list of td node.
  static OperationLogItem? fromTr(uh.Element element) {
    final tds = element.querySelectorAll('td');
    if (tds.length != 4) {
      return null;
    }

    final username = element.querySelector('a')?.innerText;
    final time = tds[1].innerText.parseToDateTimeUtc8();
    final action = tds[2].innerText;
    String? duration = tds[3].innerText;
    if (duration.isEmpty) {
      duration = null;
    }

    if (username == null || time == null) {
      return null;
    }

    return OperationLogItem(username: username, time: time, action: action, duration: duration);
  }

  /// User launched the action.
  final String username;

  /// Action description.
  final String action;

  /// When happened.
  final DateTime time;

  /// The action effect duration may be null.
  final String? duration;
}
