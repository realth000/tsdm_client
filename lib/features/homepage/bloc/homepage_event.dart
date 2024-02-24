part of 'homepage_bloc.dart';

/// All events happen in HomepagePage.
@MappableClass()
sealed class HomepageEvent with HomepageEventMappable {
  const HomepageEvent();
}

/// User request to load the homepage.
///
/// This will load from cache if available.
@MappableClass()
final class HomepageLoadRequested extends HomepageEvent
    with HomepageLoadRequestedMappable {}

/// User requests to refresh homepage.
///
/// Directly load homepage from server.
@MappableClass()
final class HomepageRefreshRequested extends HomepageEvent
    with HomepageRefreshRequestedMappable {}

/// User requests to login.
@MappableClass()
final class HomepageLoginRequested extends HomepageEvent
    with HomepageLoginRequestedMappable {}

/// Current logged user changed.
///
/// This is a passive event.
@MappableClass()
final class HomepageAuthChanged extends HomepageEvent
    with HomepageAuthChangedMappable {
  /// Constructor.
  const HomepageAuthChanged({required this.isLogged}) : super();

  /// Flag indicating logged in or not.
  final bool isLogged;
}
