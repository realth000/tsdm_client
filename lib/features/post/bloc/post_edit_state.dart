part of 'post_edit_bloc.dart';

/// Status of editing a post.
@MappableEnum()
enum PostEditStatus {
  /// Initial.
  initial,

  /// Loading data.
  loading,

  /// Failed to load data.
  failedToLoad,

  /// Waiting for user to edit.
  editing,

  /// Uploading data.
  uploading,

  /// Failed to load data.
  failedToUpload,

  /// Post edit result success.
  success,
}

/// State of mappable.
@MappableClass()
final class PostEditState with PostEditStateMappable {
  /// Constructor.
  const PostEditState({
    this.status = PostEditStatus.initial,
    this.content,
    this.errorText,
  });

  /// Status.
  final PostEditStatus status;

  /// Post content.
  final PostEditContent? content;

  /// Error text html element.
  ///
  /// Use this to show the error message.
  final String? errorText;
}
