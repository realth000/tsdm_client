import 'dart:math' as math;
import 'dart:ui';

import 'package:dart_bbcode_web_colors/dart_bbcode_web_colors.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/checkin/bloc/checkin_bloc.dart';
import 'package:tsdm_client/features/checkin/widgets/checkin_button.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/profile/bloc/profile_bloc.dart';
import 'package:tsdm_client/features/profile/repository/profile_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/medal.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/html/adaptive_color.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/attr_block.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/icon_chip.dart';
import 'package:tsdm_client/widgets/medal_group_view.dart';
import 'package:tsdm_client/widgets/notice_button.dart';
import 'package:tsdm_client/widgets/obscure_list_tile.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Padding is (kToolbarHeight * 0.8).floor().toDouble();
const _appBarBackgroundTopPadding = 44.0;
const _appBarBackgroundImageHeight = 80.0;
const _appBarAvatarHeight = 80.0;
const _appBarExpandHeight = _appBarBackgroundImageHeight + _appBarAvatarHeight + _appBarBackgroundTopPadding;

const _groupAvatarHeight = 100.0;

/// All checking days required from current level to next level.
///
/// Data:
///
/// ``` text
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

enum _ProfileActions { viewNotification, checkin, viewPoints, switchUserGroup, logout, editAvatar }

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
  late final ScrollController _scrollController;

  static final _checkinLevelNumberRe = RegExp(r'LV\.(?<level>\d+)');

  /// Flag indicating show app bar title or not.
  ///
  /// Only show title (with true value) when app bar is fully expanded.
  bool _showAppBarTitle = false;

  void _updateAppBarState() {
    if (_scrollController.offset > _appBarExpandHeight && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset < _appBarExpandHeight && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  Widget _buildSliverAppBar(BuildContext context, ProfileState state, {required bool logout}) {
    final tr = context.t.profilePage;
    final userProfile = state.userProfile!;

    if (!context.mounted) {
      return sizedBoxEmpty;
    }

    final inCheckin = context.read<CheckinBloc>().state is CheckinStateLoading;

    late final List<Widget> actions;
    if (widget.username == null && widget.uid == null) {
      // Current is current logged user's profile page.
      actions = [
        IconButton(
          icon: const Icon(Icons.person_search_outlined),
          tooltip: tr.searchAsThreadAuthor,
          onPressed: () async => context.pushNamed(ScreenPaths.search, queryParameters: {'authorUid': userProfile.uid}),
        ),
        PopupMenuButton<_ProfileActions>(
          onSelected: (action) async {
            switch (action) {
              case _ProfileActions.viewNotification:
                await context.pushNamed(ScreenPaths.notice);
              case _ProfileActions.checkin:
                context.read<CheckinBloc>().add(const CheckinRequested());
              case _ProfileActions.viewPoints:
                await context.pushNamed(ScreenPaths.points);
              case _ProfileActions.switchUserGroup:
                if (logout) {
                  return;
                }
                await context.pushNamed(ScreenPaths.switchUserGroup);
              case _ProfileActions.logout:
                final logout = await showQuestionDialog(
                  context: context,
                  title: tr.logout,
                  message: tr.areYouSureToLogout,
                );
                if (!context.mounted) {
                  return;
                }
                if (logout == null || !logout) {
                  return;
                }
                context.read<ProfileBloc>().add(ProfileLogoutRequested());
              case _ProfileActions.editAvatar:
                await context.pushNamed(ScreenPaths.editAvatar);
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: _ProfileActions.viewNotification,
                  child: Row(
                    children: [const NoticeIcon(), sizedBoxPopupMenuItemIconSpacing, Text(context.t.noticePage.title)],
                  ),
                ),
                PopupMenuItem(
                  enabled: !inCheckin,
                  value: _ProfileActions.checkin,
                  child: Row(
                    children: [
                      const CheckinButton(useIcon: true),
                      sizedBoxPopupMenuItemIconSpacing,
                      Text(tr.checkin.title),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _ProfileActions.editAvatar,
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      sizedBoxPopupMenuItemIconSpacing,
                      Text(context.t.editAvatarPage.title),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _ProfileActions.viewPoints,
                  child: Row(
                    children: [
                      const Icon(Icons.show_chart_outlined),
                      sizedBoxPopupMenuItemIconSpacing,
                      Text(tr.statistics.title),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _ProfileActions.switchUserGroup,
                  child: Row(
                    children: [
                      const Icon(Symbols.change_circle),
                      sizedBoxPopupMenuItemIconSpacing,
                      Text(context.t.switchUserGroupPage.title),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: !logout,
                  value: _ProfileActions.logout,
                  child: Row(
                    children: [
                      DebounceIcon(icon: const Icon(Icons.logout_outlined), shouldDebounce: logout),
                      sizedBoxPopupMenuItemIconSpacing,
                      Text(tr.logout),
                    ],
                  ),
                ),
              ],
        ),
      ];
    } else {
      // Other user's profile page.
      actions = [
        IconButton(
          icon: const Icon(Icons.person_search_outlined),
          tooltip: tr.searchAsThreadAuthor,
          onPressed: () async => context.pushNamed(ScreenPaths.search, queryParameters: {'authorUid': userProfile.uid}),
        ),
        IconButton(
          icon: const Icon(Icons.email_outlined),
          tooltip: context.t.postCard.profileDialog.pmTooltip,
          onPressed:
              () async => context.pushNamed(
                ScreenPaths.chat,
                pathParameters: {'uid': widget.uid ?? userProfile.uid!},
                extra: <String, dynamic>{'username': userProfile.username},
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: HeroUserAvatar(
        username: userProfile.username ?? '',
        avatarUrl: userProfile.avatarUrl ?? noAvatarUrl,
        heroTag: widget.heroTag,
        maxRadius: _appBarAvatarHeight / 2,
        minRadius: _appBarAvatarHeight / 2,
      ),
    );

    if (userProfile.avatarUrl != null) {
      flexSpace = Stack(
        // Disable clip, let profile avatar show outside the stack.
        clipBehavior: Clip.none,
        children: [
          // Background blurred image.
          Positioned.fill(
            // Why we can not add padding here?
            child: Column(
              children: [
                // The height of color box is decided by the sigma in image filtered.
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  height: _appBarBackgroundTopPadding,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: CachedImage(userProfile.avatarUrl!, fit: BoxFit.cover, enableAnimation: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    // Add 4 here because the avatar row (Positioned() below) has 4 padding at bottom.
                    child: const SizedBox(height: _appBarAvatarHeight / 2 + 4),
                  ),
                ),
              ],
            ),
          ),
          // Avatar and user info.
          Positioned(
            bottom: 4,
            left: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                avatar,
                Tooltip(
                  message: tr.online,
                  child: Icon(
                    Icons.circle,
                    size: 16,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.green[400] : Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return SliverAppBar(
      title: _showAppBarTitle ? Text(state.userProfile?.username ?? '') : null,
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
            (!(userProfile.checkinLevel?.contains('Master') ?? false) || userProfile.checkinNextLevelDays == null)) {
      return [];
    }
    final tr = context.t.profilePage;

    int? totalDays;
    final double percent;
    final String description;

    // Parse checkin level number.
    final int? checkinLevelNumber;
    if (userProfile.checkinLevel == null) {
      checkinLevelNumber = null;
    } else if (userProfile.checkinLevel!.contains('Master')) {
      // Max level
      checkinLevelNumber = 11;
    } else {
      checkinLevelNumber =
          _checkinLevelNumberRe.firstMatch(userProfile.checkinLevel!)?.namedGroup('level')?.parseToInt();
    }
    if (userProfile.checkinNextLevelDays != null) {
      totalDays = userProfile.checkinDaysCount! + userProfile.checkinNextLevelDays!;
      if (checkinLevelNumber != null && checkinLevelNumber >= 0 && checkinLevelNumber < _checkinNextLevelExp.length) {
        // If checkin level is recognized, set the checkin progress percentage
        // to (checkin count in current level  /  all days count required to
        // next level).
        //
        // e.g. From level 5 to level 6 requires (60-30) days and user is 10
        //      days before step into level 6, so the percent is:
        //      1 - 10 / (60 - 30)
        percent = math.max(1 - userProfile.checkinNextLevelDays! / _checkinNextLevelExp[checkinLevelNumber], 0);
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
      _SectionTitle(tr.checkin.title),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkin level.
          Row(
            children: [
              Text(
                userProfile.checkinLevel!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).primaryColor),
              ),
              sizedBoxW12H12,
              Text(
                description,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ),
          LinearProgressIndicator(value: percent),

          // General info
          if (userProfile.checkinDaysCount != null)
            _ProfileSectionListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(tr.checkinDaysCount),
              subtitle: Text('${userProfile.checkinDaysCount}'),
            ),
          if (userProfile.checkinThisMonthCount != null)
            _ProfileSectionListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(tr.checkinDaysInThisMonth),
              subtitle: Text(userProfile.checkinThisMonthCount!),
            ),
          if (userProfile.checkinRecentTime != null)
            _ProfileSectionListTile(
              leading: const Icon(Icons.history_outlined),
              title: Text(tr.checkinRecentTime),
              subtitle: Text(userProfile.checkinRecentTime!),
            ),
          if (userProfile.checkinAllCoins != null)
            _ProfileSectionListTile(
              leading: const Icon(FontAwesomeIcons.coins),
              title: Text(tr.checkinAllCoins),
              subtitle: Text(userProfile.checkinAllCoins!),
            ),
          if (userProfile.checkinLastTimeCoin != null)
            _ProfileSectionListTile(
              leading: const Icon(Icons.monetization_on_outlined),
              title: Text(tr.checkinLastTimeCoins),
              subtitle: Text(userProfile.checkinLastTimeCoin!),
            ),
          if (userProfile.checkinTodayStatus != null)
            _ProfileSectionListTile(
              leading: const Icon(Icons.today_outlined),
              title: Text(tr.checkinTodayStatus),
              subtitle: Text(userProfile.checkinTodayStatus ?? '-'),
            ),
        ].insertBetween(sizedBoxW4H4),
      ),
    ];
  }

  List<Widget> _buildSliverContent(BuildContext context, ProfileState state) {
    final tr = context.t.profilePage;
    final userProfile = state.userProfile!;

    // Friends count info.
    final friendsInfoNode = parseHtmlDocument(userProfile.friendsCount ?? '0').body;
    final friendsCount = friendsInfoNode?.innerText.split(' ').lastOrNull?.trim() ?? '-';
    final friendsPage = friendsInfoNode?.querySelector('a')?.attributes['href']?.prependHost();

    // Birthday.
    final birthDayText = [
      userProfile.birthdayYear,
      userProfile.birthdayMonth,
      userProfile.birthdayDay,
    ].whereType<String>().join('.');

    final inDark = Theme.of(context).brightness == Brightness.dark;

    final moderatorGroupDoc = parseHtmlDocument(userProfile.moderatorGroup ?? '').body;
    final moderatorGroupImg = moderatorGroupDoc?.children.lastOrNull?.imageUrl();
    final moderatorGroupName = moderatorGroupDoc?.firstEndDeepText()?.trim();
    final Color? moderatorGroupNameColor;
    final moderatorColorValue = WebColors.fromString(
      moderatorGroupDoc?.querySelector('font')?.attributes['color'] ?? '',
    );
    if (moderatorColorValue.isValid) {
      moderatorGroupNameColor =
          inDark ? Color(moderatorColorValue.colorValue).adaptiveDark() : Color(moderatorColorValue.colorValue);
    } else {
      moderatorGroupNameColor = null;
    }

    final userGroupDoc = parseHtmlDocument(userProfile.userGroup ?? '').body;
    final userGroupImg = userGroupDoc?.children.lastOrNull?.imageUrl();
    final userGroupName = userGroupDoc?.firstEndDeepText()?.trim();
    final Color? userGroupNameColor;
    final userColorValue = WebColors.fromString(userGroupDoc?.querySelector('font')?.attributes['color'] ?? '');
    if (userColorValue.isValid) {
      userGroupNameColor = inDark ? Color(userColorValue.colorValue).adaptiveDark() : Color(userColorValue.colorValue);
    } else {
      userGroupNameColor = null;
    }

    // Introduction.
    //
    // Introduction is captured as raw html code when have multiple lines.
    uh.BodyElement? introductionContent;
    if (userProfile.introduction != null) {
      introductionContent = parseHtmlDocument(userProfile.introduction ?? '').body;
    }
    // Signature.
    //
    // Signature is captured as raw html code because server side provides some
    // rich text formats.
    uh.BodyElement? signatureContent;
    if (userProfile.signature != null) {
      signatureContent = parseHtmlDocument(userProfile.signature ?? '').body;
    }

    final iconChipBackgroundColor = Theme.of(context).colorScheme.surfaceContainerLowest;

    // All content widgets in profile main sliver list.
    return [
      // Username and uid
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            sizedBoxW12H12,
            GestureDetector(
              child: SingleLineText(
                userProfile.username ?? context.t.profilePage.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              onTap: () async => copyToClipboard(context, userProfile.username ?? ''),
            ),
            sizedBoxW12H12,
            if (userProfile.uid != null)
              SingleLineText(
                userProfile.uid!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
          ],
        ),
      ),
      sizedBoxW12H12,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            sizedBoxW12H12,
            if (userProfile.nickname != null)
              SingleLineText(
                userProfile.nickname!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            if (userProfile.nickname != null && userProfile.customTitle != null)
              const SizedBox(width: 20, height: 20, child: VerticalDivider()),
            if (userProfile.customTitle != null)
              SingleLineText(
                userProfile.customTitle!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
          ],
        ),
      ),
      sizedBoxW12H12,
      Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (userProfile.uid != null)
            // Email verify state.
            IconButton(
              icon: const Icon(Icons.email_outlined),
              onPressed: () async {
                final content = userProfile.emailVerified ?? false ? tr.emailVerified : tr.emailNotVerified;
                showSnackBar(context: context, message: content);
              },
              isSelected: userProfile.emailVerified ?? false,
            ),
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: () async {
              final content = userProfile.videoVerified ?? false ? tr.videoVerified : tr.videoNotVerified;
              showSnackBar(context: context, message: content);
            },
            isSelected: userProfile.videoVerified ?? false,
          ),
          TextButton.icon(
            icon: const Icon(Icons.group_outlined),
            label: Text(friendsCount),
            onPressed:
                friendsPage != null
                    ? () async {
                      await context.dispatchAsUrl(friendsPage);
                    }
                    : null,
          ),
          if (userProfile.gender != null)
            IconChip(
              iconData: Icons.face_2_outlined,
              text: Text(userProfile.gender!),
              backgroundColor: iconChipBackgroundColor,
            ),
          if (birthDayText.isNotEmpty)
            IconChip(iconData: Icons.cake_outlined, text: Text(birthDayText), backgroundColor: iconChipBackgroundColor),
          if (userProfile.zodiac != null)
            IconChip(
              iconData: MdiIcons.starCrescent,
              text: Text(userProfile.zodiac!),
              backgroundColor: iconChipBackgroundColor,
            ),
          if (userProfile.from != null)
            IconChip(
              iconData: Icons.location_on_outlined,
              text: Text(userProfile.from!),
              backgroundColor: iconChipBackgroundColor,
            ),
          if (userProfile.msn != null)
            IconChip(
              iconData: Icons.group_outlined,
              text: Text(userProfile.msn!),
              backgroundColor: iconChipBackgroundColor,
            ),
          if (userProfile.qq != null)
            IconChip(
              iconData: FontAwesomeIcons.qq,
              text: Text(userProfile.qq!),
              iconSize: 14,
              backgroundColor: iconChipBackgroundColor,
            ),
        ],
      ),

      // Self introduction.
      if (introductionContent != null) ...[
        sizedBoxW16H16,
        InputDecorator(
          decoration: InputDecoration(labelText: tr.introduction, filled: false),
          child: munchElement(context, introductionContent),
        ),
      ],

      // Signature.
      if (signatureContent != null) ...[
        sizedBoxW16H16,
        InputDecorator(
          decoration: InputDecoration(labelText: tr.signature, filled: false),
          child: munchElement(context, signatureContent),
        ),
      ],

      // User group
      if (moderatorGroupImg != null || userGroupImg != null) ...[
        _SectionTitle(tr.userGroup),
        Row(
          children: [
            if (moderatorGroupImg != null)
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CachedImage(moderatorGroupImg, maxWidth: 200, maxHeight: _groupAvatarHeight),
                    sizedBoxW4H4,
                    Text(moderatorGroupName ?? '', style: TextStyle(color: moderatorGroupNameColor)),
                  ],
                ),
              ),
            if (moderatorGroupImg != null && userGroupImg != null)
              const SizedBox(width: 20, height: _groupAvatarHeight, child: VerticalDivider()),
            if (userGroupImg != null)
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CachedImage(userGroupImg, maxWidth: 200, maxHeight: _groupAvatarHeight),
                    sizedBoxW4H4,
                    Text(userGroupName ?? '-', style: TextStyle(color: userGroupNameColor)),
                  ],
                ),
              ),
          ],
        ),
      ],

      /// Medals, if any.
      if (userProfile.profileMedals?.isNotEmpty ?? false) ...[
        _SectionTitle(tr.medals),
        MedalGroupView(
          userProfile.profileMedals!
              .map((e) => Medal(name: e.name, image: e.image, alter: e.alter, description: e.description))
              .toList(),
        ),
      ],

      if (userProfile.mangedForums?.isNotEmpty ?? false) ...[
        _SectionTitle(tr.mangedForum),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children:
              userProfile.mangedForums!
                  .map(
                    (e) => ActionChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(e.name),
                      onPressed: () async => context.pushNamed(ScreenPaths.forum, pathParameters: {'fid': '${e.fid}'}),
                    ),
                  )
                  .toList(),
        ),
      ],

      /// Checkin level.
      ..._buildCheckinInfoRow(context, state),

      /// Activity
      _SectionTitle(tr.activityStatus),
      if (userProfile.onlineTime != null)
        _ProfileSectionListTile(
          leading: const Icon(Icons.timelapse_outlined),
          title: Text(tr.onlineTime),
          subtitle: Text(userProfile.onlineTime!),
        ),
      if (userProfile.registerTime != null)
        _ProfileSectionListTile(
          leading: Icon(MdiIcons.timelineAlertOutline),
          title: Text(tr.registerTime),
          subtitle: Text(userProfile.registerTime!.yyyyMMDDHHMM()),
        ),
      if (userProfile.lastVisitTime != null)
        _ProfileSectionListTile(
          leading: Icon(MdiIcons.timelineClockOutline),
          title: Text(tr.lastVisitTime),
          subtitle: Text(userProfile.lastVisitTime!.yyyyMMDDHHMM()),
        ),
      if (userProfile.lastActiveTime != null)
        _ProfileSectionListTile(
          leading: Icon(MdiIcons.timelineCheckOutline),
          title: Text(tr.lastActiveTime),
          subtitle: Text(userProfile.lastActiveTime!.yyyyMMDDHHMM()),
        ),
      if (userProfile.lastPostTime != null)
        _ProfileSectionListTile(
          leading: Icon(MdiIcons.timelinePlusOutline),
          title: Text(tr.lastPostTime),
          subtitle: Text(userProfile.lastPostTime!.yyyyMMDDHHMM()),
        ),
      if (userProfile.timezone != null)
        _ProfileSectionListTile(
          leading: const Icon(Symbols.globe_location_pin),
          title: Text(tr.timezone),
          subtitle: Text(userProfile.timezone!),
        ),
      if (userProfile.registerIP != null)
        ObscureListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 0,
          leading: const Icon(Symbols.add_location_alt),
          title: Text(tr.registerIP),
          subtitle: Text(userProfile.registerIP!),
        ),
      if (userProfile.lastVisitIP != null)
        ObscureListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 0,
          leading: const Icon(Symbols.moved_location),
          title: Text(tr.lastVisitIP),
          subtitle: Text(userProfile.lastVisitIP!),
        ),

      /// Statistics.
      _SectionTitle(tr.statistics.title),
      GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 70),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (userProfile.credits != null) AttrBlock(name: tr.statistics.credits, value: userProfile.credits!),
          if (userProfile.famous != null) AttrBlock(name: tr.statistics.famous, value: userProfile.famous!),
          if (userProfile.coins != null) AttrBlock(name: tr.statistics.coins, value: userProfile.coins!),
          if (userProfile.publicity != null) AttrBlock(name: tr.statistics.publicity, value: userProfile.publicity!),
          if (userProfile.natural != null) AttrBlock(name: tr.statistics.natural, value: userProfile.natural!),
          if (userProfile.scheming != null) AttrBlock(name: tr.statistics.scheming, value: userProfile.scheming!),
          if (userProfile.spirit != null) AttrBlock(name: tr.statistics.spirit, value: userProfile.spirit!),
          // Special attr changes over time.
          // Here is dynamic and not translated.
          if (userProfile.specialAttr != null && userProfile.specialAttrName != null)
            AttrBlock(name: userProfile.specialAttrName!, value: userProfile.specialAttr!),
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
      onRefresh:
          () => context.read<ProfileBloc>().add(ProfileRefreshRequested(uid: widget.uid, username: widget.username)),
      childBuilder:
          (context, physics) => CustomScrollView(
            controller: _scrollController,
            physics: physics,
            slivers: [
              // Real app bar when data loaded.
              _buildSliverAppBar(context, state, logout: logout),
              SliverPadding(
                padding: edgeInsetsL12T4R12,
                sliver: SliverList(delegate: SliverChildListDelegate(_buildSliverContent(context, state))),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_updateAppBarState);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController
      ..removeListener(_updateAppBarState)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ProfileBloc(
            profileRepository: RepositoryProvider.of<ProfileRepository>(context),
            authenticationRepository: RepositoryProvider.of<AuthenticationRepository>(context),
          )..add(ProfileLoadRequested(username: widget.username, uid: widget.uid)),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // Default AppBar only use when loading data or failed to load data.
          // Keep this widget so that user can go back to the previous page in
          // some error state (e.g. network error).
          final appBar = switch (state.status) {
            ProfileStatus.initial ||
            ProfileStatus.loading ||
            ProfileStatus.needLogin ||
            ProfileStatus.failure => AppBar(title: Text(context.t.profilePage.title)),
            ProfileStatus.success || ProfileStatus.loggingOut => null,
          };

          // Main content of user profile.
          // Contain a sliver version app bar to show when data loaded.
          final body = switch (state.status) {
            ProfileStatus.initial || ProfileStatus.loading => const Center(child: CircularProgressIndicator()),
            ProfileStatus.needLogin => NeedLoginPage(
              backUri: GoRouterState.of(context).uri,
              needPop: true,
              popCallback: (context) {
                context.read<ProfileBloc>().add(ProfileRefreshRequested(uid: widget.uid, username: widget.username));
              },
            ),
            ProfileStatus.failure => buildRetryButton(context, () {
              context.read<ProfileBloc>().add(ProfileLoadRequested(username: widget.username, uid: widget.uid));
            }),
            ProfileStatus.success || ProfileStatus.loggingOut => _buildContent(
              context,
              state,
              failedToLogoutReason: state.failedToLogoutReason,
              logout: state.status == ProfileStatus.loggingOut,
            ),
          };

          return Scaffold(appBar: appBar, body: SafeArea(top: false, bottom: false, child: body));
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedBoxW24H24,
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        sizedBoxW12H12,
      ],
    );
  }
}

class _ProfileSectionListTile extends StatelessWidget {
  /// Constructor.
  const _ProfileSectionListTile({required this.leading, required this.title, required this.subtitle});

  /// [ListTile.leading].
  final Widget? leading;

  /// [ListTile.title].
  final Widget? title;

  /// [ListTile.subtitle].
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 0,
      contentPadding: EdgeInsets.zero,
      leading: leading,
      title: title,
      subtitle: subtitle,
    );
  }
}
