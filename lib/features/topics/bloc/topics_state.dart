part of 'topics_bloc.dart';

/// Data status of the homepage of the app (the first tab in home).
enum TopicsStatus {
  /// Initial state.
  initial,

  /// Loading the page.
  loading,

  /// Load data finished.
  success,

  /// Failed to load data.
  failed;

  /// Is [initial].
  bool get isInitial => this == TopicsStatus.initial;

  /// Is [loading].
  bool get isLoading => this == TopicsStatus.loading;

  /// Is [success].
  bool get isSuccess => this == TopicsStatus.success;

  /// Is [failed].
  bool get isFailed => this == TopicsStatus.failed;
}

/// State of topics page.
final class TopicsState extends Equatable {
  /// Constructor.
  const TopicsState({
    this.status = TopicsStatus.initial,
    this.topicsTab = 0,
    this.forumGroupList = const [],
  });

  /// Status.
  final TopicsStatus status;

  /// Current tab index.
  final int topicsTab;

  /// All forums to show.
  final List<ForumGroup> forumGroupList;

  /// Copy with.
  TopicsState copyWith({
    TopicsStatus? status,
    int? topicsTab,
    List<ForumGroup>? forumGroupList,
  }) {
    return TopicsState(
      status: status ?? this.status,
      topicsTab: topicsTab ?? this.topicsTab,
      forumGroupList: forumGroupList ?? this.forumGroupList,
    );
  }

  @override
  List<Object?> get props => [status, forumGroupList];
}
