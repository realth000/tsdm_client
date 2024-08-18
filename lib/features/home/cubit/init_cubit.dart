import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:path_provider/path_provider.dart';

part 'init_cubit.mapper.dart';
part 'init_state.dart';

/// Cubit to do some initializing work during app start.
final class InitCubit extends Cubit<InitState> {
  /// Constructor.
  InitCubit() : super(const InitState());

  /// Delete legacy data used in version v0.x.
  Future<void> deleteV0LegacyData() async {
    final v0IsarDb =
        File('${(await getApplicationSupportDirectory()).path}/db/main.isar');
    if (!v0IsarDb.existsSync()) {
      return;
    }
    await v0IsarDb.delete();

    final v0IsarDbLock = File('${v0IsarDb.path}-lck');
    if (v0IsarDbLock.existsSync()) {
      await v0IsarDbLock.delete();
    }

    final v0ImageCacheDir =
        Directory('${(await getApplicationCacheDirectory()).path}/images');
    if (v0ImageCacheDir.existsSync()) {
      await v0ImageCacheDir.list(recursive: true).forEach((e) => e.delete());
    }

    emit(state.copyWith(v0LegacyDataDeleted: true));
  }
}
