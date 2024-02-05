part of 'points_bloc.dart';

/// State of current user points.
enum PointsStatus {
  /// Initial.
  initial,

  /// Loading data.
  loading,

  /// Load succeed.
  success,

  /// Load failed.
  failed,
}

/// State of user points statistics page.
///
/// This page has no pagination and the length of points changelog is expected
/// to no more than 10.
final class PointsStatisticsState extends Equatable {
  /// Constructor.
  const PointsStatisticsState({
    this.status = PointsStatus.initial,
    this.pointsMap = const {},
    this.pointsRecentChangelog = const [],
  });

  /// Status.
  final PointsStatus status;

  /// Map of user's different attributes points.
  ///
  /// With `name` and `value`.
  final Map<String, String> pointsMap;

  /// A list of changes event on user's points.
  ///
  /// But this field only contains recent changes that shows in user's points
  /// page.
  ///
  /// The length is expected to be no more than 10.
  ///
  /// For full changelog, see [PointsChangelogState.pointsFullChangelog].
  final List<PointsChange> pointsRecentChangelog;

  /// Copy with
  PointsStatisticsState copyWith({
    PointsStatus? status,
    Map<String, String>? pointsMap,
    List<PointsChange>? pointsRecentChangelog,
  }) {
    return PointsStatisticsState(
      status: status ?? this.status,
      pointsMap: pointsMap ?? this.pointsMap,
      pointsRecentChangelog:
          pointsRecentChangelog ?? this.pointsRecentChangelog,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pointsMap,
        pointsRecentChangelog,
      ];
}

/// State of points changelog page.
final class PointsChangelogState extends Equatable {
  /// Constructor.
  const PointsChangelogState({
    this.status = PointsStatus.initial,
    this.pointsFullChangelog = const [],
    this.pointsLogPageCurrentNumber = 1,
    this.pointsLogPageTotalNumber = 1,
  });

  /// Status.
  final PointsStatus status;

  /// A list of changes event on user's points.
  ///
  /// This field contains all queried changes on user's points, may contains
  /// a long period.
  ///
  /// For recent changes, see [PointsStatisticsState.pointsRecentChangelog].
  final List<PointsChange> pointsFullChangelog;

  /// Current page number of user's points changelog page.
  final int pointsLogPageCurrentNumber;

  /// Total pages count of user's points changelog page.
  final int pointsLogPageTotalNumber;

  /// Copy with.
  PointsChangelogState copyWith({
    List<PointsChange>? pointsFullChangelog,
    int? pointsLogPageCurrentNumber,
    int? pointsLogPageTotalNumber,
  }) {
    return PointsChangelogState(
      pointsFullChangelog: pointsFullChangelog ?? this.pointsFullChangelog,
      pointsLogPageCurrentNumber:
          pointsLogPageCurrentNumber ?? this.pointsLogPageCurrentNumber,
      pointsLogPageTotalNumber:
          pointsLogPageTotalNumber ?? this.pointsLogPageTotalNumber,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pointsFullChangelog,
        pointsLogPageCurrentNumber,
        pointsLogPageTotalNumber,
      ];
}
