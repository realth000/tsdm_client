part of 'user_mention_cubit.dart';

/// Status of loading progress.
enum UserMentionStatus {
  /// Initial state.
  initial,

  /// Loading data.
  loading,

  /// Got data.
  success,

  /// Failed to load.
  failure,
}

/// Basic state
@MappableClass()
final class UserMentionState with UserMentionStateMappable {
  /// Constructor.
  const UserMentionState({
    required this.searchStatus,
    required this.recommendStatus,
    required this.searchResult,
    required this.randomFriend,
    this.formHash,
  });

  /// Empty state.
  factory UserMentionState.empty() => const UserMentionState(
        searchStatus: UserMentionStatus.initial,
        recommendStatus: UserMentionStatus.initial,
        searchResult: [],
        randomFriend: [],
      );

  /// Current status of searching user.
  final UserMentionStatus searchStatus;

  /// Current status of random recommend friend.
  final UserMentionStatus recommendStatus;

  /// Form hash used when searching user by name.
  ///
  /// It's hard to inject form hash from outside so we use the one when getting
  /// random friends, it is the same with regular one in thread page or else
  /// where editor exists but easier to fetch.
  final String? formHash;

  /// Search result.
  final List<String> searchResult;

  /// Random recommended friends.
  ///
  /// None value means http request failed.
  /// We don't have to show the detail error.
  final List<String> randomFriend;
}
