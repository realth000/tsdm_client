import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({this.uid, super.key});

  final String? uid;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Widget _buildProfile(BuildContext context, dom.Document document) {
    final profileRootNode =
        document.body?.querySelector('div#pprl > div.bm.bbda');
    if (profileRootNode == null) {
      return Center(
        child: Text(t.profilePage.userNodeNotFound),
      );
    }

    final username =
        profileRootNode.querySelector('h2.mbn')?.nodes.firstOrNull?.text;

    final uid = profileRootNode
        .querySelector('h2.mbn > span.xw0')
        ?.text
        .split(': ')
        .lastOrNull
        ?.split(')')
        .firstOrNull;

    final friendsNode =
        document.querySelector('ul.bbda > li:nth-child(3) > a:nth-child(2)');
    final friendsCount =
        document.body?.firstEndDeepText()?.split(' ').lastOrNull;

    final birthday = document
        .querySelector(
            'div.pbm:nth-child(1) > ul:nth-child(3) > li:nth-child(1)')
        ?.firstEndDeepText();
    final gender = profileRootNode
        .querySelector(
            'div.pbm:nth-child(1) > ul:nth-child(3) > li:nth-child(2)')
        ?.firstEndDeepText();

    final signInDaysCount = profileRootNode
        .querySelector('div.pbm:nth-child(2) > p:nth-child(2)')
        ?.firstEndDeepText();
    final signInThisMonthCount = profileRootNode
        .querySelector('div.pbm:nth-child(2) > p:nth-child(3)')
        ?.firstEndDeepText();
    final signInRecentTime = document
        .querySelector('div.pbm:nth-child(2) > p:nth-child(4)')
        ?.firstEndDeepText();

    return Scaffold(
      appBar: AppBar(title: Text(t.profilePage.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('username: $username'),
            Text('uid: $uid'),
            Text('friendsCount: $friendsCount'),
            Text('birthday: $birthday'),
            Text('gender: $gender'),
            Text('signInDaysCount: $signInDaysCount'),
            Text('signInThisMonthCount: $signInThisMonthCount'),
            Text('signInResultTime: $signInRecentTime'),
            const SizedBox(width: 10, height: 10),
            ElevatedButton(
              child: const Text('logout'),
              onPressed: () async {
                final logoutResult =
                    await ref.read(authProvider.notifier).logout();
                if (logoutResult) {
                  // Refresh root content.
                  // We do not need the value return here, but if we use ref.invalidate()
                  // the future will not execute until we reach pages that watching
                  // rootContentProvider.
                  //
                  // There is no risk that provider refreshes multiple times before we
                  // really use the cache in content.
                  ref.invalidate(rootContentProvider);
                }
                debug('logout result: $logoutResult');
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.uid ?? ref.read(authProvider);
    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.t.general.needLoginToSeeThisPage),
              const SizedBox(width: 10, height: 10),
              ElevatedButton(
                child: Text(t.loginPage.login),
                onPressed: () async {
                  await context.pushNamed(ScreenPaths.login);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder(
        future: ref
            .read(netClientProvider())
            .get('https://www.tsdm39.com/home.php?mod=space&uid=$uid'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final resp = snapshot.data;
            final document = html_parser.parse(resp!.data);
            return _buildProfile(context, document);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
