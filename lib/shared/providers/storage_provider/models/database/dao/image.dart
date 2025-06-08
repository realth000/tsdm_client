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
  ///
  /// If you are sure to update only part of fields for an item in database, use [updateImageCache].
  Future<int> upsertImageCache(ImageCompanion imageCompanion) async {
    return into(image).insertOnConflictUpdate(imageCompanion);
  }

  /// Update part of the image cache info.
  ///
  /// Not all fields are required, unlike [upsertImageCache].
  Future<int> updateImageCache({
    required String url,
    String? fileName,
    DateTime? lastCachedTime,
    DateTime? lastUsedTime,
    ImageUsage? usage,
  }) async {
    final curr = await selectImageByUrl(url);
    if (curr == null) {
      return 0;
    }

    return (update(image)..where((e) => e.url.equals(url))).write(
      curr
          .toCompanion(false)
          .copyWith(
            fileName: Value(fileName ?? curr.fileName),
            lastCachedTime: Value(lastCachedTime ?? curr.lastCachedTime),
            lastUsedTime: Value(lastUsedTime ?? curr.lastUsedTime),
            usage: Value(usage ?? curr.usage),
          ),
    );
  }

  /// Delete image cache by [url].
  Future<int> deleteImageByUrl(String url) async {
    return (delete(image)..where((e) => e.url.equals(url))).go();
  }

  /// Delete all records.
  Future<int> deleteAll() async {
    return delete(image).go();
  }

  /// Delete image cache have an older last used time than [dateTime].
  Future<List<ImageEntity>> deleteByLastUsedDuration(DateTime dateTime) async {
    return (delete(image)..where((e) => e.lastUsedTime.isSmallerOrEqualValue(dateTime))).goAndReturn();
  }
}
