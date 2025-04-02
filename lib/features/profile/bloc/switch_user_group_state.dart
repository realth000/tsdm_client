part of 'switch_user_group_bloc.dart';

/// Status of switching user group status.
enum SwitchUserGroupStatus {
  /// Initial status.
  initial,

  /// Loading data, multiple staged.
  loadingInfo,

  /// Waiting for user to trigger switch action.
  waitingSwitchAction,

  /// Switch succeeded.
  success,

  /// Some action failed.
  failure,
}

/// The state of switching user group.
@MappableClass()
final class SwitchUserGroupState with SwitchUserGroupStateMappable {
  /// Constructor.
  const SwitchUserGroupState({
    required this.status,
    this.availableGroups = const [],
    this.currentUserGroup = '',
    this.formHash = '',
    this.destination,
  });

  /// Current status.
  final SwitchUserGroupStatus status;

  /// All available user groups could switch to.
  final List<AvailableUserGroup> availableGroups;

  /// The name of current user group.
  final String currentUserGroup;

  /// Form hash in current page.
  final String formHash;

  /// The final user group switched to.
  ///
  /// Must set when set [status] to success.
  final String? destination;
}
