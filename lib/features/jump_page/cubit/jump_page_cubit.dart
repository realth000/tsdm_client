import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'jump_page_state.dart';

/// Cubit of jump page feature.
///
/// This cubit is used inside other pages that can "jump to another page" logically.
///
/// Provides the logic that need to handle in other widgets when jump page actions triggered..
class JumpPageCubit extends Cubit<JumpPageState> {
  JumpPageCubit() : super(const JumpPageState());

  void jumpTo(int page) => emit(
        state.copyWith(
          status: JumpPageStatus.success,
          currentPage: page,
        ),
      );

  void markLoading() =>
      emit(state.copyWith(status: JumpPageStatus.loading, canJumpPage: false));

  void markSuccess() =>
      emit(state.copyWith(status: JumpPageStatus.success, canJumpPage: true));

  void setPageInfo({int? currentPage, int? totalPages}) =>
      emit(state.copyWith(currentPage: currentPage, totalPages: totalPages));
}
