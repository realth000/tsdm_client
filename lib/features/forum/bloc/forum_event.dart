part of 'forum_bloc.dart';

sealed class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

final class ForumRefreshRequested extends ForumEvent {}

/// User requested to load page [pageNumber].
final class ForumLoadMoreRequested extends ForumEvent {
  const ForumLoadMoreRequested(this.pageNumber) : super();

  final int pageNumber;
}

/// User request to jump to another page.
final class ForumJumpPageRequested extends ForumEvent {
  const ForumJumpPageRequested(this.pageNumber) : super();
  final int pageNumber;
}
