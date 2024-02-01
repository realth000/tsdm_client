part of 'homepage_bloc.dart';

/// All events happen in HomepagePage.
sealed class HomepageEvent extends Equatable {
  const HomepageEvent();

  @override
  List<Object> get props => [];
}

/// User request to load the homepage.
///
/// This will load from cache if available.
final class HomepageLoadRequested extends HomepageEvent {}

/// User requests to refresh homepage.
///
/// Directly load homepage from server.
final class HomepageRefreshRequested extends HomepageEvent {}

/// User requests to login.
final class HomepageLoginRequested extends HomepageEvent {}

/// Current logged user changed.
///
/// This is a passive event.
final class _HomepageAuthChanged extends HomepageEvent {
  const _HomepageAuthChanged({required this.isLogged}) : super();
  final bool isLogged;

  @override
  List<Object> get props => [isLogged];
}
