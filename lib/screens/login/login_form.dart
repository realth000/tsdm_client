import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/screens/login/captcha_image.dart';
import 'package:tsdm_client/utils/debug.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    required this.redirectPath,
    required this.redirectPathParameters,
    required this.redirectExtra,
    required this.loginHash,
    required this.formHash,
    super.key,
  });

  final String redirectPath;
  final Map<String, String> redirectPathParameters;
  final Object? redirectExtra;

  // Data needed when posting login request.
  // Need to store in widget not state to prevent redundant web request.
  final String loginHash;
  final String formHash;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final verifyCodeController = TextEditingController();

  bool _showPassword = false;

  Future<void> _login(BuildContext context) async {
    if (formKey.currentState == null || !(formKey.currentState!).validate()) {
      return;
    }
    final (loginResult, error) = await ref.read(authProvider.notifier).login(
          username: usernameController.text,
          password: passwordController.text,
          verifyCode: verifyCodeController.text,
          formHash: widget.formHash,
        );

    if (!mounted) {
      return;
    }
    // Check login result.
    switch (loginResult) {
      case LoginResult.success:
        debug(
          'login success, redirect back to: path=${widget.redirectPath} with parameters=${widget.redirectPathParameters}, extra=${widget.redirectExtra}',
        );

        // Refresh root content.
        // We do not need the value return here, but if we use ref.invalidate()
        // the future will not execute until we reach pages that watching
        // rootContentProvider.
        //
        // There is no risk that provider refreshes multiple times before we
        // really use the cache in content.
        //
        // Can only use invalidate() here, using refresh or using invalidate with
        // read will cause UI not refresh which is weired, maybe still using
        // legacy cookie?
        // FIXME: Fix root content not refresh immediately.
        // Note that add Circle indicator to root content screen when loading not works.
        ref.invalidate(rootContentProvider);
        if (!mounted) {
          return;
        }
        context.pushReplacementNamed(
          widget.redirectPath,
          pathParameters: widget.redirectPathParameters,
          extra: widget.redirectExtra,
        );
      case LoginResult.requestFailed:
        return showLoginFailedDialog(
          context,
          context.t.loginPage.failedToLoginStatusCode(code: error),
        );
      case LoginResult.messageNotFound:
        return showLoginFailedDialog(
          context,
          context.t.loginPage.failedToLoginMessageNodeNotFound,
        );
      default:
        return showLoginFailedDialog(context, '$loginResult');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Text(
            t.loginPage.login,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 10, height: 10),
          TextFormField(
            autofocus: true,
            controller: usernameController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person),
              labelText: t.loginPage.username,
            ),
            validator: (v) =>
                v!.trim().isNotEmpty ? null : t.loginPage.usernameEmpty,
          ),
          const SizedBox(width: 10, height: 10),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password),
              labelText: t.loginPage.password,
              suffixIcon: IconButton(
                icon: _showPassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
            ),
            obscureText: true,
            validator: (v) =>
                v!.trim().isNotEmpty ? null : t.loginPage.passwordEmpty,
          ),
          const SizedBox(width: 10, height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: verifyCodeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pin),
                    labelText: t.loginPage.verifyCode,
                  ),
                  validator: (v) =>
                      v!.trim().isNotEmpty ? null : t.loginPage.verifyCodeEmpty,
                ),
              ),
              const SizedBox(width: 10, height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: const CaptchaImage(),
              ),
            ],
          ),
          const SizedBox(width: 10, height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text(context.t.loginPage.login),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showLoginFailedDialog(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        scrollable: true,
        title: Text(t.loginPage.loginFailed),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(t.general.ok),
          )
        ],
      );
    },
  );
}
