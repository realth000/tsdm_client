part of 'topics_bloc.dart';

/// Event of topics page.
@MappableClass()
sealed class TopicsEvent with TopicsEventMappable {
  const TopicsEvent();
}

/// User requested to load page.
///
/// Load from cache if available.
@MappableClass()
final class TopicsLoadRequested extends TopicsEvent
    with TopicsLoadRequestedMappable {}

/// User requested to refresh page.
///
/// Directly load from server.
@MappableClass()
final class TopicsRefreshRequested extends TopicsEvent
    with TopicsRefreshRequestedMappable {}

/// User changed the current tab.
@MappableClass()
final class TopicsTabSelected extends TopicsEvent
    with TopicsTabSelectedMappable {
  /// Constructor.
  const TopicsTabSelected(this.tabIndex) : super();

  /// Current tab index.
  final int tabIndex;
}
