import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part '../../generated/models/database/image_cache.g.dart';

/// Image cache schema.
@Collection()
class DatabaseImageCache {
  DatabaseImageCache({
    required this.id,
    required this.imageUrl,
    required this.fileName,
    required this.lastCachedTime,
    required this.lastUsedTime,
  });

  DatabaseImageCache.fromData({
    required this.id,
    required this.imageUrl,
    String? fileName,
    DateTime? lastCachedTime,
    DateTime? lastUsedTime,
  })  : fileName = fileName ?? const Uuid().v5(Uuid.NAMESPACE_URL, imageUrl),
        lastCachedTime = lastCachedTime ?? DateTime.now(),
        lastUsedTime = lastUsedTime ?? DateTime.now();

  @Id()
  int id;

  @Index(unique: true)
  String imageUrl;

  String fileName;

  DateTime lastCachedTime;

  DateTime lastUsedTime;
}
