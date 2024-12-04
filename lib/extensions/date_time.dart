import 'package:flutter/cupertino.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Extension of [DateTime] that provides some transformation and calculation.
extension DateTimeExtension on DateTime {
  /// Format [DateTime] to format yyyy-MM-DD.
  String yyyyMMDD() {
    return '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// Format [DateTime] to format yyyy-MM-DD hh:mm:ss
  String yyyyMMDDHHMMSS() {
    return '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';
  }

  /// Calculate the duration to current date time.
  ///
  /// May be less than zero if current time is older than the given `this` time.
  String elapsedTillNow(BuildContext context) {
    final duration = DateTime.now().difference(this);
    final tr = context.t.general;

    final days = duration.inDays;
    if (days > 0) {
      return tr.days(value: duration.inDays);
    }

    final hours = duration.inHours;
    if (hours > 0) {
      return tr.hours(value: hours);
    }

    final minutes = duration.inMinutes;
    if (minutes > 0) {
      return tr.minutes(value: minutes);
    }

    final seconds = duration.inSeconds;
    if (seconds > 0) {
      return tr.seconds(value: seconds);
    }

    return tr.now;
  }
}
