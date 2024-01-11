import 'package:equatable/equatable.dart';
import 'package:tsdm_client/features/homepage/models/pinned_thread.dart';

/// A list of recommended thread with grouped name in the website homepage.
final class PinnedThreadGroup extends Equatable {
  const PinnedThreadGroup({required this.title, required this.threadList});

  /// Title of this thread group.
  final String title;

  /// List of threads in this group.
  final List<PinnedThread> threadList;

  @override
  List<Object> get props => [threadList];
}
