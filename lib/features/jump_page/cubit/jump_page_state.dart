part of 'jump_page_cubit.dart';

/// status of jumping page.
enum JumpPageStatus {
  /// Initial.
  initial,

  /// Loading the new page.
  loading,

  /// Load succeed.
  success,
}

/// State of jumping page.
final class JumpPageState extends Equatable {
  /// Constructor.
  const JumpPageState({
    this.status = JumpPageStatus.initial,
    this.currentPage = 1,
    this.totalPages = 1,
    this.canJumpPage = true,
  });

  /// Status of jumping.
  final JumpPageStatus status;

  /// Current page number
  final int currentPage;

  /// Total page number.
  final int totalPages;

  /// Flag indicates can jump page or not.
  final bool canJumpPage;

  /// Copy with.
  JumpPageState copyWith({
    JumpPageStatus? status,
    int? currentPage,
    int? totalPages,
    bool? canJumpPage,
  }) {
    return JumpPageState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      canJumpPage: canJumpPage ?? this.canJumpPage,
    );
  }

  @override
  List<Object?> get props => [status, currentPage, totalPages, canJumpPage];
}
