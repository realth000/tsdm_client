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
import 'package:tsdm_client/providers/small_providers.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/html_element.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({this.uid, super.key});

  final String? uid;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  static const _avatarWidth = 180.0;
  static const _avatarHeight = 220.0;

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkInAction() async {
    final (result, message) = await ref.read(checkInProvider.future);
    switch (result) {
      case CheckInResult.success:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.success(msg: '$message'),
        );
      case CheckInResult.notAuthorized:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedNotAuthorized,
        );
      case CheckInResult.webRequestFailed:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedRequest(err: '$message'),
        );
      case CheckInResult.formHashNotFound:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedFormHashNotFound,
        );
      case CheckInResult.alreadyCheckedIn:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedAlreadyCheckedIn,
        );
      case CheckInResult.earlyInTime:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedEarlyInTime,
        );
      case CheckInResult.lateInTime:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message: context.t.profilePage.checkIn.failedLateInTime,
        );
      case CheckInResult.otherError:
        return showMessageSingleButtonDialog(
          context: context,
          title: context.t.profilePage.checkIn.title,
          message:
              context.t.profilePage.checkIn.failedOtherError(err: '$message'),
        );
    }
  }

  Widget _buildProfile(BuildContext context, dom.Document document) {
    final profileRootNode =
        document.body?.querySelector('div#pprl > div.bm.bbda');

    if (profileRootNode == null) {
      return Center(
        child: Text(t.profilePage.userNodeNotFound),
      );
    }

    final avatarUrl = document.body
        ?.querySelector(
            'div#wp.wp div#ct.ct2 div#ct_shell div.sd div.hm > p > a > img')
        ?.attributes['src'];

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
      appBar: AppBar(
        title: Text(t.profilePage.title),
        actions: [
          DebounceTextButton(
            text: context.t.profilePage.checkIn.title,
            debounceProvider: isCheckingInProvider,
            onPressed: _checkInAction,
          ),
          DebounceTextButton(
            text: context.t.profilePage.logout,
            debounceProvider: isLoggingOutProvider,
            onPressed: () async {
              final confirm = await showQuestionDialog(
                context: context,
                title: context.t.profilePage.logout,
                message: context.t.profilePage.areYouSureToLogout,
              );

              if (confirm != true) {
                return;
              }

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
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 15, right: 15),
        children: [
          if (avatarUrl != null)
            Image.network(
              avatarUrl,
              width: _avatarWidth,
              height: _avatarHeight,
            ),
          if (username != null)
            ListTile(
              title: Text(context.t.profilePage.username),
              subtitle: Text(username),
            ),
          if (uid != null)
            ListTile(
              title: Text(context.t.profilePage.uid),
              subtitle: Text(uid),
            ),
          ...basicInfoList.map(
            (e) => ListTile(
              title: Text(e!.$1),
              subtitle: Text(e.$2),
            ),
          ),
          if (checkInDaysCount != null)
            ListTile(
              title: Text(context.t.profilePage.checkInDaysCount),
              subtitle: Text(checkInDaysCount),
            ),
          if (checkInThisMonthCount != null)
            ListTile(
              title: Text(context.t.profilePage.checkInDaysInThisMonth),
              subtitle: Text(checkInThisMonthCount),
            ),
          if (checkInRecentTime != null)
            ListTile(
              title: Text(context.t.profilePage.checkInRecentTime),
              subtitle: Text(checkInRecentTime),
            ),
          if (checkInAllCoins != null)
            ListTile(
              title: Text(context.t.profilePage.checkInAllCoins),
              subtitle: Text(checkInAllCoins),
            ),
          if (checkInLastTimeCoin != null)
            ListTile(
              title: Text(context.t.profilePage.checkInLastTimeCoins),
              subtitle: Text(checkInLastTimeCoin),
            ),
          if (checkInLevel != null)
            ListTile(
              title: Text(context.t.profilePage.checkInLevel),
              subtitle: Text(checkInLevel),
            ),
          if (checkInNextLevel != null)
            ListTile(
              title: Text(context.t.profilePage.checkInNextLevel),
              subtitle: Text(checkInNextLevel),
            ),
          if (checkInNextLevelDays != null)
            ListTile(
              title: Text(context.t.profilePage.checkInNextLevelDays),
              subtitle: Text(checkInNextLevelDays),
            ),
          if (checkInTodayStatus != null)
            ListTile(
              title: Text(context.t.profilePage.checkInTodayStatus),
              subtitle: Text(checkInTodayStatus),
            ),
          ...activityInfoList.map(
            (e) => ListTile(
              title: Text(e!.$1),
              subtitle: Text(e.$2),
            ),
          ),
        ],
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
