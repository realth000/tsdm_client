part of 'jump_page_cubit.dart';

enum JumpPageStatus {
  initial,
  loading,
  success,
}

final class JumpPageState extends Equatable {
  const JumpPageState({
    this.status = JumpPageStatus.initial,
    this.currentPage = 1,
    this.totalPages = 1,
    this.canJumpPage = true,
  });

  final JumpPageStatus status;

  /// Current page number
  final int currentPage;

  /// Total page number.
  final int totalPages;
  final bool canJumpPage;

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
