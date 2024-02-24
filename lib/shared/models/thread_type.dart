part of 'models.dart';

/// Thread type
///
/// 宣传、心情、其他……
@MappableClass()
class ThreadType with ThreadTypeMappable {
  /// Constructor.
  const ThreadType({
    required this.name,
    required this.url,
  });

  /// Parse and build [ThreadType]
  static ThreadType? parse(String? name, String? url) {
    if (name != null && url != null) {
      return ThreadType(name: name, url: url);
    }
    return null;
  }

  /// Display name.
  final String name;

  /// Url.
  final String url;
}
