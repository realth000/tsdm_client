import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/settings_provider.dart';
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

  Future<void> _login() async {
    if (formKey.currentState == null || !(formKey.currentState!).validate()) {
      return;
    }

    // login
    final body = {
      'formhash': widget.formHash,
      'referer': 'https://tsdm39.com/forum.php',
      'loginfield': 'username',
      'username': usernameController.text,
      'password': passwordController.text,
      'tsdm_verify': verifyCodeController.text,
      'questionid': 0,
      'answer': 0,
      'cookietime': 2592000,
      'loginsubmit': true
    };
    final target =
        'https://tsdm39.com/member.php?mod=logging&action=login&loginsubmit=yes&frommessage&loginhash=${widget.loginHash}';
    final resp = await ref
        .read(netClientProvider(username: usernameController.text))
        .post(
          target,
          data: body,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

    // err_login_captcha_invalid

    if (resp.statusCode != HttpStatus.ok) {
      final message = 'failed to login: StatusCode=${resp.statusCode}';
      debug(message);
      if (mounted) {
        return showLoginFailedDialog(context, message);
      } else {
        await Fluttertoast.showToast(msg: message);
        return;
      }
    }

    final document = html_parser.parse(resp.data);
    final loginResultMessageNode = document.getElementById('messagetext');
    if (loginResultMessageNode == null) {
      // Impossible.
      const message = 'failed to login: login result message node not found';
      debug(message);
      if (mounted) {
        return showLoginFailedDialog(context, message);
      } else {
        await Fluttertoast.showToast(msg: message);
        return;
      }
    }

    if (mounted) {
      // Check login result.
      final loginResult =
          LoginAttemptResult.fromLoginMessageNode(loginResultMessageNode);
      switch (loginResult) {
        case LoginAttemptResult.success:
          debug(
            'login success, redirect back to: path=${widget.redirectPath} with parameters=${widget.redirectPathParameters}, extra=${widget.redirectExtra}',
          );

          // TODO: Do this update in auth provider.
          // FIXME: Now the check login state logic always fails with login
          // failure. Fix this or we can not get uid and username.
          // Update login state.
          await ref
              .read(appSettingsProvider.notifier)
              .setLoginUsername(usernameController.text);
          // final resp = await ref
          //     .refresh(netClientProvider(username: usernameController.text))
          //     .get('https://www.tsdm39.com/home.php?mod=task');
          // final document = html_parser.parse(resp.data);
          // final userNode =
          //     document.querySelector('div#inner_stat > strong > a');
          // if (userNode == null) {
          //   debug(
          //     'failed to find user node when check login state, seems not login.',
          //   );
          //   debug(document.body?.innerHtml);
          //   return;
          // }
          // final uid = userNode.firstHref()?.split('uid=').last;
          // if (uid == null) {
          //   debug(
          //     'failed to find uid when checking login state, seems not login',
          //   );
          //   return;
          // }
          // final username = userNode.firstEndDeepText();
          // if (username == null) {
          //   debug(
          //     'failed to find username when checking login state, seems not login',
          //   );
          //   return;
          // }
          // await ref
          //     .read(appSettingsProvider.notifier)
          //     .setLoginUserId(int.parse(uid));
          // await ref
          //     .read(appSettingsProvider.notifier)
          //     .setLoginUsername(username);
          // debug('update login state: uid=$uid, username=$username');

          if (!mounted) {
            return;
          }

          context.pushReplacementNamed(
            widget.redirectPath,
            pathParameters: widget.redirectPathParameters,
            extra: widget.redirectExtra,
          );
        default:
          return showLoginFailedDialog(
            context,
            '$loginResult: ${loginResultMessageNode.querySelector('div#messagetext > p')?.nodes.firstOrNull?.text}',
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Text(
            'Login',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 10, height: 10),
          TextFormField(
            autofocus: true,
            controller: usernameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Username',
            ),
            validator: (v) =>
                v!.trim().isNotEmpty ? null : 'Username should not be empty',
          ),
          const SizedBox(width: 10, height: 10),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password),
              labelText: 'Password',
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
                v!.trim().isNotEmpty ? null : 'Password should not be empty',
          ),
          const SizedBox(width: 10, height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: verifyCodeController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.pin),
                    labelText: 'Verify Code',
                  ),
                  validator: (v) => v!.trim().isNotEmpty
                      ? null
                      : 'Verify code should not be empty',
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
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Enum to represent whether a login attempt succeed.
enum LoginAttemptResult {
  /// Login success.
  success,

  /// Captcha is not correct.
  incorrectCaptcha,

  /// Maybe a login failed.
  ///
  /// When showing error messages or logging, record the original message.
  maybeInvalidUsernameOrPassword,

  /// Too many login attempt and failure.
  loginAttemptLimit,

  /// Other unrecognized error received from server.
  otherError,

  /// Unknown result.
  ///
  /// Treat as login failed.
  unknown;

  factory LoginAttemptResult.fromLoginMessageNode(dom.Element messageNode) {
    final message = messageNode
        .querySelector('div#messagetext > p')
        ?.nodes
        .firstOrNull
        ?.text;
    if (message == null) {
      debug(
          'failed to check login result: login result message text not found');
      return LoginAttemptResult.unknown;
    }

    // Check message result node classes.
    // alert_right => login success.
    // alert_info  => login failed, maybe incorrect captcha.
    // alert_error => login failed, maybe invalid username or password.
    final messageClasses = messageNode.classes;

    if (messageClasses.contains('alert_right')) {
      if (message.contains('欢迎您回来')) {
        return LoginAttemptResult.success;
      }

      // Impossible unless server response page updated and changed these messages.
      debug(
        'login result check passed but message check maybe outdated: $message',
      );
      return LoginAttemptResult.success;
    }

    if (messageClasses.contains('alert_info')) {
      if (message.contains('err_login_captcha_invalid')) {
        return LoginAttemptResult.incorrectCaptcha;
      }

      // Other unrecognized error.
      debug(
          'login result check not passed: alert_info class with unknown message: $message');
      return LoginAttemptResult.otherError;
    }

    if (messageClasses.contains('alert_error')) {
      if (message.contains('登录失败')) {
        return LoginAttemptResult.maybeInvalidUsernameOrPassword;
      }

      if (message.contains('密码错误次数过多')) {
        return LoginAttemptResult.loginAttemptLimit;
      }

      // Other unrecognized error.
      debug(
          'login result check not passed: alert_error with unknown message: $message');
      return LoginAttemptResult.otherError;
    }

    debug('login result check not passed: unknown result');
    return LoginAttemptResult.unknown;
  }

  @override
  String toString() {
    switch (this) {
      case LoginAttemptResult.success:
        return 'login success';
      case LoginAttemptResult.incorrectCaptcha:
        return 'incorrect captcha';
      case LoginAttemptResult.maybeInvalidUsernameOrPassword:
        return 'maybe invalid username or password';
      case LoginAttemptResult.loginAttemptLimit:
        return 'too many login attempts';
      case LoginAttemptResult.otherError:
        return 'other errors';
      case LoginAttemptResult.unknown:
        return 'failed with unknown reason';
    }
  }
}

Future<void> showLoginFailedDialog(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        scrollable: true,
        title: const Text('Login failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ok'),
          )
        ],
      );
    },
  );
}
