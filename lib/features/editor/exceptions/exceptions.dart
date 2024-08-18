import 'package:dart_mappable/dart_mappable.dart';

part 'exceptions.mapper.dart';

/// Basic exception related to emoji.
@MappableClass()
sealed class EmojiRelatedException
    with EmojiRelatedExceptionMappable
    implements Exception {}

/// Failed to load emoji
@MappableClass()
final class EmojiLoadFailedException extends EmojiRelatedException
    with EmojiLoadFailedExceptionMappable {}
