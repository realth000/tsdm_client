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
@MappableClass()
final class JumpPageState with JumpPageStateMappable {
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
}
