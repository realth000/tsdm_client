import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:tsdm_client/shared/models/models.dart' hide Cookie;
import 'package:tsdm_client/shared/providers/storage_provider/models/convertable/convertable.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/schema/schema.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/schema/schema_versions.dart';
import 'package:tsdm_client/utils/logger.dart';

// part 'database.g.dart';
part 'database.g.dart';

/// 数据库定义
@DriftDatabase(
  tables: [
    BroadcastMessage,
    Cookie,
    Image,
    Notice,
    PersonalMessage,
    Settings,
    ThreadVisitHistory,
    UserAvatar,
  ],
)
final class AppDatabase extends _$AppDatabase with LoggerMixin {
  /// Constructor.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: stepByStep(
          from1To2: (m, schema) async {
            info('migrating database schema from 1 to 2...');
            await m.create(schema.threadVisitHistory);
            info('migrating database schema from 1 to 2... ok!');
          },
          from2To3: (m, schema) async {
            info('migrating database schema from 2 to 3...');
            await m.addColumn(schema.settings, schema.settings.offsetValue);
            await m.addColumn(schema.settings, schema.settings.sizeValue);
            await m.addColumn(schema.cookie, schema.cookie.lastCheckin);
            info('migrating database schema from 2 to 3... ok!');
          },
          from3To4: (m, schema) async {
            info('migrating database schema from 3 to 4...');
            await m.createAll();
            await m.addColumn(schema.cookie, schema.cookie.lastFetchNotice);
            await m.dropColumn(schema.cookie, 'email');
            await m.addColumn(schema.imageCache, schema.imageCache.usage);
            info('migrating database schema from 3 to 4... ok!');
          },
          from4To5: (m, schema) async {
            info('migrating database schema from 4 to 5...');
            // Migrate notice table
            final noticeData = await m.database.select(schema.notice).get();
            final noticeEntity =
                noticeData.map((e) => NoticeEntity.fromJson(e.data));
            await m.drop(schema.notice);
            await m.create(schema.notice);
            await transaction(() async {
              for (final n in noticeEntity) {
                await m.database.into(notice).insertOnConflictUpdate(n);
              }
            });
            info('migrating database schema from 4 to 5... ok!');
          },
        ),
      );
}
