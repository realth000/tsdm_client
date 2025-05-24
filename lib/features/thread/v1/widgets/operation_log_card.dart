import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/thread/v1/repository/thread_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

Future<void> _showOperationLogDialog(BuildContext context, String tid) async {
  final tr = context.t.threadPage.operationLog;
  await showDialog<void>(
    context: context,
    builder: (_) {
      return RootPage(
        DialogPaths.showOperationLog,
        AlertDialog(
          title: Text(tr.title),
          content: FutureBuilder(
            future: context.read<ThreadRepository>().fetchOperationLog(tid).run(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('${snapshot.error!}');
              }

              if (!snapshot.hasData) {
                return const SizedBox(width: 50, height: 50, child: Align(child: CircularProgressIndicator()));
              }

              final actions = snapshot.data!;
              if (actions.isLeft()) {
                return Text(context.t.general.failedToLoad);
              }

              final content = actions.unwrap().map(
                    (e) =>
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      isThreeLine: true,
                      leading: GestureDetector(
                        onTap: () async =>
                            context.pushNamed(ScreenPaths.profile, queryParameters: {
                              'username': e.username
                            }),
                        child: HeroUserAvatar(username: e.username, avatarUrl: null, disableHero: true),
                      ),
                      title: GestureDetector(
                        onTap: () async =>
                            context.pushNamed(ScreenPaths.profile, queryParameters: {
                              'username': e.username
                            }),
                        child: Text(e.username),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleLineText(e.time.yyyyMMDDHHMMSS(), style: Theme
                              .of(context)
                              .textTheme
                              .labelMedium),
                          SingleLineText(
                            '${e.action}${e.duration != null ? "（${e.duration}）" : ""}',
                            style: Theme
                                .of(
                              context,
                            )
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Theme
                                .of(context)
                                .colorScheme
                                .primary),
                          ),
                        ],
                      ),
                    ),
              );
              return SingleChildScrollView(child: Column(children: content.toList()));
            },
          ),
        ),
      );
    },
  );
}

/// Card shows thread operation log.
class OperationLogCard extends StatelessWidget {
  /// Constructor.
  const OperationLogCard({required this.latestAction, required this.tid, super.key});

  /// The latest action to show.
  final String latestAction;

  /// Thread id.
  final String tid;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      shape: const OutlineInputBorder(borderSide: BorderSide.none),
      child: InkWell(
        onTap: () async => _showOperationLogDialog(context, tid),
        child: Padding(
          padding: edgeInsetsL12T4R12B4,
          child: Row(
            children: [
              Icon(Icons.manage_history_outlined, size: 16, color: Theme
                  .of(context)
                  .colorScheme
                  .onSurfaceVariant),
              sizedBoxW8H8,
              Expanded(
                child: Text(latestAction, style: TextStyle(color: Theme
                    .of(context)
                    .colorScheme
                    .onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
