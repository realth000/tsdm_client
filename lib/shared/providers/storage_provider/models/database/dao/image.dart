part of 'dao.dart';

/// DAO for table [Image].
@DriftAccessor(tables: [Image])
final class ImageDao extends DatabaseAccessor<AppDatabase> with _$ImageDaoMixin {
  /// Constructor.
  ImageDao(super.db);

  /// Get all image cache.
  Future<List<ImageEntity>> selectAll() async {
    return select(image).get();
  }

  /// Get image cache info by image's [url].
  Future<ImageEntity?> selectImageByUrl(String url) async {
    return (select(image)..where((e) => e.url.equals(url))).getSingleOrNull();
  }

  /// Save image cache info [imageCompanion].
  Future<int> upsertImageCache(ImageCompanion imageCompanion) async {
    return into(image).insertOnConflictUpdate(imageCompanion);
  }

  /// Delete image cache by [url].
  Future<int> deleteImageByUrl(String url) async {
    return (delete(image)..where((e) => e.url.equals(url))).go();
  }

  /// Delete all records.
  Future<int> deleteAll() async {
    return delete(image).go();
  }
}
