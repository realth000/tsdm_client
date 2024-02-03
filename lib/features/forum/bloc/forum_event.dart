part of 'forum_bloc.dart';

/// Forum event.
sealed class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

/// User request to refresh the forum page.
final class ForumRefreshRequested extends ForumEvent {}

/// User requested to load page [pageNumber].
final class ForumLoadMoreRequested extends ForumEvent {
  /// Constructor.
  const ForumLoadMoreRequested(this.pageNumber) : super();

  /// Page number to load.
  final int pageNumber;
}

/// User request to jump to another page.
final class ForumJumpPageRequested extends ForumEvent {
  /// Constructor.
  const ForumJumpPageRequested(this.pageNumber) : super();

  /// Page number to jump to.
  final int pageNumber;
}

/// User requested to change the current thread filter state.
final class ForumChangeThreadFilterStateRequested extends ForumEvent {
  /// Constructor.
  const ForumChangeThreadFilterStateRequested(this.filterState);

  /// [FilterState] to change to.
  final FilterState filterState;
}
