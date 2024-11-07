import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'notification_bloc.mapper.dart';
part 'notification_event.dart';
part 'notification_state.dart';

/// Emitter
typedef _Emit = Emitter<NotificationState>;

/// Bloc of notification.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState>
    with LoggerMixin {
  /// Constructor.
  NotificationBloc({
    required NotificationRepository notificationRepository,
    required AuthenticationRepository authRepo,
    required StorageProvider storageProvider,
  })  : _notificationRepository = notificationRepository,
        _authRepo = authRepo,
        _storageProvider = storageProvider,
        super(const NotificationState()) {
    on<NotificationEvent>(
      (e, emit) => switch (e) {
        NotificationUpdateAllRequested() => _onRefreshAllRequested(emit),
        NotificationRecordFetchTimeRequested() => _onRecordFetchTimeRequested(),
      },
    );
  }

  final NotificationRepository _notificationRepository;
  final AuthenticationRepository _authRepo;
  final StorageProvider _storageProvider;

  Future<void> _onRefreshAllRequested(_Emit emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    final uid = _authRepo.currentUser?.uid;
    if (uid == null) {
      error('failed to refresh all notification: uid not found');
      return;
    }
    final lastFetchTimeEither =
        await _storageProvider.fetchLastFetchNoticeTime(uid).run();
    int? timestamp;
    if (lastFetchTimeEither.isRight()) {
      final datetime = lastFetchTimeEither.unwrap();
      if (datetime != null) {
        timestamp = datetime.millisecondsSinceEpoch ~/ 1000;
      }
      debug('fetch notification since ${datetime?.yyyyMMDDHHMMSS()}');
    } else {
      debug('fetch notification with default duration');
    }
    final noticeEither = await _notificationRepository
        .fetchNotificationV2(timestamp: timestamp)
        .run();
    if (noticeEither.isLeft()) {
      handle(noticeEither.unwrapErr());
      emit(state.copyWith(status: NotificationStatus.failure));
      return;
    }
    // Load local notice cache.
    // Here fetch all cached notice, no matter what time is it when last fetch
    // notice happened.
    final localNoticeData = await _storageProvider
        .fetchNotificationSince(uid: uid, timestamp: 0)
        .run();
    debug('load local notification: '
        'notice=${localNoticeData.noticeList.length} '
        'personalMessage=${localNoticeData.personalMessageList.length} '
        'broadcastMessage=${localNoticeData.broadcastMessageList.length}');

    // Save fetched notice.
    final noticeData = noticeEither.unwrap();

    debug('saving notification: notice=${noticeData.noticeList.length} '
        'personalMessage=${noticeData.personalMessageList.length} '
        'broadcastMessage=${noticeData.broadcastMessageList.length}');
    // Save fetched notifications.
    await _storageProvider
        .saveNotification(
          uid: uid,
          notificationGroup: NotificationGroup(
            noticeList: noticeData.noticeList
                .map(
                  (e) => NoticeEntity(
                    uid: uid,
                    nid: e.id,
                    timestamp: e.timestamp,
                    data: e.data,
                  ),
                )
                .toList(),
            personalMessageList: noticeData.personalMessageList
                .map(
                  (e) => PersonalMessageEntity(
                    uid: uid,
                    timestamp: e.timestamp,
                    data: e.data,
                    peerUid: e.peerUid,
                    peerUsername: e.peerUsername,
                    sender: e.sender,
                    alreadyRead: e.read,
                  ),
                )
                .toList(),
            broadcastMessageList: noticeData.broadcastMessageList
                .map(
                  (e) => BroadcastMessageEntity(
                    uid: uid,
                    timestamp: e.timestamp,
                    data: e.data,
                    pmid: e.pmid,
                  ),
                )
                .toList(),
          ),
        )
        .run();

    // Filter all outdated messages.
    localNoticeData.personalMessageList.removeWhere(
      (x) =>
          x.uid == uid &&
          noticeData.personalMessageList.any((y) => y.peerUid == x.peerUid),
    );

    // Here simply prepend fetching notification a front of all current
    // messages.
    //
    // This works because:
    //
    // * If user already fetched notice before, the new coming notice are only
    //   the ones generated after last fetch notice time, so notice in response
    //   are only the ones that never fetched before.
    // * If user haven't fetched notice on this machine before, current state
    //   holds nothing.
    //
    // It is expected that all local notice is older than server ones.
    // TODO: Sort notice by timestamp.
    emit(
      state.copyWith(
        status: NotificationStatus.success,
        noticeList: [
          ...noticeData.noticeList,
          ...localNoticeData.noticeList.map(
            (e) => NoticeV2(
              id: e.nid,
              timestamp: e.timestamp,
              data: e.data,
            ),
          ),
        ],
        personalMessageList: [
          ...noticeData.personalMessageList,
          ...localNoticeData.personalMessageList.map(
            (e) => PersonalMessageV2(
              timestamp: e.timestamp,
              data: e.data,
              peerUid: e.peerUid,
              peerUsername: e.peerUsername,
              sender: e.sender,
              read: e.alreadyRead,
            ),
          ),
        ],
        broadcastMessageList: [
          ...noticeData.broadcastMessageList,
          ...localNoticeData.broadcastMessageList.map(
            (e) => BroadcastMessageV2(
              timestamp: e.timestamp,
              data: e.data,
              pmid: e.pmid,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRecordFetchTimeRequested() async {
    final uid = _authRepo.currentUser?.uid;
    if (uid == null) {
      error('failed to update last fetch notice time: uid not found');
      return;
    }
    final now = DateTime.now();
    debug('update last fetch notification time to ${now.yyyyMMDDHHMMSS()}');
    await _storageProvider.updateLastFetchNoticeTime(uid, now).run();
  }
}
