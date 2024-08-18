import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/editor/exceptions/exceptions.dart';
import 'package:tsdm_client/features/editor/repository/editor_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'emoji_bloc.mapper.dart';
part 'emoji_event.dart';
part 'emoji_state.dart';

/// Emoji emitter.
typedef EmojiEmitter = Emitter<EmojiState>;

/// Bloc of emoji.
///
/// Controls loading emoji.
final class EmojiBloc extends Bloc<EmojiEvent, EmojiState> with LoggerMixin {
  /// Constructor.
  EmojiBloc({required EditorRepository editRepository})
      : _editorRepository = editRepository,
        super(const EmojiState(status: EmojiStatus.initial)) {
    on<EmojiFetchFromCacheEvent>(_onEmojiFetchFromCacheEvent);
    on<EmojiFetchFromServerEvent>(_onEmojiFetchFromServerEvent);
  }

  final EditorRepository _editorRepository;

  Future<void> _onEmojiFetchFromCacheEvent(
    EmojiFetchFromCacheEvent event,
    EmojiEmitter emit,
  ) async {
    emit(state.copyWith(status: EmojiStatus.loading));
    try {
      await _editorRepository.loadEmojiFromCacheOrServer();
      emit(
        state.copyWith(
          status: EmojiStatus.success,
          emojiGroupList: _editorRepository.emojiGroupList,
        ),
      );
    } on EmojiRelatedException catch (e) {
      error('failed to load emoji from cache: $e');
      emit(state.copyWith(status: EmojiStatus.failure));
    }
  }

  Future<void> _onEmojiFetchFromServerEvent(
    EmojiFetchFromServerEvent event,
    EmojiEmitter emit,
  ) async {
    emit(state.copyWith(status: EmojiStatus.loading));
    try {
      final result = await _editorRepository.loadEmojiFromServer();
      if (!result) {
        emit(state.copyWith(status: EmojiStatus.failure));
      } else {
        emit(
          state.copyWith(
            status: EmojiStatus.success,
            emojiGroupList: _editorRepository.emojiGroupList,
          ),
        );
      }
      return;
    } on HttpRequestFailedException catch (e) {
      error('failed to load emoji from server: $e');
      emit(state.copyWith(status: EmojiStatus.failure));
    }
  }
}
