import 'package:drift/drift.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/connection/connection.dart'
    as conn;
import 'package:tsdm_client/shared/providers/storage_provider/models/database/schema/schema.dart';

// part 'database.g.dart';
part 'database.g.dart';

/// 数据库定义
@DriftDatabase(
  tables: [
    Cookie,
    ImageCache,
    Settings,
  ],
)
final class AppDatabase extends _$AppDatabase {
  /// Constructor.
  ///
  /// Dart analyzer does not work on conditional export.
  // ignore: undefined_function
  AppDatabase() : super(conn.connect());

  @override
  int get schemaVersion => 1;
}
