import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/checkin_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';
import 'package:tsdm_client/utils/show_dialog.dart';

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

    // Basic info
    final username = profileRootNode
        .querySelector('h2.mbn')
        ?.nodes
        .firstOrNull
        ?.text
        ?.trim();
    final uid = profileRootNode
        .querySelector('h2.mbn > span.xw0')
        ?.text
        .split(': ')
        .lastOrNull
        ?.split(')')
        .firstOrNull;
    final basicInfoList = profileRootNode
        .querySelectorAll('div.pbm:nth-child(1) li')
        .map((e) => e.parseLiEmNode())
        .where((e) => e != null)
        .toList();

    // Check in status
    final checkInNode = profileRootNode.querySelector('div.pbm.mbm.bbda.c');
    final checkInDaysCount =
        checkInNode?.querySelector('p:nth-child(1)')?.firstEndDeepText();
    final checkInThisMonthCount =
        checkInNode?.querySelector('p:nth-child(2)')?.firstEndDeepText();
    final checkInRecentTime =
        checkInNode?.querySelector('p:nth-child(3)')?.firstEndDeepText();
    final checkInAllCoins = checkInNode
        ?.querySelector('p:nth-child(4) font:nth-child(1)')
        ?.firstEndDeepText();
    final checkInLastTimeCoin = checkInNode
        ?.querySelector('p:nth-child(4) font:nth-child(3)')
        ?.firstEndDeepText();
    final checkInLevel = checkInNode
        ?.querySelector('p:nth-child(5) font:nth-child(1)')
        ?.firstEndDeepText();
    final checkInNextLevel = checkInNode
        ?.querySelector('p:nth-child(5) font:nth-child(3)')
        ?.firstEndDeepText();
    final checkInNextLevelDays = checkInNode
        ?.querySelector('p:nth-child(5) font:nth-child(5)')
        ?.firstEndDeepText();
    final checkInTodayStatus =
        checkInNode?.querySelector('p:nth-child(6)')?.firstEndDeepText();

    // TODO: Parse medals here.

    // Activity overview
    // TODO: Parse manager groups and user groups belonged to, here.
    final activityNode = profileRootNode.querySelector('ul#pbbs');
    final activityInfoList = activityNode
            ?.querySelectorAll('li')
            .map((e) => e.parseLiEmNode())
            .where((e) => e != null)
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(title: Text(t.profilePage.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('username: $username'),
            Text('uid: $uid'),
            ...basicInfoList.map((e) => Text('${e!.$1}: ${e.$2}')),
            Text('checkInDaysCount: $checkInDaysCount'),
            Text('checkInThisMonthCount: $checkInThisMonthCount'),
            Text('checkInResultTime: $checkInRecentTime'),
            Text('checkInAllCoins: $checkInAllCoins'),
            Text('checkInLastTimeCoins: $checkInLastTimeCoin'),
            Text('checkInLevel: $checkInLevel'),
            Text('checkInNextLevel: $checkInNextLevel'),
            Text('checkInNextLevelDays: $checkInNextLevelDays'),
            Text('checkInTodayStatus: $checkInTodayStatus'),
            ...activityInfoList.map((e) => Text('${e!.$1}: ${e.$2}')),
            const SizedBox(width: 10, height: 10),
            ElevatedButton(
              child: const Text('check in'),
              onPressed: () async {
                final (result, message) =
                    await ref.read(checkInProvider.future);
                switch (result) {
                  // TODO: Show dialog here to ensure enough time to read and
                  // chances to copy other error message.
                  case CheckInResult.success:
                    return showMessageSingleButtonDialog(
                      context: context,
                      title: context.t.profilePage.checkIn.title,
                      message: context.t.profilePage.checkIn
                          .success(msg: '$message'),
                    );
                  case CheckInResult.notAuthorized:
                    return showMessageSingleButtonDialog(
                      context: context,
                      title: context.t.profilePage.checkIn.title,
                      message:
                          context.t.profilePage.checkIn.failedNotAuthorized,
                    );
                  case CheckInResult.webRequestFailed:
                    return showMessageSingleButtonDialog(
                      context: context,
                      title: context.t.profilePage.checkIn.title,
                      message: context.t.profilePage.checkIn
                          .failedRequest(err: '$message'),
                    );
                  case CheckInResult.formHashNotFound:
                    return showMessageSingleButtonDialog(
                      context: context,
                      title: context.t.profilePage.checkIn.title,
                      message:
                          context.t.profilePage.checkIn.failedFormHashNotFound,
                    );
                  case CheckInResult.alreadyCheckedIn:
                    return showMessageSingleButtonDialog(
                      context: context,
                      title: context.t.profilePage.checkIn.title,
                      message:
                          context.t.profilePage.checkIn.failedAlreadyCheckedIn,
                    );
                  case CheckInResult.otherError:
                    return showMessageSingleButtonDialog(
                      context: context,
                      title: context.t.profilePage.checkIn.title,
                      message: context.t.profilePage.checkIn
                          .failedOtherError(err: '$message'),
                    );
                }
              },
            ),
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
