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
    this.recentChangelog = const [],
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
  /// For full changelog, see [PointsChangelogState.fullChangelog].
  final List<PointsChange> recentChangelog;

  /// Copy with
  PointsStatisticsState copyWith({
    PointsStatus? status,
    Map<String, String>? pointsMap,
    List<PointsChange>? recentChangelog,
  }) {
    return PointsStatisticsState(
      status: status ?? this.status,
      pointsMap: pointsMap ?? this.pointsMap,
      recentChangelog: recentChangelog ?? this.recentChangelog,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pointsMap,
        recentChangelog,
      ];
}

/// State of points changelog page.
final class PointsChangelogState extends Equatable {
  /// Constructor.
  const PointsChangelogState({
    this.status = PointsStatus.initial,
    this.parameter = const ChangelogParameter.empty(),
    this.fullChangelog = const [],
    this.allParameters = const ChangelogAllParameters.empty(),
    this.currentPage = 1,
    this.totalPages = 1,
  });

  /// Status.
  final PointsStatus status;

  /// A list of changes event on user's points.
  ///
  /// This field contains all queried changes on user's points, may contains
  /// a long period.
  ///
  /// For recent changes, see [PointsStatisticsState.recentChangelog].
  final List<PointsChange> fullChangelog;

  /// Current page number of user's points changelog page.
  final int currentPage;

  /// Total pages count of user's points changelog page.
  final int totalPages;

  /// Parameters used to do the changelog query.
  final ChangelogParameter parameter;

  /// All available parameters that can fill in the query filter.
  ///
  /// Some parameters in query filters are choices provided by the server side.
  /// This parameter holds those parameters.
  ///
  /// e.g. points type, operation type, points change type.
  ///
  /// Also there are some parameters that not came from the server side.
  ///
  /// e.g. start time, end time.
  final ChangelogAllParameters allParameters;

  /// Copy with.
  PointsChangelogState copyWith({
    PointsStatus? status,
    ChangelogParameter? parameter,
    ChangelogAllParameters? allParameters,
    List<PointsChange>? fullChangelog,
    int? currentPage,
    int? totalPages,
  }) {
    return PointsChangelogState(
      status: status ?? this.status,
      parameter: parameter ?? this.parameter,
      allParameters: allParameters ?? this.allParameters,
      fullChangelog: fullChangelog ?? this.fullChangelog,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
        status,
        parameter,
        allParameters,
        fullChangelog,
        currentPage,
        totalPages,
      ];
}
