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
    AvatarHistory,
    BroadcastMessage,
    Cookie,
    FastRateTemplate,
    FastReplyTemplate,
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
  int get schemaVersion => 9;

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
        await customUpdate(
          'DELETE FROM notice '
          'WHERE (uid, nid) NOT IN ( '
          '    SELECT uid, max(nid) '
          '    FROM notice '
          '    GROUP BY uid '
          ');',
          updates: {schema.notice},
          updateKind: UpdateKind.delete,
        );
        await m.alterTable(TableMigration(schema.notice));
        info('migrating database schema from 4 to 5... ok!');
      },
      from5To6: (m, schema) async {
        info('migrating database schema from 5 to 6...');
        // Migrate broadcast message table.
        //
        // This raw sql statement only reserves the latest message in each
        // pair of (uid, peer_uid), which means deleting all duplicate
        // `{uid, peer_uid}` pair while keeping the latest message.
        // So it's safe to change the primary key from `{uid, timestamp}` to
        // `{uid, peer_uid}`.
        await customUpdate(
          'DELETE FROM personal_message '
          'WHERE (uid, peer_uid, timestamp) NOT IN ( '
          '    SELECT uid, peer_uid, max(timestamp) '
          '    FROM personal_message '
          '    GROUP BY uid, peer_uid '
          ');',
          updates: {schema.personalMessage},
          updateKind: UpdateKind.delete,
        );
        await m.alterTable(TableMigration(schema.personalMessage));
        // Migrate personal message table.
        await m.addColumn(schema.broadcastMessage, schema.broadcastMessage.alreadyRead);
        await m.addColumn(schema.notice, schema.notice.alreadyRead);
        info('migrating database schema from 5 to 6... ok!');
      },
      from6To7: (m, schema) async {
        info('migrating database schema from 6 to 7...');
        await m.addColumn(schema.userAvatar, schema.userAvatar.imageUrl);
        info('migrating database schema from 6 to 7... ok!');
      },
      from7To8: (m, schema) async {
        info('migrating database schema from 7 to 8...');
        await m.create(schema.avatarHistory);
        await m.create(schema.fastRateTemplate);
        await m.create(schema.fastReplyTemplate);
        info('migrating database schema from 7 to 8... ok!');
      },
      from8To9: (m, schema) async {
        info('migrating database schema from 8 to 9...');
        await m.addColumn(schema.settings, schema.settings.stringListValue);
        await m.addColumn(schema.settings, schema.settings.intListValue);
        info('migrating database schema from 8 to 9... ok!');
      },
    ),
  );
}
