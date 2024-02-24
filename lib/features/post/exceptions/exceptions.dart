import 'package:dart_mappable/dart_mappable.dart';

part '../../../generated/features/post/exceptions/exceptions.mapper.dart';

/// Exceptions used in editing post.
@MappableClass()
sealed class PostEditException
    with PostEditExceptionMappable
    implements Exception {
  /// Constructor.
  const PostEditException() : super();
}

/// Failed to upload edit result.
@MappableClass()
final class PostEditFailedToUploadResult extends PostEditException
    with PostEditFailedToUploadResultMappable {
  /// Constructor.
  const PostEditFailedToUploadResult(this.errorText) : super();

  /// Html element contains the error message.
  final String errorText;
}
