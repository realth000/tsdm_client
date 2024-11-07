import 'package:drift_dev/api/migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsdm_client/shared/providers/storage_provider/models/database/database.dart';

import '../data/generated_migrations/schema.dart';

void main() {
  test('upgrade from 1 to 2', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('upgrade from 2 to 3', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(2);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 3);
    await db.close();
  });

  test('upgrade from 3 to 4', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(3);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 4);
    await db.close();
  });

  test('upgrade from 4 to 5', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(4);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 5);
    await db.close();
  });

  test('upgrade from 5 to 6', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(5);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 6);
    await db.close();
  });
}
