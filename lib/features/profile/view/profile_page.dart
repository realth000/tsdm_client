import 'dart:math';
import 'dart:ui';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/profile/bloc/profile_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/packages/html_muncher/lib/html_muncher.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/attr_block.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/checkin_button/checkin_button.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/icon_chip.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

const _appBarBackgroundImageHeight = 100.0;
const _appBarAvatarHeight = 80.0;
const _appBarExpandHeight = _appBarBackgroundImageHeight + _appBarAvatarHeight;

const _groupAvatarHeight = 100.0;

/// All checking days required from current level to next level.
///
/// Data:
///
/// ```
/// lvMaster 伴坛终老 300天
/// lv10 以坛为家III  250天
/// lv9  以坛为家II   200天   3505
/// lv8  以坛为家III  150天   4288
/// lv7  常住居民III  100天   5392
/// lv6  常住居民II   60天    7072
/// lv5  长居居民I    30天    10007
/// lv4  偶尔看看III  15天    13925
/// lv3  偶尔看看II    7天    19191
/// lv2  偶尔看看I     3天
/// lv1  初来乍到      1天
/// ```
const _checkinNextLevelExp = [
  1 - 0,
  3 - 1,
  7 - 3,
  15 - 7,
  30 - 15,
  60 - 30,
  100 - 60,
  150 - 100,
  200 - 150,
  250 - 200,
  300 - 250,
];

/// Page of user profile.
class ProfilePage extends StatefulWidget {
  /// Constructor.
  const ProfilePage({this.uid, this.username, this.heroTag, super.key});

  /// Other user uid.
  final String? uid;

  /// Other user username.
  final String? username;

  /// Optional hero tag.
  final String? heroTag;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _refreshController = EasyRefreshController(controlFinishRefresh: true);
  final _scrollController = ScrollController();

  static final _checkinLevelNumberRe = RegExp(r'LV\.(?<level>\d+)');

  Widget _buildSliverAppBar(
    BuildContext context,
    ProfileState state, {
    required bool logout,
  }) {
    final userProfile = state.userProfile!;
    final unreadNoticeCount = state.unreadNoticeCount;
    final hasUnreadMessage = state.hasUnreadMessage;

    late final Widget noticeIcon;
    if (RepositoryProvider.of<SettingsRepository>(context)
        .getShowUnreadInfoHint()) {
      if (unreadNoticeCount > 0) {
        noticeIcon = Badge(
          label: Text('$unreadNoticeCount'),
          child: const Icon(Icons.notifications_outlined),
        );
      } else if (unreadNoticeCount <= 0 && hasUnreadMessage) {
        noticeIcon = const Badge(child: Icon(Icons.notifications_outlined));
      } else {
        noticeIcon = const Icon(Icons.notifications_outlined);
      }
    } else {
      noticeIcon = const Icon(Icons.notifications_outlined);
    }

    late final List<Widget> actions;
    if (widget.username == null && widget.uid == null) {
      // Current is current logged user's profile page.
      actions = [
        IconButton(
          icon: const Icon(Icons.show_chart_outlined),
          onPressed: () async {
            await context.pushNamed(ScreenPaths.points);
          },
        ),
        IconButton(
          icon: noticeIcon,
          onPressed: () async {
            await context.pushNamed(ScreenPaths.notice);
          },
        ),
        const CheckInButton(),
        DebounceIconButton(
          icon: const Icon(Icons.logout_outlined),
          shouldDebounce: logout,
          onPressed: () async {
            final logout = await showQuestionDialog(
              context: context,
              title: context.t.profilePage.logout,
              message: context.t.profilePage.areYouSureToLogout,
            );
            if (!context.mounted) {
              return;
            }
            if (logout == null || !logout) {
              return;
            }
            context.read<ProfileBloc>().add(ProfileLogoutRequested());
          },
        ),
      ];
    } else {
      // Other user's profile page.
      actions = [
        IconButton(
          icon: const Icon(Icons.email_outlined),
          onPressed: () async => context.pushNamed(
            ScreenPaths.chat,
            pathParameters: {
              'uid': widget.uid ?? userProfile.uid!,
            },
            extra: <String, dynamic>{
              'username': userProfile.username,
            },
          ),
        ),
      ];
    }

    // Widget used in flexible space of app bar.
    // Contains a blurred background image, bottom background color and
    // user avatar.
    Widget? flexSpace;

    final Widget avatar = CircleAvatar(
      radius: _appBarAvatarHeight / 2 + 3,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: HeroUserAvatar(
        username: userProfile.username ?? '',
        avatarUrl: userProfile.avatarUrl ?? noAvatarUrl,
        heroTag: widget.heroTag,
        maxRadius: _appBarAvatarHeight / 2,
        minRadius: _appBarAvatarHeight / 2,
      ),
    );

    // Title in app bar.
    final title =
        LayoutBuilder(builder: (context, cons) => Row(children: [avatar]));

    if (userProfile.avatarUrl != null) {
      flexSpace = Stack(
        // Disable clip, let profile avatar show outside the stack.
        clipBehavior: Clip.none,
        children: [
          // Background blurred image.
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: CachedImage(
                userProfile.avatarUrl!,
                fit: BoxFit.cover,
                enableAnimation: false,
              ),
            ),
          ),
          // Background color under avatar, height is half of avatar height.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: const SizedBox(height: _appBarAvatarHeight / 2),
                  ),
                ),
              ],
            ),
          ),
          // Avatar and user info.
          Positioned(bottom: 0, left: 15, child: title),
        ],
      );
    }

    return SliverAppBar(
      pinned: true,
      floating: true,
      actions: actions,
      expandedHeight: _appBarExpandHeight,
      flexibleSpace: FlexibleSpaceBar(background: flexSpace),
    );
  }

  List<Widget> _buildCheckinInfoRow(BuildContext context, ProfileState state) {
    final userProfile = state.userProfile;
    if (userProfile == null ||
        userProfile.checkinLevel == null ||
        userProfile.checkinDaysCount == null &&
            (!(userProfile.checkinLevel?.contains('Master') ?? false) ||
                userProfile.checkinNextLevelDays == null)) {
      return [];
    }
    final tr = context.t.profilePage;

    int? totalDays;
    final double percent;
    final String description;

    // Parse checkin level number.
    int? checkinLevelNumber;
    if (userProfile.checkinLevel == null) {
      // Not found.
    } else if (userProfile.checkinLevel!.contains('Master')) {
      // Max level
      checkinLevelNumber = 11;
    } else {
      checkinLevelNumber = _checkinLevelNumberRe
          .firstMatch(userProfile.checkinLevel!)
          ?.namedGroup('level')
          ?.parseToInt();
    }
    if (userProfile.checkinNextLevelDays != null) {
      totalDays =
          userProfile.checkinDaysCount! + userProfile.checkinNextLevelDays!;
      if (checkinLevelNumber != null &&
          checkinLevelNumber >= 0 &&
          checkinLevelNumber < _checkinNextLevelExp.length) {
        // If checkin level is recognized, set the checkin progress percentage
        // to (checkin count in current level  /  all days count required to
        // next level).
        //
        // e.g. From level 5 to level 6 requires (60-30) days and user is 10
        //      days before step into level 6, so the percent is:
        //      1 - 10 / (60 - 30)
        percent = max(
          1 -
              userProfile.checkinNextLevelDays! /
                  _checkinNextLevelExp[checkinLevelNumber],
          0,
        );
      } else {
        percent = userProfile.checkinDaysCount! / totalDays;
      }
      description = '${userProfile.checkinDaysCount}/$totalDays';
    } else {
      percent = 1;
      description = '${userProfile.checkinDaysCount}/-';
    }

    // Checkin
    return [
      sizedBoxW20H20,
      Text(
        tr.checkin.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      sizedBoxW10H10,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                userProfile.checkinLevel!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              sizedBoxW10H10,
              Text(
                description,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
          LinearProgressIndicator(value: percent),
          if (userProfile.checkinThisMonthCount != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 0,
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(tr.checkinDaysInThisMonth),
              subtitle: Text(userProfile.checkinThisMonthCount!),
            ),
          if (userProfile.checkinRecentTime != null)
            ListTile(
              minTileHeight: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_outlined),
              title: Text(tr.checkinRecentTime),
              subtitle: Text(userProfile.checkinRecentTime!),
            ),
          if (userProfile.checkinAllCoins != null)
            ListTile(
              minTileHeight: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(FontAwesomeIcons.coins),
              title: Text(tr.checkinAllCoins),
              subtitle: Text(userProfile.checkinAllCoins!),
            ),
          if (userProfile.checkinLastTimeCoin != null)
            ListTile(
              minTileHeight: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.monetization_on_outlined),
              title: Text(tr.checkinLastTimeCoins),
              subtitle: Text(userProfile.checkinLastTimeCoin!),
            ),
          if (userProfile.checkinTodayStatus != null)
            ListTile(
              minTileHeight: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.today_outlined),
              title: Text(tr.checkinTodayStatus),
              subtitle: Text(userProfile.checkinTodayStatus ?? '-'),
            ),
        ].insertBetween(sizedBoxW5H5),
      ),
    ];
  }

  List<Widget> _buildSliverContent(BuildContext context, ProfileState state) {
    final tr = context.t.profilePage;
    final userProfile = state.userProfile!;

    // Friends count info.
    final friendsInfoNode =
        parseHtmlDocument(userProfile.friendsCount ?? '0').body;
    final friendsCount =
        friendsInfoNode?.innerText.split(' ').lastOrNull?.trim() ?? '-';
    final friendsPage =
        friendsInfoNode?.querySelector('a')?.attributes['href']?.prependHost();

    // Birthday.
    final birthDayText = [
      userProfile.birthdayYear,
      userProfile.birthdayMonth,
      userProfile.birthdayDay,
    ].whereType<String>().join('.');

    final moderatorGroupImg =
        parseHtmlDocument(userProfile.moderatorGroup ?? '')
            .body
            ?.children
            .lastOrNull
            ?.imageUrl();
    final userGroupImg = parseHtmlDocument(userProfile.userGroup ?? '')
        .body
        ?.children
        .lastOrNull
        ?.imageUrl();

    // Introduction.
    //
    // Introduction is captured as raw html code when have multiple lines.
    uh.BodyElement? introductionContent;
    if (userProfile.introduction != null) {
      introductionContent =
          parseHtmlDocument(userProfile.introduction ?? '').body;
    }
    // Signature.
    //
    // Signature is captured as raw html code because server side provides some
    // rich text formats.
    uh.BodyElement? signatureContent;
    if (userProfile.signature != null) {
      signatureContent = parseHtmlDocument(userProfile.signature ?? '').body;
    }

    // All content widgets in profile main sliver list.
    return [
      // Username and uid
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            sizedBoxW10H10,
            GestureDetector(
              child: SingleLineText(
                userProfile.username ?? context.t.profilePage.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onTap: () async =>
                  copyToClipboard(context, userProfile.username ?? ''),
            ),
            sizedBoxW10H10,
            if (userProfile.uid != null)
              SingleLineText(
                userProfile.uid!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
          ],
        ),
      ),
      // Nickname and custom title.
      if (userProfile.nickname != null || userProfile.customTitle != null)
        sizedBoxW5H5,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            sizedBoxW10H10,
            if (userProfile.nickname != null)
              SingleLineText(
                userProfile.nickname!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            if (userProfile.nickname != null && userProfile.customTitle != null)
              const SizedBox(width: 20, height: 20, child: VerticalDivider()),
            if (userProfile.customTitle != null)
              SingleLineText(
                userProfile.customTitle!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
          ],
        ),
      ),
      sizedBoxW5H5,
      // email/video verify state, friends, gender
      // This row always exists.
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            if (userProfile.uid != null)
              // Email verify state.
              IconButton(
                icon: const Icon(Icons.email_outlined),
                onPressed: () async {
                  final content = userProfile.emailVerified ?? false
                      ? tr.emailVerified
                      : tr.emailNotVerified;
                  showSnackBar(context: context, message: content);
                },
                isSelected: userProfile.emailVerified ?? false,
              ),
            IconButton(
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: () async {
                final content = userProfile.videoVerified ?? false
                    ? tr.videoVerified
                    : tr.videoNotVerified;
                showSnackBar(context: context, message: content);
              },
              isSelected: userProfile.videoVerified ?? false,
            ),
            TextButton.icon(
              icon: const Icon(Icons.group_outlined),
              label: Text(friendsCount),
              onPressed: friendsPage != null
                  ? () async {
                      await context.dispatchAsUrl(friendsPage);
                    }
                  : null,
            ),
            if (userProfile.gender != null)
              IconChip(
                iconData: Icons.face_2_outlined,
                text: Text(userProfile.gender!),
              ),
          ].insertBetween(sizedBoxW5H5),
        ),
      ),
      // Birthday, zodiac,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            if (birthDayText.isNotEmpty)
              IconChip(
                iconData: Icons.cake_outlined,
                text: Text(birthDayText),
              ),
            if (userProfile.zodiac != null)
              IconChip(
                iconData: MdiIcons.starCrescent,
                text: Text(userProfile.zodiac!),
              ),
          ].insertBetween(sizedBoxW5H5),
        ),
      ),
      // Location.
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            if (userProfile.from != null)
              IconChip(
                iconData: Icons.location_on_outlined,
                text: Text(userProfile.from!),
              ),
          ].insertBetween(sizedBoxW5H5),
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            if (userProfile.msn != null)
              IconChip(
                iconData: Icons.group_outlined,
                text: Text(userProfile.msn!),
              ),
            if (userProfile.qq != null)
              IconChip(
                iconData: FontAwesomeIcons.qq,
                text: Text(userProfile.qq!),
                iconSize: 14,
              ),
          ].insertBetween(sizedBoxW5H5),
        ),
      ),

      if (moderatorGroupImg != null && userGroupImg != null) sizedBoxW10H10,
      Row(
        children: [
          if (moderatorGroupImg != null)
            Flexible(
              child: CachedImage(
                moderatorGroupImg,
                maxWidth: 200,
                maxHeight: _groupAvatarHeight,
              ),
            ),
          if (moderatorGroupImg != null && userGroupImg != null)
            const SizedBox(
              width: 20,
              height: _groupAvatarHeight,
              child: VerticalDivider(),
            ),
          if (userGroupImg != null)
            Flexible(
              child: CachedImage(
                userGroupImg,
                maxWidth: 200,
                maxHeight: _groupAvatarHeight,
              ),
            ),
        ],
      ),
      if (moderatorGroupImg != null && userGroupImg != null) sizedBoxW10H10,

      // Self introduction.
      if (introductionContent != null) ...[
        sizedBoxW15H15,
        InputDecorator(
          decoration: InputDecoration(
            labelText: tr.introduction,
            filled: false,
          ),
          child: munchElement(context, introductionContent),
        ),
      ],

      // Signature.
      if (signatureContent != null) ...[
        sizedBoxW15H15,
        InputDecorator(
          decoration: InputDecoration(
            labelText: tr.signature,
            filled: false,
          ),
          child: munchElement(context, signatureContent),
        ),
      ],

      /// Checkin level.
      ..._buildCheckinInfoRow(context, state),

      /// Statistics.
      sizedBoxW20H20,
      Text(
        tr.statistics.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      sizedBoxW10H10,
      GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 70,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (userProfile.credits != null)
            AttrBlock(
              name: tr.statistics.credits,
              value: userProfile.credits!,
            ),
          if (userProfile.famous != null)
            AttrBlock(
              name: tr.statistics.famous,
              value: userProfile.famous!,
            ),
          if (userProfile.coins != null)
            AttrBlock(
              name: tr.statistics.coins,
              value: userProfile.coins!,
            ),
          if (userProfile.publicity != null)
            AttrBlock(
              name: tr.statistics.publicity,
              value: userProfile.publicity!,
            ),
          if (userProfile.natural != null)
            AttrBlock(
              name: tr.statistics.natural,
              value: userProfile.natural!,
            ),
          if (userProfile.scheming != null)
            AttrBlock(
              name: tr.statistics.scheming,
              value: userProfile.scheming!,
            ),
          if (userProfile.spirit != null)
            AttrBlock(
              name: tr.statistics.spirit,
              value: userProfile.spirit!,
            ),
          if (userProfile.seal != null)
            AttrBlock(
              name: tr.statistics.seal,
              value: userProfile.seal!,
            ),
        ],
      ),
    ];
  }

  Widget _buildContent(
    BuildContext context,
    ProfileState state, {
    required Exception? failedToLogoutReason,
    required bool logout,
  }) {
    // Check whether have failed logout attempt.
    if (failedToLogoutReason != null) {
      showSnackBar(context: context, message: '$failedToLogoutReason');
    }

    _refreshController.finishRefresh();

    return EasyRefresh.builder(
      controller: _refreshController,
      scrollController: _scrollController,
      header: const MaterialHeader(),
      onRefresh: () =>
          context.read<ProfileBloc>().add(ProfileRefreshRequested()),
      childBuilder: (context, physics) => CustomScrollView(
        controller: _scrollController,
        physics: physics,
        slivers: [
          // Real app bar when data loaded.
          _buildSliverAppBar(context, state, logout: logout),
          SliverPadding(
            padding: edgeInsetsL10T5R10,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildSliverContent(context, state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        profileRepository: RepositoryProvider.of<ProfileRepository>(context),
        authenticationRepository:
            RepositoryProvider.of<AuthenticationRepository>(context),
      )..add(ProfileLoadRequested(username: widget.username, uid: widget.uid)),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failed) {
            showFailedToLoadSnackBar(context);
          }
        },
        builder: (context, state) {
          // Default AppBar only use when loading data or failed to load data.
          // Keep this widget so that user can go back to the previous page in
          // some error state (e.g. network error).
          final appBar = switch (state.status) {
            ProfileStatus.initial ||
            ProfileStatus.loading ||
            ProfileStatus.needLogin ||
            ProfileStatus.failed =>
              AppBar(title: Text(context.t.profilePage.title)),
            ProfileStatus.success || ProfileStatus.logout => null,
          };

          // Main content of user profile.
          // Contain a sliver version app bar to show when data loaded.
          final body = switch (state.status) {
            ProfileStatus.initial ||
            ProfileStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ProfileStatus.needLogin => NeedLoginPage(
                backUri: GoRouterState.of(context).uri,
                needPop: true,
                popCallback: (context) {
                  context.read<ProfileBloc>().add(ProfileRefreshRequested());
                },
              ),
            ProfileStatus.failed => buildRetryButton(context, () {
                context.read<ProfileBloc>().add(
                      ProfileLoadRequested(
                        username: widget.username,
                        uid: widget.uid,
                      ),
                    );
              }),
            ProfileStatus.success || ProfileStatus.logout => _buildContent(
                context,
                state,
                failedToLogoutReason: state.failedToLogoutReason,
                logout: state.status == ProfileStatus.logout,
              ),
          };

          return Scaffold(
            appBar: appBar,
            body: ColoredBox(
              // FIXME: Remove workaround for page background issue.
              color: Theme.of(context).colorScheme.surface,
              child: body,
            ),
          );
        },
      ),
    );
  }
}
