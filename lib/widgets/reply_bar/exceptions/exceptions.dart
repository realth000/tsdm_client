import 'package:dart_mappable/dart_mappable.dart';

part '../../../generated/widgets/reply_bar/exceptions/exceptions.mapper.dart';

/// Failed to fetch parameters used in replying to a post.
@MappableClass()
class ReplyToPostFetchParameterFailedException
    with ReplyToPostFetchParameterFailedExceptionMappable
    implements Exception {}

/// Reply to a post, but no successful result found in response.
@MappableClass()
class ReplyToPostResultFailedException
    with ReplyToPostResultFailedExceptionMappable
    implements Exception {}

/// Reply to thread, but no successful result found in response.
@MappableClass()
class ReplyToThreadResultFailedException
    with ReplyToThreadResultFailedExceptionMappable
    implements Exception {}

/// Reply personal message, but failed in response.
@MappableClass()
class ReplyPersonalMessageFailedException
    with ReplyPersonalMessageFailedExceptionMappable
    implements Exception {
  /// Constructor.
  const ReplyPersonalMessageFailedException(this.message);

  /// Error message.
  final String message;
}
