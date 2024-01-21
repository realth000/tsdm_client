import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/features/need_login/view/need_login_page.dart';
import 'package:tsdm_client/features/profile/bloc/profile_bloc.dart';
import 'package:tsdm_client/features/profile/models/user_profile.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/repositories/profile_repository/profile_repository.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/checkin_button/checkin_button.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/obscure_list_tile.dart';

const _avatarWidth = 180.0;
const _avatarHeight = 220.0;

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.uid, this.username, super.key});

  /// Other user uid.
  final String? uid;

  /// Other user username.
  final String? username;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        profileRepository: RepositoryProvider.of<ProfileRepository>(context),
        authenticationRepository:
            RepositoryProvider.of<AuthenticationRepository>(context),
      )..add(ProfileLoadRequested(username: widget.username, uid: widget.uid)),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.t.general.failedToLoad)));
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return switch (state.status) {
              ProfileStatus.initial || ProfileStatus.loading => Scaffold(
                  appBar: AppBar(
                    title: Text(context.t.profilePage.title),
                  ),
                  body: const Center(child: CircularProgressIndicator()),
                ),
              ProfileStatus.needLogin => Scaffold(
                  appBar: AppBar(
                    title: Text(context.t.profilePage.title),
                  ),
                  body: NeedLoginPage(
                    backUri: GoRouterState.of(context).uri,
                    needPop: true,
                    popCallback: (context) {
                      context
                          .read<ProfileBloc>()
                          .add(ProfileRefreshRequested());
                    },
                  ),
                ),
              ProfileStatus.failed => buildRetryButton(context, () {
                  context.read<ProfileBloc>().add(ProfileLoadRequested(
                      username: widget.username, uid: widget.uid));
                }),
              ProfileStatus.success || ProfileStatus.logout => _buildBody(
                  context,
                  state.userProfile!,
                  failedToLogoutReason: state.failedToLogoutReason,
                  logout: state.status == ProfileStatus.logout,
                ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserProfile userProfile, {
    required Exception? failedToLogoutReason,
    required bool logout,
  }) {
    // Check whether have failed logout attempt.
    if (failedToLogoutReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$failedToLogoutReason'),
        ),
      );
    }

    late final List<Widget> actions;
    if (widget.username == null && widget.uid == null) {
      // Current is current logged user's profile page.
      actions = [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
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
      actions = const [];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.profilePage.title),
        actions: actions,
      ),
      body: ListView(
        padding: edgeInsetsL15R15,
        children: [
          if (userProfile.avatarUrl != null)
            CachedImage(
              userProfile.avatarUrl!,
              maxWidth: _avatarWidth,
              maxHeight: _avatarHeight,
            ),
          if (userProfile.username != null)
            ListTile(
              title: Text(context.t.profilePage.username),
              subtitle: Text(userProfile.username!),
            ),
          if (userProfile.uid != null)
            ListTile(
              title: Text(context.t.profilePage.uid),
              subtitle: Text(userProfile.uid!),
            ),
          ...userProfile.basicInfoList.map(
            (e) => ListTile(
              title: Text(e.$1),
              subtitle: Text(e.$2),
            ),
          ),
          if (userProfile.checkinDaysCount != null)
            ListTile(
              title: Text(context.t.profilePage.checkinDaysCount),
              subtitle: Text(userProfile.checkinDaysCount!),
            ),
          if (userProfile.checkinThisMonthCount != null)
            ListTile(
              title: Text(context.t.profilePage.checkinDaysInThisMonth),
              subtitle: Text(userProfile.checkinThisMonthCount!),
            ),
          if (userProfile.checkinRecentTime != null)
            ListTile(
              title: Text(context.t.profilePage.checkinRecentTime),
              subtitle: Text(userProfile.checkinRecentTime!),
            ),
          if (userProfile.checkinAllCoins != null)
            ListTile(
              title: Text(context.t.profilePage.checkinAllCoins),
              subtitle: Text(userProfile.checkinAllCoins!),
            ),
          if (userProfile.checkinLastTimeCoin != null)
            ListTile(
              title: Text(context.t.profilePage.checkinLastTimeCoins),
              subtitle: Text(userProfile.checkinLastTimeCoin!),
            ),
          if (userProfile.checkinLevel != null)
            ListTile(
              title: Text(context.t.profilePage.checkinLevel),
              subtitle: Text(userProfile.checkinLevel!),
            ),
          if (userProfile.checkinNextLevel != null)
            ListTile(
              title: Text(context.t.profilePage.checkinNextLevel),
              subtitle: Text(userProfile.checkinNextLevel!),
            ),
          if (userProfile.checkinNextLevelDays != null)
            ListTile(
              title: Text(context.t.profilePage.checkinNextLevelDays),
              subtitle: Text(userProfile.checkinNextLevelDays!),
            ),
          if (userProfile.checkinTodayStatus != null)
            ListTile(
              title: Text(context.t.profilePage.checkinTodayStatus),
              subtitle: Text(userProfile.checkinTodayStatus!),
            ),
          ...userProfile.activityInfoList.map(
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
}
