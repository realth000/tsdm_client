part of 'emoji_bloc.dart';

/// Basic emoji related events.
@MappableClass()
sealed class EmojiEvent with EmojiEventMappable {}

/// Fetch emoji from server
@MappableClass()
final class EmojiFetchFromServerEvent extends EmojiEvent
    with EmojiFetchFromServerEventMappable {}

/// Fetch emoji from cache.
@MappableClass()
final class EmojiFetchFromCacheEvent extends EmojiEvent
    with EmojiFetchFromCacheEventMappable {}
