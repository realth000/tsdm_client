part of 'topics_bloc.dart';

sealed class TopicsEvent extends Equatable {
  const TopicsEvent();

  @override
  List<Object?> get props => [];
}

final class TopicsLoadRequested extends TopicsEvent {}

final class TopicsRefreshRequested extends TopicsEvent {}

final class TopicsTabSelected extends TopicsEvent {
  const TopicsTabSelected(this.tabIndex) : super();
  final int tabIndex;
}
