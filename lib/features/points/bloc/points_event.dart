part of 'points_bloc.dart';

/// Event of points statistics page.
sealed class PointsStatisticsEvent extends Equatable {
  /// Constructor.
  const PointsStatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// User required to refresh the points statistics page.
final class PointsStatisticsRefreshRequested extends PointsStatisticsEvent {}

/// Event of points changelog page.
sealed class PointsChangelogEvent extends Equatable {
  /// Constructor.
  const PointsChangelogEvent();

  @override
  List<Object?> get props => [];
}

/// User requested to refresh the points changelog page.
final class PointsChangelogRefreshRequested extends PointsChangelogEvent {}

/// User requested to load more page in points changelog page.
final class PointsChangelogLoadMoreRequested extends PointsChangelogEvent {
  /// Constructor.
  const PointsChangelogLoadMoreRequested(this.pageNumber);

  /// Page number to fetch data from.
  final int pageNumber;
}

/// User requested to jump to another page.
final class PointsChangelogJumpPageRequested extends PointsChangelogEvent {
  /// Constructor.
  const PointsChangelogJumpPageRequested(this.pageNumber);

  /// Page number to jump to.
  final int pageNumber;
}
