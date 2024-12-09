import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/reply_bar/models/reply_types.dart';
import 'package:tsdm_client/widgets/reply_bar/repository/reply_repository.dart';

part 'reply_bloc.mapper.dart';
part 'reply_event.dart';
part 'reply_state.dart';

/// Emitter
typedef _Emit = Emitter<ReplyState>;

/// Bloc of reply
class ReplyBloc extends Bloc<ReplyEvent, ReplyState> with LoggerMixin {
  /// Constructor.
  ReplyBloc({required ReplyRepository replyRepository})
      : _replyRepository = replyRepository,
        super(const ReplyState()) {
    on<ReplyParametersUpdated>(_onReplyParametersUpdated);
    on<ReplyThreadClosed>(_onReplyThreadClosed);
    on<ReplyToPostRequested>(_onReplyToPostRequested);
    on<ReplyToThreadRequested>(_onReplyToThreadRequested);
    on<ReplyResetClearTextStateTriggered>(_onReplyResetClearTextStateTriggered);
    on<ReplyChatHistoryRequested>(_onReplyChatHistoryRequested);
    on<ReplyChatRequested>(_onReplyChatRequested);
  }

  final ReplyRepository _replyRepository;

  Future<void> _onReplyParametersUpdated(
    ReplyParametersUpdated event,
    _Emit emit,
  ) async {
    if (event.replyParameters == null) {
      emit(state.copyWithNullReplyParameters());
    } else {
      emit(state.copyWith(replyParameters: event.replyParameters));
    }
  }

  Future<void> _onReplyThreadClosed(
    ReplyThreadClosed event,
    _Emit emit,
  ) async {
    emit(state.copyWith(closed: event.closed));
  }

  Future<void> _onReplyToPostRequested(
    ReplyToPostRequested event,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: ReplyStatus.loading));
    final ret = await _replyRepository
        .replyToPost(
          replyParameters: event.replyParameters,
          replyAction: event.replyAction,
          replyMessage: event.replyMessage,
        )
        .run();
    if (ret.isLeft()) {
      handle(ret.unwrapErr());
      emit(state.copyWith(status: ReplyStatus.failure));
      return;
    }
    emit(state.copyWith(status: ReplyStatus.success, needClearText: true));
  }

  Future<void> _onReplyToThreadRequested(
    ReplyToThreadRequested event,
    _Emit emit,
  ) async {
    try {
      emit(state.copyWith(status: ReplyStatus.loading));
      await _replyRepository.replyToThread(
        replyParameters: event.replyParameters,
        replyMessage: event.replyMessage,
      );
      emit(state.copyWith(status: ReplyStatus.success, needClearText: true));
    } on HttpRequestFailedException catch (e) {
      error('failed to reply to thread: http failed with $e');
      emit(state.copyWith(status: ReplyStatus.failure));
    } on ReplyToThreadResultFailedException catch (e) {
      error('failed to reply to thread: failed result: $e');
      emit(state.copyWith(status: ReplyStatus.failure));
    }
  }

  Future<void> _onReplyResetClearTextStateTriggered(
    ReplyResetClearTextStateTriggered event,
    _Emit emit,
  ) async {
    emit(state.copyWith(needClearText: false));
  }

  Future<void> _onReplyChatHistoryRequested(
    ReplyChatHistoryRequested event,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: ReplyStatus.loading));
    // TODO: Update chat history with returned pmid.
    final result = await _replyRepository
        .replyHistoryPersonalMessage(
          targetUrl: event.targetUrl,
          formHash: event.formHash,
          message: event.message,
        )
        .run();
    if (result.isLeft()) {
      final err = result.unwrapErr();
      if (err case ReplyPersonalMessageFailedException()) {
        error('failed to reply chat history');
        emit(
          state.copyWith(
            status: ReplyStatus.failure,
            failedReason: err.message,
          ),
        );
        return;
      }
      handle(err);
      emit(state.copyWith(status: ReplyStatus.failure));
      return;
    }
    emit(state.copyWith(status: ReplyStatus.success, needClearText: true));
  }

  Future<void> _onReplyChatRequested(
    ReplyChatRequested event,
    _Emit emit,
  ) async {
    emit(state.copyWith(status: ReplyStatus.loading));
    // TODO: Update chat history with returned pmid.
    final result = await _replyRepository
        .replyPersonalMessage(event.touid, event.formData)
        .run();
    if (result.isLeft()) {
      final err = result.unwrapErr();
      if (err case ReplyPersonalMessageFailedException()) {
        emit(
          state.copyWith(
            status: ReplyStatus.failure,
            failedReason: err.message,
          ),
        );
        return;
      }
      handle(err);
      emit(state.copyWith(status: ReplyStatus.failure));
      return;
    }
    emit(state.copyWith(status: ReplyStatus.success, needClearText: true));
  }
}
