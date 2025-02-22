import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/thread/v1/repository/thread_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

Future<void> _showOperationLogDialog(BuildContext context, String tid) async {
  await showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Operation log'),
        scrollable: true,
        content: FutureBuilder(
          future: context.read<ThreadRepository>().fetchOperationLog(tid).run(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('${snapshot.error!}');
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final actions = snapshot.data!;
            if (actions.isLeft()) {
              return Text(context.t.general.failedToLoad);
            }

            final content =
                actions
                    .unwrap()
                    .map(
                      (e) => [
                        ListTile(
                          title: Text(e.username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleLineText(e.time.yyyyMMDDHHMMSS()),
                              if (e.duration != null) Text(e.action) else Text('${e.action} ? ${e.duration}'),
                            ],
                          ),
                        ),
                      ],
                    )
                    .flattenedToList;
            return Column(children: content);
          },
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
    return Padding(
      padding: edgeInsetsL12T4R12B4,
      child: Card(
        margin: EdgeInsets.zero,
        shape: const OutlineInputBorder(borderSide: BorderSide.none),
        child: InkWell(
          onTap: () async => _showOperationLogDialog(context, tid),
          child: Row(
            children: [
              sizedBoxW12H12,
              Icon(Icons.manage_history_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              Padding(
                padding: edgeInsetsL12T4R12B4,
                child: Text(latestAction, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
