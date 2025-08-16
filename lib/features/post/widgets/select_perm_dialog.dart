import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:tsdm_client/widgets/selectable_list_tile.dart';

/// Show a dialog to let user select a read permission value for current thread.
Future<ThreadPerm?> showSelectPermDialog(
  BuildContext context,
  List<ThreadPerm> permList,
  ThreadPerm? initialPerm,
) async => showDialog<ThreadPerm>(
  context: context,
  builder: (context) => RootPage(DialogPaths.selectPerm, _SelectPermDialog(permList, initialPerm)),
);

/// Dialog to let user select a value of available read permissions.
class _SelectPermDialog extends StatefulWidget {
  const _SelectPermDialog(this.permList, this.initialPerm);

  /// All perms available.
  final List<ThreadPerm> permList;

  /// Initial perm value.
  final ThreadPerm? initialPerm;

  @override
  State<_SelectPermDialog> createState() => _SelectPermDialogState();
}

class _SelectPermDialogState extends State<_SelectPermDialog> {
  /// Current selected permission.
  ThreadPerm? currentPerm;

  late final Map<int, List<ThreadPerm>> groupMap;

  @override
  void initState() {
    super.initState();
    currentPerm = widget.initialPerm;
    groupMap = {};
    for (final perm in widget.permList) {
      groupMap[int.tryParse(perm.perm) ?? 0] = (groupMap[int.tryParse(perm.perm) ?? 0] ?? [])..add(perm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog.sync(
      title: Text(context.t.postEditPage.permDialog.title),
      content: Column(
        children: groupMap.keys
            .sorted(
              (a, b) => a < b
                  ? -1
                  : a > b
                  ? 1
                  : 0,
            )
            .map(
              (e) => SelectableListTile(
                title: Text('$e', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                subtitle: Text(
                  groupMap[e]!.map((p) => p.groupName).join(' '),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                selected: currentPerm?.perm == '$e',
                onTap: () {
                  setState(() {
                    currentPerm = groupMap[e]!.first;
                  });
                  context.pop(currentPerm);
                },
              ),
            )
            .toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
