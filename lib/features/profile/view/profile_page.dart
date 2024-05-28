import 'dart:ui';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
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
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/checkin_button/checkin_button.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/icon_chip.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';
import 'package:universal_html/parsing.dart';

const _appBarBackgroundImageHeight = 120.0;
const _appBarAvatarHeight = 80.0;
const _appBarExpandHeight = _appBarBackgroundImageHeight + _appBarAvatarHeight;

/// Page of user profile.
class ProfilePage extends StatefulWidget {
  /// Constructor.
  const ProfilePage({this.uid, this.username, super.key});

  /// Other user uid.
  final String? uid;

  /// Other user username.
  final String? username;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _refreshController = EasyRefreshController(controlFinishRefresh: true);
  final _scrollController = ScrollController();

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
          onPressed: () async =>
              context.read<ProfileBloc>().add(ProfileLogoutRequested()),
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

    // Title in app bar.
    final title = LayoutBuilder(
      builder: (context, cons) => Row(
        children: [
          CircleAvatar(
            radius: _appBarAvatarHeight / 2 + 3,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: ClipOval(
              child: CachedImage(
                userProfile.avatarUrl ?? noAvatarUrl,
                maxWidth: _appBarAvatarHeight,
                maxHeight: _appBarAvatarHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );

    if (userProfile.avatarUrl != null) {
      flexSpace = Stack(
        // Disable clip, let profile avatar show outside the stack.
        clipBehavior: Clip.none,
        children: [
          // Background blurred image.
          Align(
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, cons) => ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: CachedImage(
                  userProfile.avatarUrl!,
                  // Set to max width, ensure fill all width.
                  maxWidth: cons.maxWidth,
                  fit: BoxFit.cover,
                ),
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

  List<Widget> _buildSliverContent(BuildContext context, ProfileState state) {
    final tr = context.t.profilePage;
    final userProfile = state.userProfile!;

    // Friends count info.
    final friendsInfoNode =
        parseHtmlDocument(userProfile.friendsCount ?? '0').body;
    final friendsCount =
        friendsInfoNode?.innerText.split(' ').lastOrNull ?? '-';
    final friendsPage =
        friendsInfoNode?.querySelector('a')?.attributes['href']?.prependHost();

    // Birthday.
    final birthDayText = [
      userProfile.birthdayYear,
      userProfile.birthdayMonth,
      userProfile.birthdayDay,
    ].whereType<String>().join('.');

    // Signature.
    final signatureContent =
        parseHtmlDocument(userProfile.signature ?? '').body;

    // All content widgets in profile main sliver list.
    return [
      // Username
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          sizedBoxW10H10,
          GestureDetector(
            child: SingleLineText(
              userProfile.username ?? context.t.profilePage.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
      sizedBoxW5H5,
      Row(
        children: <Widget>[
          if (userProfile.uid != null)
            // Email verify state.
            IconButton(
              icon: const Icon(Icons.email_outlined),
              onPressed: () async {
                final content = userProfile.emailVerified ?? false
                    ? tr.emailVerified
                    : tr.emailNotVerified;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(content)));
              },
              isSelected: userProfile.emailVerified ?? false,
            ),
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: () async {
              final content = userProfile.videoVerified ?? false
                  ? tr.videoVerified
                  : tr.videoNotVerified;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(content)));
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
        ].insertBetween(sizedBoxW10H10),
      ),
      Row(
        children: [
          if (birthDayText.isNotEmpty)
            IconChip(
              icon: const Icon(Icons.cake_outlined),
              text: Text(birthDayText),
            ),
          if (userProfile.from != null)
            IconChip(
              icon: const Icon(Icons.location_on_outlined),
              text: Text(userProfile.from!),
            ),
        ],
      ),
      Row(
        children: [
          if (userProfile.zodiac != null)
            IconChip(
              icon: Icon(MdiIcons.starCrescent),
              text: Text(userProfile.zodiac!),
            ),
        ],
      ),
      ListTile(
        title: Text(tr.customTitle),
        subtitle: Text(state.userProfile?.customTitle ?? ''),
      ),
      ListTile(
        title: Text(tr.signature),
        subtitle: signatureContent != null
            ? munchElement(context, signatureContent)
            : const SizedBox.shrink(),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$failedToLogoutReason')));
    }

    _refreshController.finishRefresh();

    return EasyRefresh(
      controller: _refreshController,
      scrollController: _scrollController,
      header: const MaterialHeader(),
      onRefresh: () =>
          context.read<ProfileBloc>().add(ProfileRefreshRequested()),
      child: CustomScrollView(
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t.general.failedToLoad)),
            );
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
