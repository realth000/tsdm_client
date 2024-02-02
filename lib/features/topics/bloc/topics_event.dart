part of 'topics_bloc.dart';

/// Event of topics page.
sealed class TopicsEvent extends Equatable {
  const TopicsEvent();

  @override
  List<Object?> get props => [];
}

/// User requested to load page.
///
/// Load from cache if available.
final class TopicsLoadRequested extends TopicsEvent {}

/// User requested to refresh page.
///
/// Directly load from server.
final class TopicsRefreshRequested extends TopicsEvent {}

/// User changed the current tab.
final class TopicsTabSelected extends TopicsEvent {
  /// Constructor.
  const TopicsTabSelected(this.tabIndex) : super();

  /// Current tab index.
  final int tabIndex;
}
