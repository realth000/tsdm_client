part of 'forum_group_bloc.dart';

/// Basic event.
@MappableClass()
sealed class ForumGroupBaseEvent with ForumGroupBaseEventMappable {
  /// Constructor.
  const ForumGroupBaseEvent();
}

/// Load the data on a group
@MappableClass()
final class ForumGroupLoadRequested extends ForumGroupBaseEvent with ForumGroupLoadRequestedMappable {
  /// Constructor.
  const ForumGroupLoadRequested(this.gid);

  /// The id of group to load.
  final String gid;
}
