part of 'models.dart';

/// A list of recommended thread with grouped name in the website homepage.
@MappableClass()
final class PinnedThreadGroup with PinnedThreadGroupMappable {
  /// Constructor.
  const PinnedThreadGroup({required this.title, required this.threadList});

  /// Title of this thread group.
  final String title;

  /// List of threads in this group.
  final List<PinnedThread> threadList;
}
