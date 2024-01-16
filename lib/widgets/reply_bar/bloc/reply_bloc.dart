import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/shared/models/reply_parameters.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/widgets/reply_bar/execptions/exceptions.dart';
import 'package:tsdm_client/widgets/reply_bar/repository/reply_repository.dart';

part 'reply_event.dart';
part 'reply_state.dart';

typedef ReplyEmitter = Emitter<ReplyState>;

class ReplyBloc extends Bloc<ReplyEvent, ReplyState> {
  ReplyBloc({required ReplyRepository replyRepository})
      : _replyRepository = replyRepository,
        super(const ReplyState()) {
    on<ReplyParametersUpdated>(_onReplyParametersUpdated);
    on<ReplyThreadClosed>(_onReplyThreadClosed);
    on<ReplyToPostRequested>(_onReplyToPostRequested);
    on<ReplyToThreadRequested>(_onReplyToThreadRequested);
  }

  final ReplyRepository _replyRepository;

  Future<void> _onReplyParametersUpdated(
    ReplyParametersUpdated event,
    ReplyEmitter emit,
  ) async {
    if (event.replyParameters == null) {
      emit(state.copyWithNullReplyParameters());
    } else {
      emit(state.copyWith(replyParameters: event.replyParameters));
    }
  }

  Future<void> _onReplyThreadClosed(
    ReplyThreadClosed event,
    ReplyEmitter emit,
  ) async {
    emit(state.copyWith(closed: event.closed));
  }

  Future<void> _onReplyToPostRequested(
    ReplyToPostRequested event,
    ReplyEmitter emit,
  ) async {
    try {
      emit(state.copyWith(status: ReplyStatus.loading));
      await _replyRepository.replyToPost(
        replyParameters: event.replyParameters,
        replyAction: event.replyAction,
        replyMessage: event.replyMessage,
      );
      emit(state.copyWith(status: ReplyStatus.success));
    } on HttpRequestFailedException catch (e) {
      debug('failed to reply to post: http failed with $e');
      emit(state.copyWith(status: ReplyStatus.failed));
    } on ReplyToPostFetchParameterFailedException catch (e) {
      debug('failed to reply to post: failed to fetch parameters: $e');
      emit(state.copyWith(status: ReplyStatus.failed));
    } on ReplyToPostResultFailedException catch (e) {
      debug('failed to reply to post: failed result: $e');
      emit(state.copyWith(status: ReplyStatus.failed));
    }
  }

  Future<void> _onReplyToThreadRequested(
    ReplyToThreadRequested event,
    ReplyEmitter emit,
  ) async {
    try {
      emit(state.copyWith(status: ReplyStatus.loading));
      await _replyRepository.replyToThread(
        replyParameters: event.replyParameters,
        replyMessage: event.replyMessage,
      );
      emit(state.copyWith(status: ReplyStatus.success));
    } on HttpRequestFailedException catch (e) {
      debug('failed to reply to thread: http failed with $e');
      emit(state.copyWith(status: ReplyStatus.failed));
    } on ReplyToThreadResultFailedException catch (e) {
      debug('failed to reply to thread: failed result: $e');
      emit(state.copyWith(status: ReplyStatus.failed));
    }
  }
}
