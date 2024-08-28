part of 'thread_publish_bloc.dart';

/// Base event.
@MappableClass()
sealed class ThreadPubEvent with ThreadPubEventMappable {
  /// Constructor.
  const ThreadPubEvent();
}

/// Fetch required info for publishing, including form hash, post time and more.
@MappableClass()
final class ThreadPubFetchInfoRequested extends ThreadPubEvent
    with ThreadPubFetchInfoRequestedMappable {
  /// Constructor.
  const ThreadPubFetchInfoRequested({required this.fid});

  /// Forum id.
  final String fid;
}

/// Post a new thread to forum.
@MappableClass()
final class ThreadPubPostThread extends ThreadPubEvent
    with ThreadPubPostThreadMappable {
  /// Constructor.
  const ThreadPubPostThread(this.info);

  /// All info to post in body.
  final ThreadPublishInfo info;
}
