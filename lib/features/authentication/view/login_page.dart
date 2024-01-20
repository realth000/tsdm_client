import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/authentication/bloc/authentication_bloc.dart';
import 'package:tsdm_client/features/authentication/repository/exceptions/exceptions.dart';
import 'package:tsdm_client/features/authentication/widgets/login_form.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({this.redirectBackState, super.key});

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
            authenticationRepository: RepositoryProvider.of(context))
          ..add(AuthenticationFetchLoginHashRequested()),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state.status == AuthenticationStatus.failed) {
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
                null => context.t.general.failedToLoad,
              };
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(errorText)));

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
