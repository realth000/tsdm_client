import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/authentication/repository/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'authentication_bloc.mapper.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

/// Emitter
typedef _Emitter = Emitter<AuthenticationState>;

/// Bloc the authentication, including login and logout.
///
/// This bloc should be used as a global long-live bloc.
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> with LoggerMixin {
  /// Constructor
  AuthenticationBloc({required AuthenticationRepository authenticationRepository})
    : _authenticationRepository = authenticationRepository,
      super(const AuthenticationState()) {
    on<AuthenticationEvent>(
      (event, emitter) => switch (event) {
        AuthenticationFetchLoginHashRequested() => _onFetchLoginHashRequested(emitter),
        AuthenticationLoginRequested(:final userCredential) => _onLoginRequested(emitter, userCredential),
      },
    );
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onFetchLoginHashRequested(_Emitter emit) async {
    emit(state.copyWith(status: AuthenticationStatus.fetchingHash));
    await _authenticationRepository.fetchHash().match((e) {
      handle(e);
      emit(state.copyWith(status: AuthenticationStatus.failure));
    }, (v) => emit(state.copyWith(status: AuthenticationStatus.gotHash, loginHash: v))).run();
  }

  Future<void> _onLoginRequested(_Emitter emit, UserCredential userCredential) async {
    emit(state.copyWith(status: AuthenticationStatus.loggingIn));
    await _authenticationRepository.loginWithPassword(userCredential).match((e) {
      handle(e);
      emit(state.copyWith(status: AuthenticationStatus.failure));
    }, (_) => emit(state.copyWith(status: AuthenticationStatus.success))).run();
  }
}
