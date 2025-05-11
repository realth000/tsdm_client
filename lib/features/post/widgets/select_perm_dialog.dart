import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';

/// Show a dialog to let user select a read permission value for current thread.
Future<String?> showSelectPermDialog(BuildContext context, List<ThreadPerm> permList, String? initialPerm) async =>
    showDialog<String>(context: context,
        builder: (context) => RootPage(DialogPaths.selectPerm, _SelectPermDialog(permList, initialPerm)));

/// Dialog to let user select a value of available read permissions.
class _SelectPermDialog extends StatefulWidget {
  const _SelectPermDialog(this.permList, this.initialPerm);

  /// All perms available.
  final List<ThreadPerm> permList;

  /// Initial perm value.
  final String? initialPerm;

  @override
  State<_SelectPermDialog> createState() => _SelectPermDialogState();
}

class _SelectPermDialogState extends State<_SelectPermDialog> {
  /// Current selected permission.
  String? currentPerm;

  @override
  void initState() {
    super.initState();
    currentPerm = widget.initialPerm;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t.postEditPage.permDialog.title),
      content: Column(
        children:
        widget.permList
            .map(
              (e) =>
              RadioListTile(
                title: Text(e.groupName),
                subtitle: Text(e.perm),
                value: e.perm,
                groupValue: currentPerm,
                onChanged: (v) {
                  setState(() {
                    currentPerm = e.perm;
                  });
                  context.pop(currentPerm);
                },
              ),
        )
            .toList(),
      ),
      scrollable: true,
    );
  }
}
