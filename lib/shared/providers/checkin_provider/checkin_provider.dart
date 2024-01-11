import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/checkin_result.dart';

abstract interface class CheckinProvider {
  Future<CheckinResult> checkin(
    CheckinFeeling feeling,
    String message,
  );
}
