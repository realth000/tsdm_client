import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Cubit keep logging in state.
final class _LoggingInCubit extends Cubit<bool> {
  _LoggingInCubit() : super(false);

  void setLoggingIn() => emit(true);

  void setNotLoggingIn() => emit(false);
}

/// Dialog to switch user account.
class SwitchAccountDialog extends StatefulWidget with LoggerMixin {
  /// Constructor.
  const SwitchAccountDialog({super.key});

  @override
  State<SwitchAccountDialog> createState() => _SwitchAccountDialogState();
}

class _SwitchAccountDialogState extends State<SwitchAccountDialog> {
  /// Flag indicating is logging in or not.
  final loggingIn = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.accountSection;
    return BlocProvider(
      create: (_) => _LoggingInCubit(),
      child: BlocBuilder<_LoggingInCubit, bool>(
        builder: (context, state) {
          return AlertDialog(
            scrollable: true,
            title: Row(
              children: [
                Text(tr.switchAccount),
                if (state) ...[
                  sizedBoxW8H8,
                  sizedCircularProgressIndicator,
                ],
              ],
            ),
            content: FutureBuilder(
              future: getIt.get<StorageProvider>().getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Unreachable.
                  return Center(child: Text('${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  final currentUser =
                      context.read<AuthenticationRepository>().currentUser;
                  final users = snapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: users
                          .where(
                            (e) =>
                                e.username != null &&
                                e.username!.isNotEmpty &&
                                e.uid != null &&
                                e.uid != 0,
                          )
                          .map(
                            (e) => _UserInfoListTile(
                              userInfo: e,
                              currentUserInfo: currentUser,
                            ),
                          )
                          .toList(),
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
            actions: [
              TextButton(
                onPressed: state ? null : () async => context.pop(),
                child: Text(context.t.general.cancel),
              ),
              TextButton(
                onPressed: state
                    ? null
                    : () async {
                        await context.pushNamed(ScreenPaths.login);
                        if (!context.mounted) {
                          return;
                        }
                        context.pop();
                      },
                child: Text(tr.loginAnother),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserInfoListTile extends StatelessWidget with LoggerMixin {
  const _UserInfoListTile({
    required this.userInfo,
    required this.currentUserInfo,
  });

  /// User info displayed in this widget.
  final UserLoginInfo userInfo;

  /// Current login user.
  final UserLoginInfo? currentUserInfo;

  Future<void> _callback(BuildContext context) async {
    info('switch user to uid ${"${userInfo.uid}".obscured(4)}');
    context.read<_LoggingInCubit>().setLoggingIn();
    final ret = await context
        .read<AuthenticationRepository>()
        .switchUser(userInfo)
        .run();

    if (ret.isLeft()) {
      handle(ret.unwrapErr());
      if (!context.mounted) {
        return;
      }
      context.read<_LoggingInCubit>().setNotLoggingIn();
      showSnackBar(
        context: context,
        message: '${ret.unwrapErr()}',
      );
      context.pop();
      return;
    }
    if (!context.mounted) {
      return;
    }
    showSnackBar(
      context: context,
      message: context.t.settingsPage.accountSection.switchSuccess,
    );
    context.read<_LoggingInCubit>().setNotLoggingIn();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.accountSection;
    final isCurrentUser = userInfo.uid! == currentUserInfo?.uid;

    return BlocBuilder<_LoggingInCubit, bool>(
      builder: (context, state) {
        return ListTile(
          enabled: !state,
          // TODO: Update user avatar.
          leading: CircleAvatar(child: Text(userInfo.username![0])),
          title: Text(userInfo.username!),
          subtitle: Text('${userInfo.uid!}'),
          trailing: isCurrentUser
              ? Chip(
                  side: BorderSide.none,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  label: Text(
                    tr.online,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                )
              : null,
          onTap:
              (state || isCurrentUser) ? null : () async => _callback(context),
        );
      },
    );
  }
}
