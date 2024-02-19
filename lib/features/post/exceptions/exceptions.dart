/// Exceptions used in editing post.
sealed class PostEditException implements Exception {
  /// Constructor.
  const PostEditException() : super();
}

/// Failed to upload edit result.
final class PostEditFailedToUploadResult extends PostEditException {
  /// Constructor.
  const PostEditFailedToUploadResult(this.errorText) : super();

  /// Html element contains the error message.
  final String errorText;
}
