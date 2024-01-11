import 'package:flutter/foundation.dart';

/// Thread type
///
/// 宣传、心情、其他……
@immutable
class ThreadType {
  /// Constructor.
  const ThreadType({
    required this.name,
    required this.url,
  });

  /// Display name.
  final String name;

  /// Url.
  final String url;
}

/// Parse and build [ThreadType]
ThreadType? parseThreadType(String? name, String? url) {
  if (name != null && url != null) {
    return ThreadType(name: name, url: url);
  }
  return null;
}
