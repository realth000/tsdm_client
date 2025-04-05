import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';

part 'image_cache_trigger_cubit.mapper.dart';

part 'image_cache_trigger_state.dart';

/// Global cubit as a trigger to enable widgets triggering image reload.
///
/// Just a wrapper outside the internal repository.
class ImageCacheTriggerCubit extends Cubit<ImageCacheTriggerState> {
  /// Constructor.
  ImageCacheTriggerCubit(this._imageCacheRepository) : super(ImageCacheTriggerState());

  final ImageCacheRepository _imageCacheRepository;

  /// Trigger reloading process for given image [url].
  void updateImageCache(String url, {bool force = false}) {
    _imageCacheRepository.updateImageCache(url, force: force);
  }
}
