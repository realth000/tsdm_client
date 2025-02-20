part of 'forum_bloc.dart';

/// Forum event.
@MappableClass()
sealed class ForumEvent with ForumEventMappable {
  const ForumEvent();
}

/// User request to refresh the forum page.
@MappableClass()
final class ForumRefreshRequested extends ForumEvent with ForumRefreshRequestedMappable {}

/// User requested to load page [pageNumber].
@MappableClass()
final class ForumLoadMoreRequested extends ForumEvent with ForumLoadMoreRequestedMappable {
  /// Constructor.
  const ForumLoadMoreRequested(this.pageNumber) : super();

  /// Page number to load.
  final int pageNumber;
}

/// User request to jump to another page.
@MappableClass()
final class ForumJumpPageRequested extends ForumEvent with ForumJumpPageRequestedMappable {
  /// Constructor.
  const ForumJumpPageRequested(this.pageNumber) : super();

  /// Page number to jump to.
  final int pageNumber;
}

/// User requested to change the current thread filter state.
@MappableClass()
final class ForumChangeThreadFilterStateRequested extends ForumEvent
    with ForumChangeThreadFilterStateRequestedMappable {
  /// Constructor.
  const ForumChangeThreadFilterStateRequested(this.filterState);

  /// [FilterState] to change to.
  final FilterState filterState;
}
