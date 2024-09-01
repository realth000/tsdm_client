import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/features/editor/repository/editor_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'user_mention_cubit.mapper.dart';
part 'user_mention_state.dart';

/// Cubit of user mention.
///
/// * Search user
/// * Get random recommended user.
final class UserMentionCubit extends Cubit<UserMentionState> with LoggerMixin {
  /// Constructor.
  UserMentionCubit(this._repo) : super(UserMentionState.empty());

  final EditorRepository _repo;

  /// Search user by part of username [keyword].
  ///
  /// Only update search result in state.
  Future<void> searchUserByName({
    required String keyword,
    required String formHash,
  }) async {
    emit(state.copyWith(searchStatus: UserMentionStatus.loading));
    switch (await _repo
        .searchUserByName(keyword: keyword, formHash: formHash)
        .run()) {
      case Left(:final value):
        handle(value);
        emit(state.copyWith(searchStatus: UserMentionStatus.failure));
      case Right(:final value):
        emit(
          state.copyWith(
            searchStatus: UserMentionStatus.success,
            searchResult: value,
          ),
        );
    }
  }

  /// Get random friend from server.
  Future<void> recommendFriend() async {
    emit(state.copyWith(recommendStatus: UserMentionStatus.loading));
    switch (await _repo.recommendUser().run()) {
      case Left(:final value):
        handle(value);
        emit(state.copyWith(recommendStatus: UserMentionStatus.failure));
      case Right(:final value):
        emit(
          state.copyWith(
            recommendStatus: UserMentionStatus.success,
            randomFriend: value.$1,
            formHash: value.$2,
          ),
        );
    }
  }
}
