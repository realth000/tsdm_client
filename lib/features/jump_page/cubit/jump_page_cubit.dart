import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'jump_page_state.dart';

/// Cubit of jump page feature.
///
/// This cubit is used inside other pages that can "jump to another page"
/// logically.
///
/// Provides the logic that need to handle in other widgets when jump page
/// actions triggered..
class JumpPageCubit extends Cubit<JumpPageState> {
  /// Constructor.
  JumpPageCubit() : super(const JumpPageState());

  /// Jump to another [page].
  void jumpTo(int page) => emit(
        state.copyWith(
          status: JumpPageStatus.success,
          currentPage: page,
        ),
      );

  /// Mark the current page is loading, disable jump page.
  void markLoading() =>
      emit(state.copyWith(status: JumpPageStatus.loading, canJumpPage: false));

  /// Mark the current page finished loading, enable jump page.
  void markSuccess() =>
      emit(state.copyWith(status: JumpPageStatus.success, canJumpPage: true));

  /// Set current page status and total page status.
  void setPageInfo({int? currentPage, int? totalPages}) =>
      emit(state.copyWith(currentPage: currentPage, totalPages: totalPages));
}
