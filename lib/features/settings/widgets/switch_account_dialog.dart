import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/authentication/repository/authentication_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Dialog to switch user account.
class SwitchAccountDialog extends StatelessWidget with LoggerMixin {
  /// Constructor.
  const SwitchAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.accountSection;
    return AlertDialog(
      scrollable: true,
      title: Text(tr.switchAccount),
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
                      (e) => ListTile(
                        // TODO: Update user avatar.
                        leading: CircleAvatar(child: Text(e.username![0])),
                        title: Text(e.username!),
                        subtitle: Text('${e.uid!}'),
                        trailing: e.uid! == currentUser?.uid
                            ? Text(
                                tr.online,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              )
                            : null,
                        onTap: () async {
                          info('switch user to uid ${"${e.uid}".obscured(4)}');
                          final ret = await context
                              .read<AuthenticationRepository>()
                              .switchUser(e)
                              .run();

                          if (ret.isLeft()) {
                            error('failed to switch user: $ret');
                            if (!context.mounted) {
                              return;
                            }
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
                          //
                          // await context
                          //     .read<SettingsRepository>()
                          //     .setValue(SettingsKeys.loginUsername,
                          //     e.username);
                          // if (!context.mounted) {
                          //   return;
                          // }
                          // await context
                          //     .read<SettingsRepository>()
                          //     .setValue(SettingsKeys.loginUsername, e.uid);
                          // if (!context.mounted) {
                          //   return;
                          // }
                          context.pop();
                        },
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
          child: Text(tr.loginAnother),
          onPressed: () async {
            await context.pushNamed(ScreenPaths.login);
            if (!context.mounted) {
              return;
            }
            context.pop();
          },
        ),
      ],
    );
  }
}
