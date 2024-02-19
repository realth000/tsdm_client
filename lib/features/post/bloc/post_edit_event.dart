part of 'post_edit_bloc.dart';

/// Event of editing post.
@MappableClass()
sealed class PostEditEvent with PostEditEventMappable {
  /// Constructor.
  const PostEditEvent();
}

/// User requested to load the data to edit.
@MappableClass()
final class PostEditLoadDataRequested extends PostEditEvent
    with PostEditLoadDataRequestedMappable {
  /// Constructor.
  const PostEditLoadDataRequested(this.editUrl) : super();

  /// Url to get the edit content data.
  final String editUrl;
}

/// User completed the editing and need to post to the server.
@MappableClass()
final class PostEditCompleteEditRequested extends PostEditEvent
    with PostEditCompleteEditRequestedMappable {
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
}
