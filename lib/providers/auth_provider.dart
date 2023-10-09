import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';

part '../generated/providers/auth_provider.g.dart';

enum AuthCheckResult {
  authed,
  httpStatusError,
  notAuthed,
}

/// Auth state manager.
@Riverpod(dependencies: [NetClient])
class Auth extends _$Auth {
  static const _authPath = 'https://www.tsdm39.com/home.php?mod=spacecp';
  static const _logoutPath =
      'https://www.tsdm39.com/member.php?mod=logging&action=logout&formhash=';

  /// Check auth state.
  ///
  /// If logged in, return uid, otherwise return null.
  @override
  Future<String?> build() async {
    // Use refresh() to ensure using the latest cookie.
    final resp = await ref.refresh(netClientProvider()).get(_authPath);
    if (resp.statusCode != HttpStatus.ok) {
      return null;
    }
    final document = html_parser.parse(resp.data);
    return checkAuthByParseDocument(document);
  }

  Future<String?> checkAuthByParseDocument(Document document) async {
    final userNode = document.querySelector('div#inner_stat > strong > a');
    if (userNode == null) {
      debug('auth failed: user node not found');
      return null;
    }
    final username = userNode.firstEndDeepText();
    if (username == null) {
      debug('auth failed: user name not found');
      return null;
    }
    final uid = userNode.firstHref()?.split('uid=').lastOrNull;
    if (uid == null) {
      debug('auth failed: user id not found');
      return null;
    }
    return uid;
  }

  Future<bool> logout() async {
    // Check auth status.
    final resp = await ref.read(netClientProvider()).get(_authPath);
    if (resp.statusCode != HttpStatus.ok) {
      debug(
        'failed to logout: auth http request failed with status code=${resp.statusCode}',
      );
      return false;
    }
    final document = html_parser.parse(resp.data);
    final uid = await checkAuthByParseDocument(document);
    if (uid == null) {
      debug('unnecessary logout: not authed');
      return true;
    }

    // Get form hash.
    final re = RegExp(r'formhash" value="(?<FormHash>\w+)"');
    final formHashMatch = re.firstMatch(document.body?.innerHtml ?? '');
    final formHash = formHashMatch?.namedGroup('FormHash');
    if (formHash == null) {
      debug('failed to logout: get form hash failed');
      return false;
    }

    // Logout
    final logoutResp =
        await ref.read(netClientProvider()).get('$_logoutPath$formHash');
    if (logoutResp.statusCode != HttpStatus.ok) {
      debug(
        'failed to logout: logout request failed with status code ${logoutResp.statusCode}',
      );
      return false;
    }

    final logoutDocument = html_parser.parse(logoutResp.data);
    final logoutMessage = logoutDocument.getElementById('messagetext');
    if (logoutMessage == null || !logoutMessage.innerHtml.contains('已退出')) {
      debug('failed to logout: logout message not found');
      return false;
    }

    ref.read(loggedUserUidProvider.notifier).state = '';
    return true;
  }
}
