part of 'homepage_bloc.dart';

/// All events happen in HomepagePage.
sealed class HomepageEvent extends Equatable {
  const HomepageEvent();

  @override
  List<Object> get props => [];
}

final class HomepageLoadRequested extends HomepageEvent {}

/// User requests to refresh homepage.
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
