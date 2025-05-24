import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/models/notification_type.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/dao/dao.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';
import 'package:tsdm_client/utils/logger.dart';

/// A time to fetch notice or save notice.
///
/// Use this model to gather different types of notice, so that makes calling
/// APIs less times.
final class NotificationGroup {
  /// Constructor.
  const NotificationGroup({
    required this.noticeList,
    required this.personalMessageList,
    required this.broadcastMessageList,
  });

  /// All fetched notice.
  final List<NoticeEntity> noticeList;

  /// All fetched personal message.
  final List<PersonalMessageEntity> personalMessageList;

  /// All fetched broadcast message.
  final List<BroadcastMessageEntity> broadcastMessageList;
}

/// Load all cookie info from database without any dependency except [db].
///
/// Only use this function to preload cookie before initializing
/// [StorageProvider].
Future<Map<UserLoginInfo, Cookie>> preloadCookie(AppDatabase db) async {
  final allCookie = await CookieDao(db).selectAll();
  final mappedCookie = allCookie.map(
    (e) => MapEntry(
      UserLoginInfo(
        username: e.username,
        uid: e.uid,
        // email: e.email,
      ),
      jsonDecode(e.cookie) as Map<String, dynamic>,
    ),
  );

  return Map.fromEntries(mappedCookie);
}

/// Load all image cache info from database without any dependency except [db].
///
/// Only use this function to preload cookie before initializing
/// [StorageProvider].
Future<Map<String, ImageEntity>> preloadImageCache(AppDatabase db) async {
  final allImageCache = await ImageDao(db).selectAll();
  final mappedImageCache = allImageCache.map((e) => MapEntry(e.url, e));
  return Map.fromEntries(mappedImageCache);
}

/// [StorageProvider] should be used by other providers.
class StorageProvider with LoggerMixin {
  /// Constructor.
  const StorageProvider(this._db, this._cookieCache, this._imageCache);

  /// Injected database
  final AppDatabase _db;

  /// All cookie cached in memory.
  ///
  /// Read cache to avoid disk IO and make it synchronous.
  ///
  /// MUST update during cookie setter calls.
  final Map<UserLoginInfo, Cookie> _cookieCache;

  /// All image cache cached in memory.
  ///
  /// Access this field to avoid disk IO and make it synchronous.
  ///
  /// MUST update during image cache setter calls.
  final Map<String, ImageEntity> _imageCache;

  /// Get the stream of all users in storage.
  Stream<List<UserLoginInfo>> allUsersStream() {
    return CookieDao(
      _db,
    ).watchAll().map((e) => e.map((entity) => UserLoginInfo(username: entity.username, uid: entity.uid)).toList());
  }

  /*             User             */

  /// Get all recorded login user.
  ///
  /// Those users are the ones ever login before.
  Future<List<UserLoginInfo>> getAllUsers() async {
    final cookies = await CookieDao(_db).selectAll();

    return cookies.map((e) => UserLoginInfo(username: e.username, uid: e.uid)).toList();
  }

  /// Get all recorded login user with datetime of last checkin.
  ///
  /// Last checkin time is in milliseconds level.
  Future<List<(UserLoginInfo, DateTime?)>> getAllUsersWithTime() async {
    final cookies = await CookieDao(_db).selectAll();

    return cookies.map((e) => (UserLoginInfo(username: e.username, uid: e.uid), e.lastCheckin)).toList();
  }

  /// Delete the user login info for the user specified by [uid].
  Future<int> deleteUserLoginInfo(int uid) async {
    return CookieDao(_db).deleteCookieByUid(uid);
  }

  /*             cookie             */

  /// Get [Cookie] with [uid] from cookie cached saved in memory.
  ///
  /// Return null if not found.
  ///
  /// Generally the cookie cache is synced with database cookie values.
  /// So may not need to use the async version API to retry to read.
  Cookie? getCookieByUidSync(int uid) {
    return _cookieCache.entries.firstWhereOrNull((e) => e.key.uid == uid)?.value;
  }

  /// Get [Cookie] with [username] from cookie cached saved in memory.
  ///
  /// Return null if not found.
  ///
  /// Generally the cookie cache is synced with database cookie values.
  /// So may not need to use the async version API to retry to read.
  Cookie? getCookieByUsernameSync(String username) {
    return _cookieCache.entries.firstWhereOrNull((e) => e.key.username == username)?.value;
  }

  /// Get [Cookie] with [email] from cookie cached saved in memory.
  ///
  /// Return null if not found.
  ///
  /// Generally the cookie cache is synced with database cookie values.
  /// So may not need to use the async version API to retry to read.
  @Deprecated('email APIs are deprecated when migrate to v1')
  Cookie? getCookieByEmailSync(String email) {
    return null;
    // return _cookieCache.entries
    //     .firstWhereOrNull((e) => e.key.email == email)
    //     ?.value;
  }

  /// Save cookie with completed user info.
  ///
  /// Required full user info and save by [uid] so that we handled some extreme
  /// situation when username or email changed.
  Future<void> saveCookie({required String username, required int uid, required Cookie cookie}) async {
    final allCookie = getCookieByUidSync(uid) ?? <String, dynamic>{};

    // Combine two map together, do not directly use [cookie].
    // ignore: cascade_invocations
    allCookie.addAll(Map.castFrom<String, dynamic, String, String>(cookie));
    // Update cookie cache.
    final userInfo = UserLoginInfo(username: username, uid: uid /*, email: email*/);
    _cookieCache[userInfo] = allCookie;

    if (!allCookie.toString().contains('${cookiePrefix}_auth')) {
      // Only save cookie when cookie is authed.
      info('refuse to save not authed cookie');
      return;
    }

    await CookieDao(_db).upsertCookie(
      CookieCompanion(
        username: Value(username),
        uid: Value(uid),
        // email: Value(email),
        cookie: Value(jsonEncode(allCookie)),
      ),
    );
  }

  /// Delete cookie for [uid].
  Future<bool> deleteCookieByUid(int uid) async {
    // Update cookie cache.
    _cookieCache.removeWhere((e, _) => e.uid == uid);
    final affectedRows = await CookieDao(_db).deleteCookieByUid(uid);
    return affectedRows != 0;
  }

  /// Delete stored cookie with [userInfo].
  ///
  /// uid > username > email.
  Future<bool> deleteCookieByUserInfo(UserLoginInfo userInfo) async {
    final username = userInfo.username;
    final uid = userInfo.uid;
    // final email = userInfo.email;
    final int affectedRows;
    if (uid != null) {
      _cookieCache.removeWhere((e, _) => e.uid == uid);
      affectedRows = await CookieDao(_db).deleteCookieByUid(uid);
    } else if (username != null) {
      _cookieCache.removeWhere((e, _) => e.username == username);
      affectedRows = await CookieDao(_db).deleteCookieByUsername(username);
      // } else if (email != null) {
      //   _cookieCache.removeWhere((e, _) => e.email == email);
      //   affectedRows = await CookieDao(_db).deleteCookieByEmail(email);
    } else {
      error('intend to delete cookie with empty user info');
      affectedRows = 0;
    }
    return affectedRows != 0;
  }

  /*            image cache           */

  /// Get the image cache for image from [url].
  ImageEntity? getImageCacheSync(String url) => _imageCache.entries.firstWhereOrNull((e) => e.key == url)?.value;

  /// Get user avatar cache info on [username].
  Future<UserAvatarEntity?> getUserAvatarEntityCache({required String username, required String? imageUrl}) async =>
      UserAvatarDao(_db).selectAvatar(username: username, imageUrl: imageUrl);

  /// Insert or update cache info, update all info.
  Future<void> updateImageCache(
    String url, {
    required String fileName,
    DateTime? lastCacheTime,
    DateTime? lastUsedTime,
  }) async {
    final now = DateTime.now();
    _imageCache[url] = ImageEntity(
      url: url,
      fileName: fileName,
      lastCachedTime: lastCacheTime ?? now,
      lastUsedTime: lastUsedTime ?? now,
    );
    await ImageDao(_db).upsertImageCache(
      ImageCompanion(
        url: Value(url),
        fileName: Value(fileName),
        lastCachedTime: lastCacheTime != null ? Value(lastCacheTime) : Value(now),
        lastUsedTime: lastUsedTime != null ? Value(lastUsedTime) : Value(now),
      ),
    );
  }

  /// Insert or update cache info, only update last used time.
  Future<void> updateImageCacheUsedTime(String url) async {
    final now = DateTime.now();
    if (_imageCache.containsKey(url)) {
      _imageCache[url] = _imageCache[url]!.copyWith(lastUsedTime: now);
    }
    await ImageDao(_db).upsertImageCache(ImageCompanion(url: Value(url), lastUsedTime: Value(now)));
  }

  /// Clear all image cache in database.
  Future<void> clearImageCache() async {
    _imageCache.clear();
    await ImageDao(_db).deleteAll();
  }

  /*             settings             */

  /// Load all saved settings.
  Future<List<SettingsEntity>> getAllSettings() async {
    return SettingsDao(_db).getAll();
  }

  /// Remove a settings with given [name].
  Future<bool> removeByKey(String name) async {
    final affectedRows = await SettingsDao(_db).deleteByName(name);
    return affectedRows != 0;
  }

  /// Get string type value of specified key.
  Future<String?> getString(String key) async => SettingsDao(_db).getValueByName<String>(key);

  /// Save string type value of specified key.
  Future<void> saveString(String key, String value) async {
    await SettingsDao(_db).setValue<String>(key, value);
  }

  /// Get int type value of specified key.
  Future<int?> getInt(String key) async => SettingsDao(_db).getValueByName<int>(key);

  /// Sae int type value of specified key.
  Future<void> saveInt(String key, int value) async {
    await SettingsDao(_db).setValue<int>(key, value);
  }

  /// Get bool type value of specified key.
  Future<bool?> getBool(String key) async => SettingsDao(_db).getValueByName<bool>(key);

  /// Save bool type value of specified value.
  Future<void> saveBool(String key, {required bool value}) async {
    await SettingsDao(_db).setValue<bool>(key, value);
  }

  /// Get double type value of specified key.
  Future<double?> getDouble(String key) async => SettingsDao(_db).getValueByName<double>(key);

  /// Save double type value of specified key.
  Future<void> saveDouble(String key, double value) async {
    await SettingsDao(_db).setValue<double>(key, value);
  }

  /// Get [DateTime] type value of specified key.
  Future<DateTime?> getDateTime(String key) async => SettingsDao(_db).getValueByName(key);

  /// Save [DateTime] type value of specified key.
  Future<void> saveDateTime(String key, DateTime value) async => SettingsDao(_db).setValue<DateTime>(key, value);

  /// Get [Offset] type value of specified key.
  Future<Offset?> getOffset(String key) async => SettingsDao(_db).getValueByName(key);

  /// Save [Offset] type value of specified key.
  Future<void> saveOffset(String key, Offset value) async => SettingsDao(_db).setValue<Offset>(key, value);

  /// Get [Size] type value of specified key.
  Future<Size?> getSize(String key) async => SettingsDao(_db).getValueByName(key);

  /// Save [Size] type value of specified key.
  Future<void> saveSize(String key, Size value) async => SettingsDao(_db).setValue<Size>(key, value);

  /// Get [List] of [String] type value of specified key.
  Future<List<String>?> getStringList(String key) async => SettingsDao(_db).getValueByName(key);

  /// Save [List] of [String] type value of specified key.
  Future<void> saveStringList(String key, List<String> value) async =>
      SettingsDao(_db).setValue<List<String>>(key, value);

  /// Get [List] of [int] type value of specified key.
  Future<List<int>?> getIntList(String key) async => SettingsDao(_db).getValueByName(key);

  /// Save [List] of [int] type value of specified key.
  Future<void> saveIntList(String key, List<int> value) async => SettingsDao(_db).setValue<List<int>>(key, value);

  /// Delete the given record from database.
  Future<void> deleteKey(String key) async {
    await SettingsDao(_db).deleteByName(key);
  }

  /*        thread visit history        */

  /// Fetch all thread visit history for all users and all threads..
  AsyncEither<List<ThreadVisitHistoryEntity>> fetchAllThreadVisitHistory() => AsyncEither(() async {
    final history = await ThreadVisitHistoryDao(_db).selectAll();
    return Right(history);
  });

  /// Fetch all thread visit history for user [uid].
  AsyncEither<List<ThreadVisitHistoryEntity>> fetchThreadVisitHistoryByUid(int uid) =>
      AsyncEither(() async => Right(await ThreadVisitHistoryDao(_db).selectByUid(uid)));

  /// Delete a history record specified by [uid] and [tid].
  AsyncVoidEither deleteByUidAndTid({required int uid, required int tid}) => AsyncVoidEither(() async {
    await ThreadVisitHistoryDao(_db).deleteByUidOrTid(uid: uid, tid: tid);
    return rightVoid();
  });

  /// Save thread visit history.
  Future<void> updateThreadVisitHistory({
    required int uid,
    required int tid,
    required int fid,
    required String username,
    required String threadTitle,
    required String forumName,
    required DateTime visitTime,
  }) async => ThreadVisitHistoryDao(_db).upsertVisitHistory(
    ThreadVisitHistoryCompanion(
      uid: Value(uid),
      tid: Value(tid),
      fid: Value(fid),
      username: Value(username),
      threadTitle: Value(threadTitle),
      forumName: Value(forumName),
      visitTime: Value(visitTime),
    ),
  );

  /// Delete thread visit history with [uid] and [tid].
  Future<void> deleteThreadVisitHistory({int? uid, int? tid}) async =>
      ThreadVisitHistoryDao(_db).deleteByUidOrTid(uid: uid, tid: tid);

  /// Delete all thread visit history.
  AsyncVoidEither deleteAllThreadVisitHistory() => AsyncVoidEither(() async {
    await ThreadVisitHistoryDao(_db).deleteAll();
    return rightVoid();
  });

  /*        notification        */

  /// Fetch the timestamp for user [uid] when fetch notification last time.
  AsyncEither<DateTime?> fetchLastFetchNoticeTime(int uid) => AsyncEither(() async {
    final user = await CookieDao(_db).selectCookieByUid(uid);
    if (user == null) {
      // User record not found.
      return left(NotificationUserNotFound());
    }
    return right(user.lastFetchNotice);
  });

  /// Update the last fetch notification datetime in storage for user [uid].
  VoidTask updateLastFetchNoticeTime(int uid, DateTime datetime) => VoidTask(() async {
    await CookieDao(_db).updateLastFetchNoticeTime(uid, datetime);
    return;
  });

  /// Update the last checkin success datetime in storage for user [uid].
  VoidTask updateLastCheckinTime(int uid, DateTime datetime) => VoidTask(() async {
    await CookieDao(_db).updateLastCheckinTime(uid, datetime);
    return;
  });

  /// Fetch all notification for user [uid] since time [timestamp].
  ///
  /// Return a instance of [NotificationGroup] that contains all types of
  /// fetched notice.
  Task<NotificationGroup> fetchNotificationSince({required int uid, required int timestamp}) => Task(() async {
    final dao = NotificationDao(_db);
    // final
    final noticeList = await dao.selectNoticeSince(uid: uid, timestamp: timestamp);

    final personalMessageList = await dao.selectPersonalMessageSince(uid: uid, timestamp: timestamp);
    final broadcastMessageList = await dao.selectBroadcastMessageSince(uid: uid, timestamp: timestamp);

    return NotificationGroup(
      noticeList: noticeList,
      personalMessageList: personalMessageList,
      broadcastMessageList: broadcastMessageList,
    );
  });

  /// Save a group of notice for user [uid] into storage.
  VoidTask saveNotification({required int uid, required NotificationGroup notificationGroup}) => VoidTask(() async {
    await NotificationDao(_db).insertManyNotice(
      noticeList:
          notificationGroup.noticeList
              .map(
                (e) => NoticeCompanion(
                  uid: Value(uid),
                  timestamp: Value(e.timestamp),
                  data: Value(e.data),
                  nid: Value(e.nid),
                  alreadyRead: Value(e.alreadyRead),
                ),
              )
              .toList(),
      personalMessageList:
          notificationGroup.personalMessageList
              .map(
                (e) => PersonalMessageCompanion(
                  uid: Value(uid),
                  timestamp: Value(e.timestamp),
                  data: Value(e.data),
                  peerUid: Value(e.peerUid),
                  peerUsername: Value(e.peerUsername),
                  sender: Value(e.sender),
                  alreadyRead: Value(e.alreadyRead),
                ),
              )
              .toList(),
      broadcastMessageList:
          notificationGroup.broadcastMessageList
              .map(
                (e) => BroadcastMessageCompanion(
                  uid: Value(uid),
                  timestamp: Value(e.timestamp),
                  data: Value(e.data),
                  pmid: Value(e.pmid),
                  alreadyRead: Value(e.alreadyRead),
                ),
              )
              .toList(),
    );
  });

  /// Mark a notice as [read].
  AsyncVoidEither markNoticeAsRead({required int uid, required int nid, required bool read}) =>
      AsyncVoidEither(() async {
        await NotificationDao(_db).markNoticeAsRead(uid: uid, nid: nid, read: read);
        return rightVoid();
      });

  /// Mark a personal message as [read].
  AsyncVoidEither markPersonalMessageAsRead({required int uid, required int peerUid, required bool read}) =>
      AsyncVoidEither(() async {
        await NotificationDao(_db).markPersonalMessageAsRead(uid: uid, peerUid: peerUid, read: read);
        return rightVoid();
      });

  /// Mark a broadcast message as [read].
  AsyncVoidEither markBroadcastMessageAsRead({required int uid, required int timestamp, required bool read}) =>
      AsyncVoidEither(() async {
        await NotificationDao(_db).markBroadcastMessageAsRead(uid: uid, timestamp: timestamp, read: read);
        return rightVoid();
      });

  /// Mark all message of a [notificationType] as [alreadyRead].
  AsyncVoidEither markTypeAsRead({
    required NotificationType notificationType,
    required bool alreadyRead,
    required int uid,
  }) => AsyncVoidEither(() async {
    await NotificationDao(_db).markTypeAsRead(notificationType: notificationType, uid: uid, alreadyRead: alreadyRead);

    return rightVoid();
  });

  /// Delete located notice by given [uid] and [nid].
  ///
  /// At most delete one item.
  AsyncVoidEither deleteNotice({required int uid, required int nid}) => AsyncVoidEither(() async {
    await NotificationDao(_db).deleteNotice(uid: uid, nid: nid);
    return rightVoid();
  });

  /// Delete located personal message by [uid] and [peerUid].
  ///
  /// At most delete one item.
  AsyncVoidEither deletePersonalMessage({required int uid, required int peerUid}) => AsyncVoidEither(() async {
    await NotificationDao(_db).deletePersonalMessage(uid: uid, peerUid: peerUid);
    return rightVoid();
  });

  /// Delete located broadcast message by [uid] and [pmid].
  ///
  /// At most delete one item.
  AsyncVoidEither deleteBroadcastMessage({required int uid, required int pmid}) => AsyncVoidEither(() async {
    await NotificationDao(_db).deleteBroadcastMessage(uid: uid, pmid: pmid);
    return rightVoid();
  });

  /*        user avatar        */

  /// Update recorded user avatar info for [username] with [cacheName].
  AsyncVoidEither updateUserAvatarCacheInfo({
    required String username,
    required String cacheName,
    required String imageUrl,
  }) => AsyncVoidEither(() async {
    await UserAvatarDao(_db).upsertAvatar(
      UserAvatarCompanion(username: Value(username), cacheName: Value(cacheName), imageUrl: Value(imageUrl)),
    );

    return rightVoid();
  });

  /// Clear all user avatar cache info.
  Future<void> clearUserAvatarInfo() async {
    await UserAvatarDao(_db).deleteAll();
  }

  /// Dispose the database.
  ///
  /// WARNING: avoid to use this function when possible as reconnect is not in
  /// consideration.
  Future<void> dispose() async {
    await _db.close();
  }
}
