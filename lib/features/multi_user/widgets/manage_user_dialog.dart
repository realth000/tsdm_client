import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/multi_user/bloc/switch_user_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/auto_notification_cubit.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Open the user management dialog for the given user with [userInfo].
///
/// [heroTag] is used to specify the unique hero animation on user avatar.
Future<void> openManageUserDialog({
  required BuildContext context,
  required UserLoginInfo userInfo,
  required String heroTag,
}) async => showDialog(
  context: context,
  builder:
      (_) => BlocProvider.value(
        value: context.watch<SwitchUserBloc>(),
        child: RootPage(DialogPaths.manageUser, _ManageUserDialog(userInfo: userInfo, heroTag: heroTag)),
      ),
);

/// Dialog to manage a given user, single one.
class _ManageUserDialog extends StatelessWidget with LoggerMixin {
  /// Constructor.
  const _ManageUserDialog({required this.userInfo, required this.heroTag});

  /// The info about user to manage.
  final UserLoginInfo userInfo;

  /// Tag for user avatar hero.
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.manageAccountPage.switchAccount.dialog;
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      title: Row(
        children: [
          HeroUserAvatar(username: userInfo.username!, avatarUrl: null, disableHero: true, minRadius: 30),
          sizedBoxW12H12,
          Expanded(child: SingleLineText(userInfo.username!, style: Theme.of(context).textTheme.titleLarge)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(tr.switchAccount),
              onTap: () async {
                var times = 10;
                while (context.read<AutoNotificationCubit>().pause('switch user')) {
                  info('switch user is waiting for auto sync lock... $times');
                  times -= 1;
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                  if (times <= 0 || !context.mounted) {
                    info('auto sync lock timeout or canceled, do not switch user');
                    return;
                  }
                }
                context.read<SwitchUserBloc>().add(SwitchUserStartRequested(userInfo));
                context.pop();
              },
            ),
            ListTile(
              title: Text(tr.clearLoginStatus.title),
              subtitle: Text(tr.clearLoginStatus.detail),
              enabled: userInfo.uid != null,
              onTap: () async {
                await getIt.get<StorageProvider>().deleteCookieByUid(userInfo.uid!);
                if (!context.mounted) {
                  return;
                }
                context.pop();
              },
            ),
            ListTile(
              title: Text(tr.loginAgain.title),
              subtitle: Text(tr.loginAgain.detail),
              onTap: () async {
                await context.pushNamed(
                  ScreenPaths.login,
                  queryParameters: {if (userInfo.username != null) 'username': '${userInfo.username}'},
                );
                if (!context.mounted) {
                  return;
                }
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
