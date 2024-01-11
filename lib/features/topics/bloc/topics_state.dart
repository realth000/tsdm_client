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

  bool get isInitial => this == TopicsStatus.initial;

  bool get isLoading => this == TopicsStatus.loading;

  bool get isSuccess => this == TopicsStatus.success;

  bool get isFailed => this == TopicsStatus.failed;
}

final class TopicsState extends Equatable {
  const TopicsState({
    this.status = TopicsStatus.initial,
    this.topicsTab = 0,
    this.forumGroupList = const [],
  });

  final TopicsStatus status;

  final int topicsTab;

  final List<ForumGroup> forumGroupList;

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
  List<Object?> get props => [forumGroupList];
}
