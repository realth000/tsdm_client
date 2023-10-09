import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/screens/login/login_form.dart';
import 'package:tsdm_client/utils/debug.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({required this.redirectBackState, super.key});

  final GoRouterState redirectBackState;

  static const String _fakeFormUrl =
      'https://tsdm39.com/member.php?mod=logging&action=login&infloat=yes&frommessage&inajax=1&ajaxtarget=messagelogin';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String? loginHash;
  String? formHash;

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
        await ref.read(netClientProvider()).get(LoginPage._fakeFormUrl);
    final data = rawData.data as String;
    final re = RegExp(r'layer_login_(?<Hash>\w+)');
    final match = re.firstMatch(data);
    loginHash = match?.namedGroup('Hash');
    if (loginHash == null) {
      debug('failed to get login hash');
      return Future.error(t.loginPage.hashValueNotFound);
    }

    final re2 = RegExp(r'formhash" value="(?<FormHash>\w+)"');
    final formHashMatch = re2.firstMatch(data);
    formHash = formHashMatch?.namedGroup('FormHash');
    if (formHash == null) {
      debug('failed to get form hash');
      return Future.error(t.loginPage.failedToGetFormHash);
    }

    debug('get login hash $loginHash');
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchLoginHash(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Text(t.loginPage.failedToGetLoginHash(err: snapshot.error!)),
          );
        }

        if (snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 500,
                  maxWidth: 500,
                ),
                child: LoginForm(
                  redirectPath: widget.redirectBackState.fullPath!,
                  redirectPathParameters:
                      widget.redirectBackState.pathParameters,
                  redirectExtra: widget.redirectBackState.extra,
                  loginHash: loginHash!,
                  formHash: formHash!,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 10, height: 10),
                Text(t.loginPage.preparingLogin),
              ],
            ),
          ),
        );
      },
    );
  }
}
