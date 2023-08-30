import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/models/thread_type.freezed.dart';

/// Thread type
///
/// 宣传、心情、其他……
@freezed
class ThreadType with _$ThreadType {
  /// Constructor.
  const factory ThreadType({
    /// Display name.
    required String name,

    /// Url.
    required String url,
  }) = _ThreadType;
}

/// Parse and build [ThreadType]
ThreadType? parseThreadType(String? name, String? url) {
  if (name != null && url != null) {
    return ThreadType(name: name, url: url);
  }
  return null;
}
