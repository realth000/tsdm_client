import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/cached_image.dart';
import 'package:tsdm_client/widgets/check_in_button.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/obscure_list_tile.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

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

  Widget _buildProfile(BuildContext context, uh.Document document) {
    final profileRootNode = document.querySelector('div#pprl > div.bm.bbda');

    if (profileRootNode == null) {
      return Center(
        child: Text(t.profilePage.userNodeNotFound),
      );
    }

    final avatarUrl = document
        .querySelector('div#wp.wp div#ct.ct2 div.sd div.hm > p > a > img')
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
        ?.split(': ')
        .lastOrNull
        ?.split(')')
        .firstOrNull;
    final basicInfoList = profileRootNode
        .querySelectorAll('div.pbm:nth-child(1) li')
        .map((e) => e.parseLiEmNode())
        .whereType<(String, String)>()
        .toList();

    // Check in status
    final checkInNode = profileRootNode.querySelector('div.pbm.mbm.bbda.c');
    final checkInDaysCount =
        checkInNode?.querySelector('p:nth-child(2)')?.firstEndDeepText();
    final checkInThisMonthCount =
        checkInNode?.querySelector('p:nth-child(3)')?.firstEndDeepText();
    final checkInRecentTime =
        checkInNode?.querySelector('p:nth-child(4)')?.firstEndDeepText();
    final checkInAllCoins = checkInNode
        ?.querySelector('p:nth-child(5) font:nth-child(1)')
        ?.firstEndDeepText();
    final checkInLastTimeCoin = checkInNode
        ?.querySelector('p:nth-child(5) font:nth-child(2)')
        ?.firstEndDeepText();
    final checkInLevel = checkInNode
        ?.querySelector('p:nth-child(6) font:nth-child(1)')
        ?.firstEndDeepText();
    final checkInNextLevel = checkInNode
        ?.querySelector('p:nth-child(6) font:nth-child(3)')
        ?.firstEndDeepText();
    final checkInNextLevelDays = checkInNode
        ?.querySelector('p:nth-child(6) font:nth-child(5)')
        ?.firstEndDeepText();
    final checkInTodayStatus =
        checkInNode?.querySelector('p:nth-child(7)')?.firstEndDeepText();

    // TODO: Parse medals here.

    // Activity overview
    // TODO: Parse manager groups and user groups belonged to, here.
    final activityNode = profileRootNode.querySelector('ul#pbbs');
    final activityInfoList = activityNode
            ?.querySelectorAll('li')
            .map((e) => e.parseLiEmNode())
            .whereType<(String, String)>()
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profilePage.title),
        actions: [
          const CheckInButton(),
          DebounceIconButton(
            icon: const Icon(Icons.logout_outlined),
            shouldDebounce: ref.watch(authProvider) == AuthState.loggingOut,
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
            CachedImage(
              avatarUrl,
              maxWidth: _avatarWidth,
              maxHeight: _avatarHeight,
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
              title: Text(e.$1),
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
            (e) {
              // Privacy contents should use ObscureListTile.
              if (e.$1.contains('IP')) {
                return ObscureListTile(
                  title: Text(e.$1),
                  subtitle: Text(e.$2),
                );
              } else {
                return ListTile(
                  title: Text(e.$1),
                  subtitle: Text(e.$2),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn =
        widget.uid == null && ref.read(authProvider) != AuthState.notAuthorized;
    if (!loggedIn) {
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

    final uid = ref.read(authProvider.notifier).loggedUid;

    final profileDoc = ref.read(rootContentProvider.notifier).profileDoc;
    if (profileDoc != null) {
      // Use cached data.
      return _buildProfile(context, profileDoc);
    }

    return Scaffold(
      body: FutureBuilder(
        future: ref.read(netClientProvider()).get('$uidProfilePage$uid'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final resp = snapshot.data;
            final document = parseHtmlDocument(resp!.data as String);
            return _buildProfile(context, document);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
