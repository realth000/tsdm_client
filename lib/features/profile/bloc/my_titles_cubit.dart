import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/profile/models/secondary_title.dart';
import 'package:tsdm_client/features/profile/repository/my_titles_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'my_titles_cubit.mapper.dart';

/// Loading status.
enum MyTitlesStatus {
  /// Initial state.
  initial,

  /// Loading data.
  loadingTitles,

  /// Switching current title.
  switchingTitle,

  /// Action performed successfully.
  success,

  /// Action is failed.
  failure,
}

/// The state of bloc.
@MappableClass()
final class MyTitlesState with MyTitlesStateMappable {
  /// Status.
  const MyTitlesState({
    this.status = MyTitlesStatus.initial,
    this.titles = const [],
    this.currentTitleId,
  });

  /// Current status.
  final MyTitlesStatus status;

  /// All available secondary titles for current user.
  final List<SecondaryTitle> titles;

  /// The id of current secondary title.
  ///
  /// May not present if no title specified.
  final int? currentTitleId;
}

/// Cubit of my titles page.
final class MyTitlesCubit extends Cubit<MyTitlesState> with LoggerMixin {
  /// Constructor.
  MyTitlesCubit(this._repo) : super(const MyTitlesState());

  final MyTitlesRepository _repo;

  /// Fetch info about all secondary titles for current user.
  Future<void> fetchAvailableSecondaryTitles() async {
    emit(state.copyWith(status: MyTitlesStatus.loadingTitles));
    switch (await _repo.fetchSecondaryTitles().run()) {
      case Right(:final value):
        emit(state.copyWith(status: MyTitlesStatus.success, titles: value));
      case Left(:final value):
        error('failed to load available secondary titles: $value');
        emit(state.copyWith(status: MyTitlesStatus.failure));
    }
  }

  /// Set the secondary title to the one specified by [id].
  Future<void> setSecondaryTitle(int id) async {
    final activatedIdx = state.titles.indexWhere((v) => v.id == id);
    if (activatedIdx < 0) {
      return;
    }
    emit(state.copyWith(status: MyTitlesStatus.switchingTitle));
    switch (await _repo.setSecondaryTitle(id).run()) {
      case Right():
        final s = <SecondaryTitle>[];
        for (final (idx, o) in state.titles.indexed) {
          s.add(o.copyWith(activated: idx == activatedIdx));
        }
        emit(state.copyWith(status: MyTitlesStatus.success, titles: s));
      case Left<AppException, void>(:final value):
        error('failed to switch secondary title: $value');
        emit(state.copyWith(status: MyTitlesStatus.failure));
    }
  }

  /// Unset the user specified secondary title.
  Future<void> unsetSecondaryTitle() async {
    emit(state.copyWith(status: MyTitlesStatus.switchingTitle));
    switch (await _repo.unsetSecondaryTitle().run()) {
      case Right():
        final s = <SecondaryTitle>[];
        for (final o in state.titles) {
          s.add(o.copyWith(activated: false));
        }
        emit(state.copyWith(status: MyTitlesStatus.success, titles: s));
      case Left<AppException, void>(:final value):
        error('failed to switch secondary title: $value');
        emit(state.copyWith(status: MyTitlesStatus.failure));
    }
  }
}
