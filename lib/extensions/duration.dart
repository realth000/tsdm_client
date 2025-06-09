import 'package:flutter/widgets.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Add methods to convert a [Duration].
extension ConvertDurationExt on Duration {
  /// Convert into a human readable string.
  ///
  /// * 1-59 seconds -> $value seconds
  /// * 1-60 minutes -> $value minutes
  /// * 1-60 minutes -> $value minutes
  String readable(BuildContext context) {
    final tr = context.t.general;

    final days = inDays;
    if (days > 0) {
      return tr.days(value: days);
    }

    final hours = inHours;
    if (hours > 0) {
      return tr.hours(value: hours);
    }

    final minutes = inMinutes;
    if (minutes > 0) {
      return tr.minutes(value: minutes);
    }

    return tr.seconds(value: inSeconds);
  }
}
