import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:tsdm_client/instance.dart';

/// Connect to database.
DatabaseConnection connect() => DatabaseConnection.delayed(
      Future(
        () async {
          talker.debug('start web connection');
          final result = await WasmDatabase.open(
            databaseName: 'main_v2_db',
            sqlite3Uri: Uri.parse('sqlite3.wasm'),
            driftWorkerUri: Uri.parse('drift_worker.dart.js'),
          );
          if (result.missingFeatures.isNotEmpty) {
            // Depending how central local persistence is to your app, you may
            // want to show a warning to the user if only unreliable
            // implementations are available.
            talker.error(
                'Using ${result.chosenImplementation} due to missing browser '
                'features: ${result.missingFeatures}');
          }

          talker.debug('built web connection');
          return result.resolvedExecutor;
        },
      ),
    );

/// Required function.
Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // Unfortunately, validating database schemas only works for native platforms
  // right now.
  // As we also have migration tests (see the `Testing migrations` section in
  // the readme of this example), this is not a huge issue.
}
