part of 'thread_bloc_v2.dart';

/// Base class of all thread events v2.
@MappableClass()
sealed class ThreadV2Event with ThreadV2EventMappable {
  /// Constructor.
  const ThreadV2Event();
}

/// Load data in a previous page.
///
/// Actually this event means loading the previous page before the current
/// page range.
@MappableClass()
final class ThreadV2LoadPrevPageRequested extends ThreadV2Event with ThreadV2LoadPrevPageRequestedMappable {
  /// Constructor.
  const ThreadV2LoadPrevPageRequested();
}

/// Load data in the next page.
///
/// Actually this event means loading the next page after the current
/// page range.
@MappableClass()
final class ThreadV2LoadNextPageRequested extends ThreadV2Event with ThreadV2LoadNextPageRequestedMappable {
  /// Constructor.
  const ThreadV2LoadNextPageRequested();
}

/// Jump to a certain page.
@MappableClass()
final class ThreadV2JumpPageRequested extends ThreadV2Event with ThreadV2JumpPageRequestedMappable {
  /// Constructor.
  const ThreadV2JumpPageRequested(this.page);

  /// Page number to jump.
  final int page;
}
