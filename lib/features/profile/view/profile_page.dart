import 'dart:ui';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/profile/bloc/profile_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/shared/repositories/settings_repository/settings_repository.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/checkin_button/checkin_button.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

// const _avatarWidth = 180.0;
// const _avatarHeight = 220.0;
const _appBarExpandHeight = 160.0;

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
              'uid': widget.uid!,
            },
            extra: <String, dynamic>{
              'username': userProfile.username,
            },
          ),
        ),
      ];
    }

    _refreshController.finishRefresh();

    Widget? backgroundImage;

    if (userProfile.avatarUrl != null) {
      backgroundImage = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: CachedImage(userProfile.avatarUrl!, fit: BoxFit.cover),
      );
    }

    final title = LayoutBuilder(
      builder: (context, cons) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipOval(
            child: CachedImage(
              userProfile.avatarUrl ?? noAvatarUrl,
              // [56, 160]  -> [20, 60]
              maxWidth: cons.maxHeight * 5 / 26 + 380 / 13,
              maxHeight: cons.maxHeight * 5 / 26 + 380 / 13,
              fit: BoxFit.cover,
            ),
          ),
          title: GestureDetector(
            child: SingleLineText(
              userProfile.username ?? context.t.profilePage.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(),
            ),
            onTap: () async =>
                copyToClipboard(context, userProfile.username ?? ''),
          ),
          // subtitle: subtitle,
        );
      },
    );

    // TODO: Migrate this logic part into bloc.
    final basicInfoList = userProfile.basicInfoList.map((e) {
      if (e.$1 == '邮箱状态') {
        if (e.$2 == '已认证') {
          return Chip(
            avatar: Icon(Icons.email_outlined),
            label: Text('true'),
            side: BorderSide.none,
          );
        } else {
          return Chip(
            avatar: Icon(Icons.email_outlined),
            label: Text('false'),
            side: BorderSide.none,
          );
        }
      }
      if (e.$1 == '视频认证') {
        if (e.$2 == '已认证') {
          return Chip(
            avatar: Icon(Icons.photo_camera_front_outlined),
            label: Text('true'),
            side: BorderSide.none,
          );
        } else {
          return Chip(
            avatar: Icon(Icons.photo_camera_front_outlined),
            label: Text('false'),
            side: BorderSide.none,
          );
        }
      }
    }).whereType<Widget>();

    return Scaffold(
      body: EasyRefresh(
        controller: _refreshController,
        scrollController: _scrollController,
        header: const MaterialHeader(),
        onRefresh: () {
          context.read<ProfileBloc>().add(ProfileRefreshRequested());
        },
        child: CustomScrollView(
          // padding: edgeInsetsL15R15,
          slivers: [
            // Real app bar when data loaded.
            SliverAppBar(
              pinned: true,
              floating: true,
              actions: actions,
              expandedHeight: _appBarExpandHeight,
              flexibleSpace: FlexibleSpaceBar(
                background: backgroundImage,
                titlePadding: edgeInsetsL60B10,
                centerTitle: true,
                title: title,
              ),
            ),
            SliverPadding(
              padding: edgeInsetsL10T5R10,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Row(
                      children: [
                        if (userProfile.uid != null)
                          InputChip(
                            avatar: const Icon(Icons.badge_outlined),
                            label: Text(userProfile.uid!),
                            onPressed: () async =>
                                copyToClipboard(context, userProfile.uid!),
                            side: BorderSide.none,
                          ),
                        ...basicInfoList,
                      ].insertBetween(sizedBoxW10H10),
                    ),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                    ListTile(title: Text('1')),
                  ],
                ),
              ),
            ),
            // CachedImage(
            //   userProfile.avatarUrl ?? noAvatarUrl,
            //   maxWidth: _avatarWidth,
            //   maxHeight: _avatarHeight,
            // ),
            // if (userProfile.username != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.username),
            //     subtitle: Text(userProfile.username!),
            //   ),
            // if (userProfile.uid != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.uid),
            //     subtitle: Text(userProfile.uid!),
            //   ),
            // ...userProfile.basicInfoList.map(
            //   (e) => ListTile(
            //     title: Text(e.$1),
            //     subtitle: Text(e.$2),
            //   ),
            // ),
            // if (userProfile.checkinDaysCount != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinDaysCount),
            //     subtitle: Text(userProfile.checkinDaysCount!),
            //   ),
            // if (userProfile.checkinThisMonthCount != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinDaysInThisMonth),
            //     subtitle: Text(userProfile.checkinThisMonthCount!),
            //   ),
            // if (userProfile.checkinRecentTime != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinRecentTime),
            //     subtitle: Text(userProfile.checkinRecentTime!),
            //   ),
            // if (userProfile.checkinAllCoins != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinAllCoins),
            //     subtitle: Text(userProfile.checkinAllCoins!),
            //   ),
            // if (userProfile.checkinLastTimeCoin != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinLastTimeCoins),
            //     subtitle: Text(userProfile.checkinLastTimeCoin!),
            //   ),
            // if (userProfile.checkinLevel != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinLevel),
            //     subtitle: Text(userProfile.checkinLevel!),
            //   ),
            // if (userProfile.checkinNextLevel != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinNextLevel),
            //     subtitle: Text(userProfile.checkinNextLevel!),
            //   ),
            // if (userProfile.checkinNextLevelDays != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinNextLevelDays),
            //     subtitle: Text(userProfile.checkinNextLevelDays!),
            //   ),
            // if (userProfile.checkinTodayStatus != null)
            //   ListTile(
            //     title: Text(context.t.profilePage.checkinTodayStatus),
            //     subtitle: Text(userProfile.checkinTodayStatus!),
            //   ),
            // ...userProfile.activityInfoList.map(
            //   (e) {
            //     // Privacy contents should use ObscureListTile.
            //     if (e.$1.contains('IP')) {
            //       return ObscureListTile(
            //         title: Text(e.$1),
            //         subtitle: Text(e.$2),
            //       );
            //     } else {
            //       return ListTile(
            //         title: Text(e.$1),
            //         subtitle: Text(e.$2),
            //       );
            //     }
            //   },
            // ),
          ],
        ),
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
            body: body,
          );
        },
      ),
    );
  }
}
