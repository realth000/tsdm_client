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
    this.forumName,
    this.content,
    this.errorText,
    this.threadPublishInfo,
    this.redirectTid,
  });

  /// Status.
  final PostEditStatus status;

  /// Forum name as hint when publishing thread.
  final String? forumName;

  /// Post content.
  final PostEditContent? content;

  /// Error text html element.
  ///
  /// Use this to show the error message.
  final String? errorText;

  /// Information used in publishing thread.
  final ThreadPublishInfo? threadPublishInfo;

  /// Thread id of new published thread after publish succeeded.
  ///
  /// Redirect to this page.
  final String? redirectTid;
}
