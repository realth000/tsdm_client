part of 'schema.dart';

/// Table for image cache.
///
/// Store cached image's info including url and cache file location.
@DataClassName('ImageEntity')
class Image extends Table {
  /// Image url.
  TextColumn get url => text()();

  /// Cache file name.
  TextColumn get fileName => text()();

  /// Last updated and cached time.
  DateTimeColumn get lastCachedTime => dateTime()();

  /// Last visited and used time.
  DateTimeColumn get lastUsedTime => dateTime()();

  /// Usage of the image.
  IntColumn get usage => intEnum<ImageUsage>().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {url};
}
