part of 'post_edit_bloc.dart';

/// Status of editing a post.
@MappableEnum()
enum PostEditStatus {
  /// Initial.
  initial,

  /// Loading data or posting edit result.
  loading,

  /// Post edit result success.
  success,

  /// Failed to post the edit result to server.
  failed,
}

/// State of mappable.
@MappableClass()
final class PostEditState with PostEditStateMappable {
  /// Constructor.
  const PostEditState({
    this.status = PostEditStatus.initial,
    this.content,
  });

  /// Status.
  final PostEditStatus status;

  /// Post content.
  final PostEditContent? content;
}
