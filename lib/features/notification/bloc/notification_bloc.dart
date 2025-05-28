import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/notification/models/models.dart';
import 'package:tsdm_client/features/notification/repository/notification_info_repository.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/shared/models/notification_type.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/parsing.dart';

part 'notification_bloc.mapper.dart';

part 'notification_event.dart';

part 'notification_state.dart';

/// Emitter
typedef _Emit = Emitter<NotificationState>;

/// Bloc of notification.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> with LoggerMixin {
  /// Constructor.
  NotificationBloc({
    required NotificationRepository notificationRepository,
    required NotificationInfoRepository infoRepository,
    required AuthenticationRepository authRepo,
    required StorageProvider storageProvider,
  }) : _notificationRepository = notificationRepository,
       _infoRepository = infoRepository,
       _authRepo = authRepo,
       _storageProvider = storageProvider,
       super(const NotificationState()) {
    on<NotificationEvent>(
      (e, emit) => switch (e) {
        NotificationUpdateAllRequested() => _onUpdateAllRequested(emit),
        NotificationRecordFetchTimeRequested(:final time) => _onRecordFetchTimeRequested(time),
        NotificationMarkReadRequested(:final recordMark) => _onMarkReadRequested(emit, recordMark),
        NotificationInfoFetched(:final info) => _onNoticeInfoFetched(emit, info),
        NotificationMarkTypeReadRequested(:final markAsRead, :final markType) => _onMarkTypeReadRequested(
          emit,
          markType,
          markAsRead: markAsRead,
        ),
        NotificationDeleteNoticeRequested(:final uid, :final nid) => _onDeleteNotice(emit, uid: uid, nid: nid),
        NotificationDeletePersonalMessageRequested(:final uid, :final peerUid) => _onDeletePersonalMessage(
          emit,
          uid: uid,
          peerUid: peerUid,
        ),
        NotificationDeleteBroadcastMessageRequested(:final uid, :final pmid) => _onDeleteBroadcastMessage(
          emit,
          uid: uid,
          pmid: pmid,
        ),
      },
    );

    _notificationRepository.status.listen((info) => add(NotificationInfoFetched(info)));
  }

  final NotificationRepository _notificationRepository;
  final NotificationInfoRepository _infoRepository;
  final AuthenticationRepository _authRepo;
  final StorageProvider _storageProvider;

  Future<void> _onUpdateAllRequested(_Emit emit) async {
    if (state.status == NotificationStatus.loading) {
      debug('update all notifications, skipped because already loading one');
      return;
    }
    debug('updating all notifications...');

    emit(state.copyWith(status: NotificationStatus.loading));
    final uid = _authRepo.currentUser?.uid;
    if (uid == null) {
      info('skip request of update notification: uid is null, not authorized');
      return;
    }
    final lastFetchTimeEither = await _storageProvider.fetchLastFetchNoticeTime(uid).run();
    int? timestamp;
    if (lastFetchTimeEither.isRight()) {
      final datetime = lastFetchTimeEither.unwrap();
      if (datetime != null) {
        timestamp = datetime.millisecondsSinceEpoch ~/ 1000 + 1;
      }
      debug('fetch notification since ${datetime?.yyyyMMDDHHMMSS()}');
    } else {
      debug('fetch notification with default duration');
    }

    // The final state will be triggered inside repository, do NOT manually
    // update here.
    await _notificationRepository.fetchNotificationV2(uid: uid, timestamp: timestamp).run();
  }

  Future<void> _onNoticeInfoFetched(_Emit emit, NotificationInfoState infoState) async {
    late final NotificationV2 info;
    late final int uid;
    switch (infoState) {
      case NotificationInfoStateFailure():
        emit(state.copyWith(status: NotificationStatus.failure));
        return;
      case NotificationInfoStateLoading():
        emit(state.copyWith(status: NotificationStatus.loading));
        return;
      case NotificationInfoStateSuccess(uid: final u, info: final i):
        info = i;
        uid = u;
    }

    emit(state.copyWith(status: NotificationStatus.loading));

    final latestMessageTime = info.latestTimestamp();

    // Save fetched notice.
    debug(
      'saving notification: notice=${info.noticeList.length} '
      'personalMessage=${info.personalMessageList.length} '
      'broadcastMessage=${info.broadcastMessageList.length} '
      'latestTime=${latestMessageTime?.yyyyMMDDHHMMSS()}',
    );
    // Save fetched notifications.
    await _storageProvider
        .saveNotification(
          uid: uid,
          notificationGroup: NotificationGroup(
            noticeList: info.noticeList
                .map((e) => NoticeEntity(uid: uid, nid: e.id, timestamp: e.timestamp, data: e.data, alreadyRead: false))
                .toList(),
            personalMessageList: info.personalMessageList
                .map(
                  (e) => PersonalMessageEntity(
                    uid: uid,
                    timestamp: e.timestamp,
                    data: e.data,
                    peerUid: e.peerUid,
                    peerUsername: e.peerUsername,
                    sender: e.sender,
                    alreadyRead: e.alreadyRead,
                  ),
                )
                .toList(),
            broadcastMessageList: info.broadcastMessageList
                .map(
                  (e) => BroadcastMessageEntity(
                    uid: uid,
                    timestamp: e.timestamp,
                    data: e.data,
                    pmid: e.pmid,
                    alreadyRead: false,
                  ),
                )
                .toList(),
          ),
        )
        .run();

    final currentUid = _authRepo.currentUser?.uid;
    if (currentUid != uid) {
      debug('Async gap meets uid changes, do NOT update state.');
      return;
    }

    // Load local notice cache.
    // Here fetch all cached notice, no matter what time is it when last fetch
    // notice happened.
    final localNoticeData = await _storageProvider.fetchNotificationSince(uid: uid, timestamp: 0).run();
    debug(
      'load local notification: '
      'notice=${localNoticeData.noticeList.length} '
      'personalMessage=${localNoticeData.personalMessageList.length} '
      'broadcastMessage=${localNoticeData.broadcastMessageList.length}',
    );

    // Filter all outdated messages.
    localNoticeData.personalMessageList.removeWhere(
      (x) => x.uid == uid && info.personalMessageList.any((y) => y.peerUid == x.peerUid),
    );

    // Filter all duplicate messages.
    localNoticeData.noticeList.removeWhere((x) => info.noticeList.any((y) => x.uid == uid && x.nid == y.id));
    localNoticeData.broadcastMessageList.removeWhere(
      (x) => info.broadcastMessageList.any((y) => x.uid == uid && x.pmid == y.pmid),
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

    final allNotice = [
      ...info.noticeList,
      ...localNoticeData.noticeList.map(
        (e) => NoticeV2(id: e.nid, timestamp: e.timestamp, data: e.data, alreadyRead: e.alreadyRead ?? false),
      ),
    ];
    final allPersonalMessage = [
      ...info.personalMessageList,
      ...localNoticeData.personalMessageList.map(
        (e) => PersonalMessageV2(
          timestamp: e.timestamp,
          data: e.data,
          peerUid: e.peerUid,
          peerUsername: e.peerUsername,
          sender: e.sender,
          alreadyRead: e.alreadyRead,
        ),
      ),
    ];
    final allBroadcastMessage = [
      ...info.broadcastMessageList,
      ...localNoticeData.broadcastMessageList.map(
        (e) =>
            BroadcastMessageV2(timestamp: e.timestamp, data: e.data, pmid: e.pmid, alreadyRead: e.alreadyRead ?? false),
      ),
    ];

    // Post the latest unread notification info to global state cubit.
    _infoRepository.updateInfo(
      unreadNoticeCount: allNotice.where((e) => !e.alreadyRead).length,
      unreadPersonalMessageCount: allPersonalMessage.where((e) => !e.alreadyRead).length,
      unreadBroadcastMessageCount: allBroadcastMessage.where((e) => !e.alreadyRead).length,
    );

    // Post the latest sync result in the action to global auto sync info state
    // cubit.
    //
    // Here the state posted only including ones received from server in this
    // sync action, not former ones or local storage ones.
    //
    // MARK: flnp
    if (info.personalMessageList.isNotEmpty) {
      _infoRepository.updateAutoSyncInfo(
        NotificationAutoSyncInfoPm(
          user: info.personalMessageList.last.peerUsername,
          msg: info.personalMessageList.last.data.truncate(40, ellipsis: true),
          notice: info.noticeList.length,
          personalMessage: info.personalMessageList.length,
          broadcastMessage: info.broadcastMessageList.length,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else if (info.broadcastMessageList.isNotEmpty) {
      _infoRepository.updateAutoSyncInfo(
        NotificationAutoSyncInfoBm(
          msg: info.broadcastMessageList.last.data.truncate(40, ellipsis: true),
          notice: info.noticeList.length,
          personalMessage: info.personalMessageList.length,
          broadcastMessage: info.broadcastMessageList.length,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else if (info.noticeList.isNotEmpty) {
      _infoRepository.updateAutoSyncInfo(
        NotificationAutoSyncInfoNotice(
          msg: parseHtmlDocument(info.noticeList.last.data).body?.innerText.truncate(40, ellipsis: true) ?? '<null>',
          notice: info.noticeList.length,
          personalMessage: info.personalMessageList.length,
          broadcastMessage: info.broadcastMessageList.length,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    emit(
      state.copyWith(
        status: NotificationStatus.success,
        noticeList: allNotice,
        personalMessageList: allPersonalMessage,
        broadcastMessageList: allBroadcastMessage,
        latestTime: latestMessageTime,
      ),
    );
  }

  Future<void> _onMarkTypeReadRequested(_Emit emit, NotificationType markType, {required bool markAsRead}) async {
    final uid = _authRepo.currentUser?.uid;
    if (uid == null) {
      error('intend to mark all notice for user but uid not found');
      return;
    }

    emit(state.copyWith(status: NotificationStatus.loading));

    await _storageProvider.markTypeAsRead(notificationType: markType, uid: uid, alreadyRead: markAsRead).run();

    switch (markType) {
      case NotificationType.notice:
        final list = state.noticeList.map((e) => e.copyWith(alreadyRead: markAsRead)).toList();
        emit(state.copyWith(status: NotificationStatus.success, noticeList: list));
      case NotificationType.personalMessage:
        final list = state.personalMessageList.map((e) => e.copyWith(alreadyRead: markAsRead)).toList();
        emit(state.copyWith(status: NotificationStatus.success, personalMessageList: list));
      case NotificationType.broadcastMessage:
        final list = state.broadcastMessageList.map((e) => e.copyWith(alreadyRead: markAsRead)).toList();
        emit(state.copyWith(status: NotificationStatus.success, broadcastMessageList: list));
    }
  }

  Future<void> _onRecordFetchTimeRequested(DateTime time) async {
    if (time.year < 2025) {
      warning('not going to record fetch time as we are in 2025, at least');
      return;
    }

    final uid = _authRepo.currentUser?.uid;
    if (uid == null) {
      error('failed to update last fetch notice time: uid not found');
      return;
    }
    debug('update last fetch notification time to ${time.yyyyMMDDHHMMSS()}');
    await _storageProvider.updateLastFetchNoticeTime(uid, time).run();
  }

  /// The event handler of marking some kind of notice as read or unread.
  ///
  /// This function does not update state because it only changes the
  /// read/unread status in local storage and it's the presentation layer first
  /// know the notice has been read so do not need to give the mark solution
  /// back to the presentation layer, it handles by itself.
  Future<void> _onMarkReadRequested(_Emit emit, RecordMark recordMark) async {
    debug('mark notice: $recordMark');
    final task = switch (recordMark) {
      RecordMarkNotice(:final uid, :final nid, alreadyRead: final read) => () {
        final targetIndex = state.noticeList.indexWhere((e) => e.id == nid);
        if (targetIndex < 0) {
          // target not found.
          return AsyncVoidEither(() async => left(NotificationNotFound()));
        }
        final target = state.noticeList[targetIndex];
        final list = state.noticeList.toList();
        list[targetIndex] = target.copyWith(alreadyRead: read);
        emit(state.copyWith(noticeList: list));
        return _storageProvider.markNoticeAsRead(uid: uid, nid: nid, read: read);
      }(),
      RecordMarkPersonalMessage(:final uid, :final peerUid, alreadyRead: final read) => () {
        final targetIndex = state.personalMessageList.indexWhere((e) => e.peerUid == peerUid);
        final target = state.personalMessageList[targetIndex];
        final list = state.personalMessageList.toList();
        list[targetIndex] = target.copyWith(alreadyRead: read);
        emit(state.copyWith(personalMessageList: list));
        return _storageProvider.markPersonalMessageAsRead(uid: uid, peerUid: peerUid, read: read);
      }(),
      RecordMarkBroadcastMessage(:final uid, :final timestamp, alreadyRead: final read) => () {
        final targetIndex = state.broadcastMessageList.indexWhere((e) => e.timestamp == timestamp);
        final target = state.broadcastMessageList[targetIndex];
        final list = state.broadcastMessageList.toList();
        list[targetIndex] = target.copyWith(alreadyRead: read);
        emit(state.copyWith(broadcastMessageList: list));
        return _storageProvider.markBroadcastMessageAsRead(uid: uid, timestamp: timestamp, read: read);
      }(),
    };
    await task.run();
  }

  Future<void> _onDeleteNotice(_Emit emit, {required int uid, required int nid}) async {
    emit(state.copyWith(noticeList: state.noticeList.toList()..removeWhere((e) => e.id == nid)));
    await _storageProvider.deleteNotice(uid: uid, nid: nid).run();
  }

  Future<void> _onDeletePersonalMessage(_Emit emit, {required int uid, required int peerUid}) async {
    emit(
      state.copyWith(personalMessageList: state.personalMessageList.toList()..removeWhere((e) => e.peerUid == peerUid)),
    );
    await _storageProvider.deletePersonalMessage(uid: uid, peerUid: peerUid).run();
  }

  Future<void> _onDeleteBroadcastMessage(_Emit emit, {required int uid, required int pmid}) async {
    emit(state.copyWith(broadcastMessageList: state.broadcastMessageList.toList()..removeWhere((e) => e.pmid == pmid)));
    await _storageProvider.deleteBroadcastMessage(uid: uid, pmid: pmid).run();
  }

  /// Do NOT dispose [_infoRepository] here because the state cubit owns it.
  @override
  Future<void> close() async {
    _notificationRepository.dispose();
    return super.close();
  }
}
