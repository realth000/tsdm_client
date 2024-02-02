import 'package:isar/isar.dart';
import 'package:tsdm_client/extensions/string.dart';

part '../../../../../generated/shared/providers/storage_provider/models/database/image_cache.g.dart';

/// Image cache schema.
@Collection()
class DatabaseImageCache {
  /// Constructor.
  DatabaseImageCache({
    required this.id,
    required this.imageUrl,
    required this.fileName,
    required this.lastCachedTime,
    required this.lastUsedTime,
  });

  /// Construct a cached image model for database from
  /// given [id] and [imageUrl].
  DatabaseImageCache.fromData({
    required this.id,
    required this.imageUrl,
    String? fileName,
    DateTime? lastCachedTime,
    DateTime? lastUsedTime,
  })  : fileName = fileName ?? imageUrl.fileNameV5(),
        lastCachedTime = lastCachedTime ?? DateTime.now(),
        lastUsedTime = lastUsedTime ?? DateTime.now();

  /// Database item id.
  @Id()
  int id;

  /// Url to get this image.
  @Index(unique: true)
  String imageUrl;

  /// File name when save as file cache.
  String fileName;

  /// Last updated and cached time.
  DateTime lastCachedTime;

  /// Last visited and used time.
  DateTime lastUsedTime;
}
