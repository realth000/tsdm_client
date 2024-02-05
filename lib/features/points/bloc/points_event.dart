part of 'points_bloc.dart';

/// Event of points statistics page.
sealed class PointsStatisticsEvent extends Equatable {
  /// Constructor.
  const PointsStatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// User required to refresh the points statistics page.
final class PointsStatisticsRefreshRequired extends PointsStatisticsEvent {}

/// Event of points changelog page.
sealed class PointsChangelogEvent extends Equatable {
  /// Constructor.
  const PointsChangelogEvent();

  @override
  List<Object?> get props => [];
}

/// User required to refresh the points changelog page.
final class PointsChangelogRefreshRequired extends PointsChangelogEvent {}

/// User required to load more page in points changelog page.
final class PointsChangelogLoadMoreRequired extends PointsChangelogEvent {
  /// Constructor.
  const PointsChangelogLoadMoreRequired(this.pageNumber);

  /// Page number to fetch data from.
  final String pageNumber;
}
