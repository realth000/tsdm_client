import 'package:equatable/equatable.dart';

/// A pinned thread in home page.
///
/// Contains thread info and the author's info.
final class PinnedThread extends Equatable {
  const PinnedThread({
    required this.threadUrl,
    required this.threadTitle,
    required this.authorUrl,
    required this.authorName,
  });

  /// Url of this thread.
  final String threadUrl;

  /// Title of this thread.
  final String threadTitle;

  /// This thread's author's user space url.
  final String authorUrl;

  /// This thread's author's name.
  ///
  /// Only username here, not including avatar, user space url and other info.
  /// This is due to the web page status.
  final String authorName;

  @override
  List<Object> get props => [threadUrl, threadTitle, authorUrl, authorName];
}
