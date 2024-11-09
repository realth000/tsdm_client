import 'package:bloc/bloc.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_info_repository.dart';

/// Cubit carrying latest result of auto sync notice action.
///
/// The state here is used for pushing a local notification.
final class NotificationStateAutoSyncCubit
    extends Cubit<NotificationAutoSyncInfo?> {
  /// Constructor.
  NotificationStateAutoSyncCubit(NotificationInfoRepository infoRepository)
      : _infoRepository = infoRepository,
        super(null) {
    _infoRepository.autoSyncStatus.listen(emit);
  }

  final NotificationInfoRepository _infoRepository;
}
