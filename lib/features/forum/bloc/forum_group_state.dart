part of 'forum_group_bloc.dart';

/// The base class.
@MappableClass()
sealed class ForumGroupBaseState with ForumGroupBaseStateMappable {
  /// Constructor.
  const ForumGroupBaseState();
}

/// The initial state.
@MappableClass()
final class ForumGroupInitial extends ForumGroupBaseState with ForumGroupInitialMappable {
  /// Constructor.
  const ForumGroupInitial();
}

/// Loading data.
@MappableClass()
final class ForumGroupLoading extends ForumGroupBaseState with ForumGroupLoadingMappable {
  /// Constructor.
  const ForumGroupLoading();
}

/// Successfully loaded group page.
@MappableClass()
final class ForumGroupSuccess extends ForumGroupBaseState with ForumGroupSuccessMappable {
  /// Constructor.
  const ForumGroupSuccess(this.forumGroup);

  /// The parsed forum group info.
  final ForumGroup forumGroup;
}

/// Failed to load group page.
@MappableClass()
final class ForumGroupFailure extends ForumGroupBaseState with ForumGroupFailureMappable {
  /// Constructor.
  const ForumGroupFailure();
}
