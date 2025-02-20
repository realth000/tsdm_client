import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/features/checkin/utils/do_checkin.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Repository of checkin feature.
final class CheckinRepository with LoggerMixin {
  /// Constructor.
  const CheckinRepository({required StorageProvider storageProvider}) : _storageProvider = storageProvider;

  final StorageProvider _storageProvider;

  /// Perform a checkin for user [uid].
  Future<CheckinResult> checkin(int uid, CheckinFeeling feeling, String message) async {
    final netClient = getIt.get<NetClientProvider>();
    final checkinResult = await doCheckin(netClient, feeling, message).run();

    // FIXME: Here is a time gap between start checkin and checkin finished.
    // If any login-user related operation acted, for example logout or switch
    // to another user, the current user below is unexpected behavior.
    // So it's better to make a lock when doing checkin.
    if (checkinResult is CheckinResultSuccess || checkinResult is CheckinResultAlreadyChecked) {
      await _storageProvider.updateLastCheckinTime(uid, DateTime.now()).run();
    }
    return checkinResult;
  }
}
