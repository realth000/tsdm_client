import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:tsdm_client/shared/models/models.dart' hide Cookie;
import 'package:tsdm_client/shared/providers/storage_provider/models/convertable/convertable.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/connection/connection.dart'
    as conn;
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
  ///
  /// Dart analyzer does not work on conditional export.
  // ignore: undefined_function
  AppDatabase() : super(conn.connect());

  @override
  int get schemaVersion => 4;

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
            await m.addColumn(schema.image, schema.image.usage);
            info('migrating database schema from 3 to 4... ok!');
          },
        ),
      );
}
