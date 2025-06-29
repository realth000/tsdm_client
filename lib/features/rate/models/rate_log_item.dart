part of 'models.dart';

/// Item in rate log.
///
/// Each item represents an atomic rate action.
@MappableClass()
final class RateLogItem with RateLogItemMappable {
  /// Constructor.
  const RateLogItem({
    required this.attrName,
    required this.attrValue,
    required this.username,
    required this.uid,
    required this.time,
    required this.reason,
  });

  /// Name of attribute.
  final String attrName;

  /// Value of attribute.
  ///
  /// Parsed into signed int value.
  final int attrValue;

  /// Name of user did the rate action.
  final String username;

  /// User id of the user did rate action.
  final String uid;

  /// Rate time.
  final DateTime time;

  /// Optional reason.
  ///
  /// We do not know if the user gave a empty reason or not, This field in source is always available.
  /// So it is not nullable.
  final String reason;
}

/// Rate log items accumulated.
///
/// In rate log, adjacent items can be accumulated to a single item, if:
///
/// 1. Items are adjacent when ordered in time, which is the order of items fetch by repository.
/// 2. User names are same.
/// 3. Have the same rate reason or have not.
@MappableClass()
final class RateLogAccumulatedItem with RateLogAccumulatedItemMappable {
  /// Constructor.
  const RateLogAccumulatedItem({
    required this.attrMap,
    required this.username,
    required this.uid,
    required this.firstRateTime,
    required this.lastRateTime,
    required this.reason,
  });

  /// Result of all attributes values after accumulate.
  ///
  /// Key is attribute name and value is attribute value.
  final Map<String, int> attrMap;

  /// Name of user did the rate action.
  final String username;

  /// User id of the user did rate action.
  final String uid;

  /// Time of the first rate action accumulated.
  final DateTime firstRateTime;

  /// Time of the last rate action accumulated.
  final DateTime lastRateTime;

  /// Optional reason.
  ///
  /// We do not know if the user gave a empty reason or not, This field in source is always available.
  /// So it is not nullable.
  final String reason;
}
