import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/screens/login/verity_image.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({required this.redirectBackRoute, super.key});

  static const String _fakeFormUrl =
      'https://tsdm39.com/member.php?mod=logging&action=login&infloat=yes&frommessage&inajax=1&ajaxtarget=messagelogin';

  final String redirectBackRoute;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final verifyCodeController = TextEditingController();

  String? _loginHash;
  String? _formHash;

  Future<String> _fetchLoginHash() async {
    // 返回的data是xml：
    //
    // <?xml version="1.0" encoding="utf-8"?>
    // <root><![CDATA[
    // <div id="main_messaqge_L5hJN">
    // <div id="layer_login_L5hJN">
    //
    // 其中"main_message_"后面的是本次登录的loginHash，登录时需要加到url上
    final rawData =
        await ref.read(netClientProvider).get(LoginForm._fakeFormUrl);
    final data = rawData.data as String;
    final re = RegExp(r'layer_login_(?<Hash>\w+)');
    final match = re.firstMatch(data);
    _loginHash = match?.namedGroup('Hash');
    if (_loginHash == null) {
      debugPrint('failed to get login hash');
      return Future.error('prepare failed');
    }

    final re2 = RegExp(r'formhash" value="(?<FormHash>\w+)"');
    final formHashMatch = re2.firstMatch(data);
    _formHash = formHashMatch?.namedGroup('FormHash');
    if (_formHash == null) {
      debugPrint('failed to get form hash');
      return Future.error('prepare failed');
    }

    debugPrint('get login hash $_loginHash');
    return '';
  }

  Widget _buildLogin() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Text(
            'Login',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextFormField(
            autofocus: true,
            controller: usernameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              labelText: 'Username',
            ),
            validator: (v) =>
                v!.trim().isNotEmpty ? null : 'Username should not be empty',
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
              icon: Icon(Icons.password),
              labelText: 'Password',
            ),
            obscureText: true,
            validator: (v) =>
                v!.trim().isNotEmpty ? null : 'Password should not be empty',
          ),
          const Row(
            children: [
              Icon(Icons.done),
              Text('Prepare login success'),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: verifyCodeController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.pin),
                    labelText: 'Verify Code',
                  ),
                  validator: (v) => v!.trim().isNotEmpty
                      ? null
                      : 'Verify code should not be empty',
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: const VerifyImage(),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState == null ||
                        !(formKey.currentState!).validate()) {
                      return;
                    }

                    if (_loginHash == null || _loginHash == null) {
                      return;
                    }

                    // login
                    final body = {
                      'formhash': _formHash,
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
                        'https://tsdm39.com/member.php?mod=logging&action=login&loginsubmit=yes&frommessage&loginhash=${_loginHash!}';
                    final resp = await ref.read(netClientProvider).post(
                          target,
                          data: body,
                          options: Options(
                            headers: {
                              'Content-Type':
                                  'application/x-www-form-urlencoded'
                            },
                          ),
                        );

                    if (resp.statusCode != HttpStatus.ok) {
                      debugPrint(
                          'failed to login: StatusCode=${resp.statusCode}');
                      await Fluttertoast.showToast(
                          msg:
                              'failed to login: StatusCode=${resp.statusCode}');
                      return;
                    }

                    if (mounted) {
                      // FIXME: Fix redirect back and cookie storage.
                      context.pushReplacement(widget.redirectBackRoute);
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchLoginHash(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('failed to get login hash :${snapshot.error}');
        }

        if (snapshot.hasData) {
          return _buildLogin();
        }

        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            Text('Preparing login'),
          ],
        );
      },
    );
  }
}
