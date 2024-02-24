part of 'points_bloc.dart';

/// Event of points statistics page.
@MappableClass()
sealed class PointsStatisticsEvent with PointsStatisticsEventMappable {
  /// Constructor.
  const PointsStatisticsEvent();
}

/// User required to refresh the points statistics page.
@MappableClass()
final class PointsStatisticsRefreshRequested extends PointsStatisticsEvent
    with PointsStatisticsRefreshRequestedMappable {}

/// Event of points changelog page.
@MappableClass()
sealed class PointsChangelogEvent with PointsChangelogEventMappable {
  /// Constructor.
  const PointsChangelogEvent();
}

/// User requested to refresh the points changelog page.
@MappableClass()
final class PointsChangelogRefreshRequested extends PointsChangelogEvent
    with PointsChangelogRefreshRequestedMappable {}

/// User requested to load more page in points changelog page.
@MappableClass()
final class PointsChangelogLoadMoreRequested extends PointsChangelogEvent
    with PointsChangelogLoadMoreRequestedMappable {
  /// Constructor.
  const PointsChangelogLoadMoreRequested(this.pageNumber);

  /// Page number to fetch data from.
  final int pageNumber;
}

/// User requested to jump to another page.
@MappableClass()
final class PointsChangelogJumpPageRequested extends PointsChangelogEvent
    with PointsChangelogJumpPageRequestedMappable {
  /// Constructor.
  const PointsChangelogJumpPageRequested(this.pageNumber);

  /// Page number to jump to.
  final int pageNumber;
}

/// User requested to do a query action with given [parameter].
@MappableClass()
final class PointsChangelogQueryRequested extends PointsChangelogEvent
    with PointsChangelogQueryRequestedMappable {
  /// Constructor.
  const PointsChangelogQueryRequested(this.parameter);

  /// Parameter to use in query.
  final ChangelogParameter parameter;
}
