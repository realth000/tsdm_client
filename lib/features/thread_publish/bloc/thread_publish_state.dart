part of 'thread_publish_bloc.dart';

/// Status of thread publish.
enum ThreadPubStatus {
  /// Initial state.
  initial,

  /// Loading form info required in posting thread.
  loadingInfo,

  /// Info fetched and waiting for post action.
  readyToPost,

  /// Posting data.
  posting,

  /// Post data success.
  success,

  /// Failed to load info or post thread.
  failure,
}

/// State of thread publish
@MappableClass()
final class ThreadPubState with ThreadPubStateMappable {
  /// Constructor.
  const ThreadPubState({
    required this.status,
    this.forumHash,
    this.postTime,
    this.redirectUrl,
  });

  /// Status.
  final ThreadPubStatus status;

  /// Form hash.
  final String? forumHash;

  /// Thread post time.
  final String? postTime;

  /// Url of the published thread page when publish succeed.
  final String? redirectUrl;
}
