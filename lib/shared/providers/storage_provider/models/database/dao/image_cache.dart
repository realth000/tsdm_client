part of 'dao.dart';

/// DAO for table [ImageCache].
@DriftAccessor(tables: [ImageCache])
final class ImageCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ImageCacheDaoMixin {
  /// Constructor.
  ImageCacheDao(super.db);

  /// Get all image cache.
  Future<List<ImageCacheEntity>> selectAll() async {
    return select(imageCache).get();
  }

  /// Get image cache info by image's [url].
  Future<ImageCacheEntity?> selectImageCacheByUrl(String url) async {
    return (select(imageCache)..where((e) => e.url.equals(url)))
        .getSingleOrNull();
  }

  /// Save image cache info [imageCacheCompanion].
  Future<int> upsertImageCache(ImageCacheCompanion imageCacheCompanion) async {
    return into(imageCache).insertOnConflictUpdate(imageCacheCompanion);
  }

  /// Delete image cache by [url].
  Future<int> deleteImageCacheByUrl(String url) async {
    return (delete(imageCache)..where((e) => e.url.equals(url))).go();
  }

  /// Delete all records.
  Future<int> deleteAll() async {
    return delete(imageCache).go();
  }
}
