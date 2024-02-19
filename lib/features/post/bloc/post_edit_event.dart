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
    with PostEditCompleteEditRequestedMappable {}
