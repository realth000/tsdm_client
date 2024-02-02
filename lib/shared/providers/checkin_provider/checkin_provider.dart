import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/checkin_result.dart';

/// Checkin provider interface.
// ignore: one_member_abstracts
abstract interface class CheckinProvider {
  /// Do a checkin action with given [feeling] and [message].
  Future<CheckinResult> checkin(
    CheckinFeeling feeling,
    String message,
  );
}
