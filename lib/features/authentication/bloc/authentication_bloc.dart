import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/authentication/repository/exceptions/exceptions.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

part '../../../generated/features/authentication/bloc/authentication_bloc.mapper.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

/// Emitter
typedef AuthenticationEmitter = Emitter<AuthenticationState>;

/// Bloc the authentication, including login and logout.
///
/// This bloc should be used as a global long-live bloc.
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState>
    with LoggerMixin {
  /// Constructor
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AuthenticationState()) {
    on<AuthenticationFetchLoginHashRequested>(
      _onAuthenticationFetchLoginHashRequested,
    );
    on<AuthenticationLoginRequested>(_onAuthenticationLoginRequested);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onAuthenticationFetchLoginHashRequested(
    AuthenticationFetchLoginHashRequested event,
    AuthenticationEmitter emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.fetchingHash));
    try {
      final loginHash = await _authenticationRepository.fetchHash();
      emit(
        state.copyWith(
          status: AuthenticationStatus.gotHash,
          loginHash: loginHash,
        ),
      );
    } on HttpRequestFailedException catch (e) {
      debug('failed to fetch login hash: $e');
      emit(state.copyWith(status: AuthenticationStatus.failure));
    } on LoginException catch (e) {
      debug('failed to fetch login hash: $e');
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          loginException: e,
        ),
      );
    }
  }

  Future<void> _onAuthenticationLoginRequested(
    AuthenticationLoginRequested event,
    AuthenticationEmitter emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loggingIn));
    try {
      await _authenticationRepository.loginWithPassword(event.userCredential);
      emit(state.copyWith(status: AuthenticationStatus.success));
    } on HttpRequestFailedException catch (e) {
      debug('failed to login: $e');
      emit(state.copyWith(status: AuthenticationStatus.failure));
    } on LoginException catch (e) {
      debug('failed to login: $e');
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          loginException: e,
        ),
      );
    }
  }
}
