import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/authentication/bloc/authentication_bloc.dart';
import 'package:tsdm_client/features/authentication/widgets/login_form.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Page of user to login.
class LoginPage extends StatefulWidget {
  /// Constructor.
  const LoginPage({this.redirectBackState, super.key});

  /// The redirect back route that navigator will push when logged in succeed.
  final GoRouterState? redirectBackState;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.loginPage.title),
      ),
      body: BlocProvider(
        create: (context) => AuthenticationBloc(
          authenticationRepository: context.repo(),
        )..add(AuthenticationFetchLoginHashRequested()),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state.status == AuthenticationStatus.failure) {
              final errorText = switch (state.loginException) {
                LoginFormHashNotFoundException() =>
                  context.t.loginPage.hashValueNotFound,
                LoginInvalidFormHashException() =>
                  context.t.loginPage.failedToGetFormHash,
                LoginMessageNotFoundException() =>
                  context.t.loginPage.failedToLoginMessageNodeNotFound,
                LoginIncorrectCaptchaException() =>
                  context.t.loginPage.loginResultIncorrectCaptcha,
                LoginInvalidCredentialException() =>
                  context.t.loginPage.loginResultIncorrectUsernameOrPassword,
                LoginIncorrectSecurityQuestionException() =>
                  context.t.loginPage.loginResultIncorrectQuestionOrAnswer,
                LoginAttemptLimitException() =>
                  context.t.loginPage.loginResultTooManyLoginAttempts,
                LoginUserInfoNotFoundException() =>
                  context.t.loginPage.loginFailed,
                LoginOtherErrorException() =>
                  context.t.loginPage.loginResultOtherErrors,
                _ => context.t.general.failedToLoad,
              };
              showSnackBar(context: context, message: errorText);
              context
                  .read<AuthenticationBloc>()
                  .add(AuthenticationFetchLoginHashRequested());
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 500,
                  maxWidth: 500,
                ),
                child: LoginForm(
                  redirectPath: widget.redirectBackState?.fullPath,
                  redirectPathParameters:
                      widget.redirectBackState?.pathParameters,
                  redirectExtra: widget.redirectBackState?.extra,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
