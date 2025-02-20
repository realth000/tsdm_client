part of 'post_edit_bloc.dart';

/// Event of editing post.
@MappableClass()
sealed class PostEditEvent with PostEditEventMappable {
  /// Constructor.
  const PostEditEvent();
}

/// User requested to load the data to edit.
@MappableClass()
final class PostEditLoadDataRequested extends PostEditEvent with PostEditLoadDataRequestedMappable {
  /// Constructor.
  const PostEditLoadDataRequested(this.editUrl) : super();

  /// Url to get the edit content data.
  final String editUrl;
}

/// User completed the editing and need to post to the server.
@MappableClass()
final class PostEditCompleteEditRequested extends PostEditEvent with PostEditCompleteEditRequestedMappable {
  /// Constructor.
  const PostEditCompleteEditRequested({
    required this.formHash,
    required this.postTime,
    required this.delattachop,
    required this.wysiwyg,
    required this.fid,
    required this.tid,
    required this.pid,
    required this.page,
    required this.threadType,
    required this.threadTitle,
    required this.data,
    required this.options,
    required this.save,
    required this.perm,
    required this.price,
  }) : super();

  /// Form hash.
  final String formHash;

  /// Post time.
  final String postTime;

  /// Delattachop.
  final String delattachop;

  /// What you see is what you get.
  ///
  /// "0".
  final String wysiwyg;

  /// Forum id.
  final String fid;

  /// Thread id.
  final String tid;

  /// Post id.
  final String pid;

  /// Page.
  ///
  /// Provided by server.
  final String page;

  /// Thread type.
  ///
  /// Only needed when editing or creating a new thread.
  final PostEditThreadType? threadType;

  /// Thread title.
  ///
  /// Only needed when editing or creating a new thread.
  final String? threadTitle;

  /// Post data, or first floor post data when submitting a thread.
  final String data;

  /// Additional options provided by server.
  final List<PostEditContentOption> options;

  /// Save post as draft or publish as new thread.
  ///
  /// Only set to "1" when editing thread in draft state.
  final String save;

  /// Optional permission required to access this thread.
  final String? perm;

  /// Optional thread price.
  final int? price;
}

/// Fetch required info for publishing, including form hash, post time and more.
@MappableClass()
final class ThreadPubFetchInfoRequested extends PostEditEvent with ThreadPubFetchInfoRequestedMappable {
  /// Constructor.
  const ThreadPubFetchInfoRequested({required this.fid});

  /// Forum id.
  final String fid;
}

/// Post a new thread to forum.
@MappableClass()
final class ThreadPubPostThread extends PostEditEvent with ThreadPubPostThreadMappable {
  /// Constructor.
  const ThreadPubPostThread(this.info);

  /// All info to post in body.
  final ThreadPublishInfo info;
}
