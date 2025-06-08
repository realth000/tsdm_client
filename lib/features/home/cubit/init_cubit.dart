import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'init_cubit.mapper.dart';
part 'init_state.dart';

/// Cubit to do some initializing work during app start.
final class InitCubit extends Cubit<InitState> with LoggerMixin {
  /// Constructor.
  InitCubit() : super(const InitState());

  /// Delete legacy data used in version v0.x.
  Future<void> deleteV0LegacyData() async {
    final v0IsarDb = File('${(await getApplicationSupportDirectory()).path}/db/main.isar');
    if (!v0IsarDb.existsSync()) {
      return;
    }
    await v0IsarDb.delete();

    final v0IsarDbLock = File('${v0IsarDb.path}-lck');
    if (v0IsarDbLock.existsSync()) {
      await v0IsarDbLock.delete();
    }

    final v0ImageCacheDir = Directory('${(await getApplicationCacheDirectory()).path}/images');
    if (v0ImageCacheDir.existsSync()) {
      await v0ImageCacheDir.list(recursive: true).forEach((e) => e.delete());
    }

    emit(state.copyWith(v0LegacyDataDeleted: true));
  }

  /// Clear image cache with older not-used-time than [duration]
  Future<void> autoClearImageCache(Duration duration) async {
    final cacheProvider = getIt.get<ImageCacheProvider>();
    final outdateTime = DateTime.now().subtract(duration);
    debug('deleting outdated image, outdateTime=$outdateTime');
    final clearCount = await cacheProvider.clearOutdatedCache(outdateTime);
    emit(state.copyWith(clearingOutdatedImageCache: false));
    debug('deleted outdated image cache count $clearCount');
  }

  /// Skip the clear image cache process.
  void skipAutoClearImageCache() {
    debug('skip auto clear image cache');
    emit(state.copyWith(clearingOutdatedImageCache: false));
  }
}
