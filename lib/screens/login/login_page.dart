import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/screens/login/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({required this.redirectBackState, super.key});

  final GoRouterState redirectBackState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 500,
          maxWidth: 500,
        ),
        child: LoginForm(
          redirectPath: redirectBackState.fullPath!,
          redirectPathParameters: redirectBackState.pathParameters,
          redirectExtra: redirectBackState.extra,
        ),
      ),
    );
  }
}
