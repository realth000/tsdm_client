part of 'schema.dart';

/// Table for image cache.
///
/// Store cached image's info including url and cache file location.
@DataClassName('ImageCacheEntity')
class ImageCache extends Table {
  /// Image url.
  TextColumn get url => text()();

  /// Cache file name.
  TextColumn get fileName => text()();

  /// Last updated and cached time.
  DateTimeColumn get lastCachedTime => dateTime()();

  /// Last visited and used time.
  DateTimeColumn get lastUsedTime => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {url};
}
