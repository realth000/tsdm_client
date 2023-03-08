import 'package:freezed_annotation/freezed_annotation.dart';

import 'post.dart';

part 'thread_data.freezed.dart';

/// Data of each thread.
@freezed
class ThreadData with _$ThreadData {
  /// Constructor.
  const factory ThreadData({
    /// Thread ID.
    required int threadID,

    /// Thread title.
    required String title,

    /// Total reply count.
    required int replyCount,

    /// Total view times count.
    required int viewCount,

    /// [Post] list.
    required List<Post> postList,
  }) = _ThreadData;
}
