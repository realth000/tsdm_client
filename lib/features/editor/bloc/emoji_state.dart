part of 'emoji_bloc.dart';

/// Status of emoji bloc.
enum EmojiStatus {
  /// Initial
  initial,

  /// Loading
  loading,

  /// Succeed
  success,

  /// Failed
  failed,
}

/// State of emoji bloc.
@MappableClass()
final class EmojiState with EmojiStateMappable {
  /// Constructor.
  const EmojiState({
    required this.status,
    this.emojiGroupList,
  });

  /// Status
  final EmojiStatus status;

  /// All emoji group.
  final List<EmojiGroup>? emojiGroupList;
}
