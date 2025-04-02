part of 'switch_user_group_bloc.dart';

/// Base event of switching user group.
@MappableClass()
sealed class SwitchUserGroupBaseEvent with SwitchUserGroupBaseEventMappable {
  /// Constructor.
  const SwitchUserGroupBaseEvent();
}

/// Load available user groups info.
@MappableClass()
final class SwitchUserGroupLoadInfoRequested extends SwitchUserGroupBaseEvent
    with SwitchUserGroupLoadInfoRequestedMappable {}

/// Do the switch user group action.
///
/// After confirm.
@MappableClass()
final class SwitchUserGroupRunSwitchRequested extends SwitchUserGroupBaseEvent
    with SwitchUserGroupRunSwitchRequestedMappable {
  /// Constructor.
  const SwitchUserGroupRunSwitchRequested(this.name, this.gid, this.formHash);

  /// Name of user group switch to.
  final String name;

  /// The user group id intend to switch to.
  final int gid;

  /// Form hash used in post.
  final String formHash;
}
