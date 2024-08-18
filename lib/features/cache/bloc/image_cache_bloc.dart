import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:equatable/equatable.dart';
import 'package:tsdm_client/features/cache/models/models.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';

part 'image_cache_bloc.mapper.dart';
part 'image_cache_event.dart';
part 'image_cache_state.dart';

typedef _Emit = Emitter<ImageCacheState>;

/// Bloc of global image cache.
///
/// Use this bloc to manage web image cache.
///
/// All images can cache MUST use this bloc to generate and cache.
///
/// # Purpose
///
/// * Manage image loading requests globally. Without this bloc, image cache is
///   always ran when we have no cache at the image. But in some situations,
///   several image loading requests for a same image were sent in parallel -
///   if we have the image shown in the same page more than once. This made
///   redundant http requests and also caching progress, which need to avoid.
/// * Support image reloading. When tried to load a image and ended with failure
///   or - user wants to reload an image, this action is produced by the
///   presentation layer, a listenable image cache event stream is required so
///   that the bloc can tell widgets: "your image is reloading", "your image is
///   reloaded successfully".
///
/// # Functionality
///
/// To achieve the purpose above, this bloc is made to provide a listenable
/// stream contains "responses" to image cache requests:
///
/// * Image is cache successfully and here is its data.
/// * The latest status of the given image is not loaded/loading/loaded.
///
/// Also handle requests from the presentation layer:
///
/// * Is an image cached or not?
/// * I want to reload the image globally, refresh all listeners using it.
///
/// Besides, another global cubit is provided to widgets so that widgets outside
/// the bloc can trigger image reloading.
final class ImageCacheBloc extends Bloc<ImageCacheEvent, ImageCacheState> {
  /// Constructor.
  ImageCacheBloc(this._imageUrl, this._imageCacheRepository)
      : super(const ImageCacheInitial()) {
    _streamSubscription = _imageCacheRepository.response
        .where((e) => e.imageId == _imageUrl)
        .listen(_handleImageResponse);
    on<ImageCacheLoadRequested>(_onImageCacheLoadRequested);
    on<_ImageCacheLoadPending>(_onImageCacheLoadPending);
    on<_ImageCacheLoadSuccess>(_onImageCacheLoadSuccess);
    on<_ImageCacheLoadFailed>(_onImageCacheLoadFailed);
  }

  final ImageCacheRepository _imageCacheRepository;

  /// Subscription of image response stream.
  ///
  /// Emit state according to incoming responses.
  late final StreamSubscription<ImageCacheResponse> _streamSubscription;

  // Image url to fetch the data.
  final String _imageUrl;

  void _handleImageResponse(ImageCacheResponse resp) {
    switch (resp) {
      case ImageCacheLoadingResponse():
        add(const _ImageCacheLoadPending());
      case ImageCacheSuccessResponse(:final imageData):
        add(_ImageCacheLoadSuccess(imageData));
      case ImageCacheFailedResponse():
        add(const _ImageCacheLoadFailed());
      case ImageCacheStatusResponse(:final status, :final imageData):
        switch (status) {
          case ImageCacheStatus2.notCached:
            add(const _ImageCacheLoadFailed());
          case ImageCacheStatus2.loading:
            add(const _ImageCacheLoadPending());
          case ImageCacheStatus2.cached:
            add(_ImageCacheLoadSuccess(imageData!));
        }
    }
  }

  FutureOr<void> _onImageCacheLoadRequested(
    ImageCacheLoadRequested event,
    _Emit emit,
  ) async {
    await _imageCacheRepository.updateImageCache(_imageUrl, force: event.force);
  }

  FutureOr<void> _onImageCacheLoadPending(
    _ImageCacheLoadPending event,
    _Emit emit,
  ) async {
    emit(const ImageCacheLoading());
  }

  FutureOr<void> _onImageCacheLoadSuccess(
    _ImageCacheLoadSuccess event,
    _Emit emit,
  ) async {
    emit(ImageCacheSuccess(event.imageData));
  }

  FutureOr<void> _onImageCacheLoadFailed(
    _ImageCacheLoadFailed event,
    _Emit emit,
  ) async {
    emit(const ImageCacheFailure());
  }

  @override
  Future<void> close() async {
    await _streamSubscription.cancel();
    await super.close();
  }
}
