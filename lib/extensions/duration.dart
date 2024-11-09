import 'package:flutter/widgets.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Add methods to convert a [Duration].
extension ConvertDurationExt on Duration {
  /// Convert into a human readable string.
  ///
  /// * 1-59 seconds -> $value seconds
  /// * 1-60 minutes -> $value minutes
  /// * 1-60 minutes -> $value minutes
  Text readable(BuildContext context, {TextStyle? style}) {
    final tr = context.t.general;

    final hours = inHours;
    if (hours > 0) {
      return Text.rich(
        tr.hours(value: TextSpan(text: '$hours')),
        style: style,
      );
    }

    final minutes = inMinutes;
    if (minutes > 0) {
      return Text.rich(
        tr.minutes(value: TextSpan(text: '$minutes')),
        style: style,
      );
    }

    return Text.rich(
      tr.seconds(value: TextSpan(text: '$inSeconds')),
      style: style,
    );
  }
}
