import 'package:freezed_annotation/freezed_annotation.dart';

import 'thread_author.dart';

part 'post.freezed.dart';

/// Post model.
///
/// Each [Post] contains a reply.
@freezed
class Post with _$Post {
  /// Constructor.
  const factory Post({
    /// Post ID.
    required int postID,

    /// Post author, can not be null, should have avatar.
    required ThreadAuthor author,

    /// Post publish time.
    required DateTime publishTime,

    // TODO: Confirm data display.
    /// Post data.
    required String data,
  }) = _Post;
}
