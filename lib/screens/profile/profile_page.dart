import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/providers/root_content_provider.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/screens/need_login/need_login_page.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/cached_image.dart';
import 'package:tsdm_client/widgets/check_in_button.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/obscure_list_tile.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage(
      {this.uid, this.username, this.showLoggedUser = false, super.key})
      : assert(uid != null || username != null || showLoggedUser,
            'uid or username or showLoggedUser should not be empty at the same time'),
        assert(!(uid != null && showLoggedUser),
            'uid and showLoggedUser should not have value at the same time'),
        assert(!(username != null && showLoggedUser),
            'username and showLoggedUser should not have value at the same time');

  /// Uid for other user.
  ///
  /// When not null, it means we are accessing the profile page of a not logged user, or other user.
  /// When [uid] is provided, ignore [username].
  final String? uid;

  /// Username for other user.
  /// When not null, it means we are accessing the profile page of a not logged user, or other user.
  /// If both [uid] and [username] are provided, use [uid] in advance.
  final String? username;

  /// When set to true, it means we accessing the profile page of current logged user.
  final bool showLoggedUser;

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

  Future<uh.Document> _fetchDocumentByUid(String uid) async {
    final resp = await ref.read(netClientProvider()).get('$uidProfilePage$uid');
    return parseHtmlDocument(resp.data as String);
  }

  Future<uh.Document> _fetchDocumentByUsername(String username) async {
    final resp = await ref
        .read(netClientProvider())
        .get('$usernameProfilePage$username');
    return parseHtmlDocument(resp.data as String);
  }

  Future<void> _logoutDebounce() async {
    final confirm = await showQuestionDialog(
      context: context,
      title: context.t.profilePage.logout,
      message: context.t.profilePage.areYouSureToLogout,
    );

    if (confirm != true) {
      return;
    }

    final logoutResult = await ref.read(authProvider.notifier).logout();
    debug('logout result: $logoutResult');
    if (!mounted) {
      return;
    }
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
    setState(() {});
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

    return ListView(
      padding: edgeInsetsL15R15,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    late final List<Widget> appBarActions;
    late final Future<uh.Document> documentFuture;
    // Initial data for profile, only available when accessing current user's profile page.
    uh.Document? profileDoc;
    if (widget.uid != null) {
      // Accessing other users.
      documentFuture = _fetchDocumentByUid(widget.uid!);
      appBarActions = [];
    } else if (widget.username != null) {
      documentFuture = _fetchDocumentByUsername(widget.username!);
      appBarActions = [];
    } else if (widget.showLoggedUser) {
      // Accessing current logged user.
      final loggedIn = widget.uid == null &&
          ref.read(authProvider) != AuthState.notAuthorized;
      if (!loggedIn) {
        // Embed NeedLoginPage with redirect back route.
        return NeedLoginPage(backUri: GoRouterState.of(context).uri);
      }
      documentFuture =
          _fetchDocumentByUid(ref.read(authProvider.notifier).loggedUid!);

      // Profile page of current logged user may be already cached. Use the cache first.
      profileDoc = ref.read(rootContentProvider.notifier).profileDoc;
      appBarActions = [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () async {
            await context.pushNamed(ScreenPaths.notice);
          },
        ),
        const CheckInButton(),
        DebounceIconButton(
          icon: const Icon(Icons.logout_outlined),
          shouldDebounce: ref.watch(authProvider) == AuthState.loggingOut,
          onPressed: () async => _logoutDebounce(),
        ),
      ];
    } else {
      // Impossible.
      throw Exception(
          'can not determine the type of user we are accessing, this is IMPOSSIBLE');
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.profilePage.title), actions: appBarActions),
      body: FutureBuilder(
        initialData: profileDoc,
        future: documentFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.hasData) {
            return _buildProfile(context, snapshot.data!);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
