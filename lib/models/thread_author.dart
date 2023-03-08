import 'package:freezed_annotation/freezed_annotation.dart';

part 'thread_author.freezed.dart';

/// Author of a thread.
///
/// Contains name and user page url.
@freezed
class ThreadAuthor with _$ThreadAuthor {
  /// Freezed constructor.
  const factory ThreadAuthor({
    /// User name.
    required String name,

    /// User homepage url.
    required String url,

    /// User avatar, may be null.
    String? avatarUrl,
  }) = _ThreadAuthor;
}
