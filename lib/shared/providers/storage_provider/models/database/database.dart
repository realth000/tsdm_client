import 'package:drift/drift.dart';
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
    Cookie,
    ImageCache,
    Settings,
    ThreadVisitHistory,
  ],
)
final class AppDatabase extends _$AppDatabase with LoggerMixin {
  /// Constructor.
  ///
  /// Dart analyzer does not work on conditional export.
  // ignore: undefined_function
  AppDatabase() : super(conn.connect());

  @override
  int get schemaVersion => 2;

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
        ),
      );
}
