import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/editor/repository/editor_repository.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'emoji_bloc.mapper.dart';
part 'emoji_event.dart';
part 'emoji_state.dart';

/// Emoji emitter.
typedef _Emit = Emitter<EmojiState>;

/// Bloc of emoji.
///
/// Controls loading emoji.
final class EmojiBloc extends Bloc<EmojiEvent, EmojiState> with LoggerMixin {
  /// Constructor.
  EmojiBloc({required EditorRepository editRepository})
    : _editorRepository = editRepository,
      super(const EmojiState(status: EmojiStatus.initial)) {
    on<EmojiEvent>(
      (event, emit) => switch (event) {
        EmojiFetchFromServerEvent() => _onFetchFromServer(emit),
        EmojiFetchFromCacheEvent() => _onFetchFromCache(emit),
        EmojiFetchFromAssetEvent() => _onFetchFromAsset(emit),
      },
    );
  }

  final EditorRepository _editorRepository;

  Future<void> _onFetchFromCache(_Emit emit) async {
    emit(state.copyWith(status: EmojiStatus.loading));
    await _editorRepository.loadEmojiFromCacheOrServer().match(
      (e) {
        handle(e);
        emit(state.copyWith(status: EmojiStatus.failure));
      },
      (_) => emit(state.copyWith(status: EmojiStatus.success, emojiGroupList: _editorRepository.emojiGroupList)),
    ).run();
  }

  Future<void> _onFetchFromAsset(_Emit emit) async {
    emit(state.copyWith(status: EmojiStatus.loading));
    await _editorRepository.loadEmojiFromAsset().run();
    emit(state.copyWith(status: EmojiStatus.success, emojiGroupList: _editorRepository.emojiGroupList));
  }

  Future<void> _onFetchFromServer(_Emit emit) async {
    emit(state.copyWith(status: EmojiStatus.loading));
    try {
      final result = await _editorRepository.loadEmojiFromServer();
      if (!result) {
        emit(state.copyWith(status: EmojiStatus.failure));
      } else {
        emit(state.copyWith(status: EmojiStatus.success, emojiGroupList: _editorRepository.emojiGroupList));
      }
      return;
    } on HttpRequestFailedException catch (e) {
      error('failed to load emoji from server: $e');
      emit(state.copyWith(status: EmojiStatus.failure));
    }
  }

  @override
  Future<void> close() async {
    _editorRepository.dispose();
    return super.close();
  }
}
