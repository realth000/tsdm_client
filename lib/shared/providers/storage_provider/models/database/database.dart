import 'package:drift/drift.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/connection/native.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/schema/schema.dart';

// part '../../../../../generated/shared/providers/storage_provider/models/database/database.g.dart';
part '../../../../../generated/shared/providers/storage_provider/models/database/database.g.dart';

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
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 1;
}
