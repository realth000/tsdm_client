import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/forum/utils/group.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/repositories/forum_home_repository/forum_home_repository.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'topics_bloc.mapper.dart';

part 'topics_event.dart';

part 'topics_state.dart';

/// Bloc of topic.
class TopicsBloc extends Bloc<TopicsEvent, TopicsState> with LoggerMixin {
  /// Constructor.
  TopicsBloc({required ForumHomeRepository forumHomeRepository})
    : _forumHomeRepository = forumHomeRepository,
      super(const TopicsState()) {
    on<TopicsLoadRequested>(_onTopicsLoadRequested);
    on<TopicsRefreshRequested>(_onTopicsRefreshRequested);
    on<TopicsTabSelected>(_onTopicsTabSelected);
  }

  final ForumHomeRepository _forumHomeRepository;

  Future<void> _onTopicsLoadRequested(TopicsLoadRequested event, Emitter<TopicsState> emit) async {
    emit(state.copyWith(status: TopicsStatus.loading));
    final documentEither = await _forumHomeRepository.fetchTopicPage().run();
    if (documentEither.isLeft()) {
      handle(documentEither.unwrapErr());
      emit(state.copyWith(status: TopicsStatus.failed));
      return;
    }
    final document = documentEither.unwrap();
    final forumGroupList = buildGroupListFromDocument(document);
    emit(state.copyWith(status: TopicsStatus.success, forumGroupList: forumGroupList));
  }

  Future<void> _onTopicsRefreshRequested(TopicsRefreshRequested event, Emitter<TopicsState> emit) async {
    emit(state.copyWith(status: TopicsStatus.loading));

    final documentEither = await _forumHomeRepository.fetchTopicPage(force: true).run();
    if (documentEither.isLeft()) {
      handle(documentEither.unwrapErr());
      emit(state.copyWith(status: TopicsStatus.failed));
      return;
    }
    final document = documentEither.unwrap();
    final forumGroupList = buildGroupListFromDocument(document);
    emit(state.copyWith(status: TopicsStatus.success, forumGroupList: forumGroupList));
  }

  void _onTopicsTabSelected(TopicsTabSelected event, Emitter<TopicsState> emit) {
    emit(state.copyWith(topicsTab: event.tabIndex));
  }
}
