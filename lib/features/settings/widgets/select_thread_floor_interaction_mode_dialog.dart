import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/thread_floor_interaction_mode.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:tsdm_client/widgets/selectable_list_tile.dart';

/// Show a dialog to let user select the interaction mode of floors in thread pages.
Future<ThreadFloorInteractionMode?> showSelectThreadFloorInteractionMode(
  BuildContext context,
  ThreadFloorInteractionMode initialMode,
) async => showDialog<ThreadFloorInteractionMode>(
  context: context,
  builder: (context) =>
      RootPage(DialogPaths.selectThreadFloorInteractionMode, _SelectThreadFloorInteractionModeDialog(initialMode)),
);

class _SelectThreadFloorInteractionModeDialog extends StatelessWidget {
  const _SelectThreadFloorInteractionModeDialog(this.initialMode);

  final ThreadFloorInteractionMode initialMode;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.behaviorSection.threadFloorInteractionMode;
    return CustomAlertDialog.sync(
      title: Text(tr.title),
      content: Column(
        children: [
          SelectableListTile(
            title: Text(tr.adaptiveTapOpenContextMenu),
            selected: initialMode == ThreadFloorInteractionMode.adaptiveTapMenu,
            onTap: () => context.pop(ThreadFloorInteractionMode.adaptiveTapMenu),
          ),
          SelectableListTile(
            title: Text(tr.tapToReply),
            selected: initialMode == ThreadFloorInteractionMode.tapToReply,
            onTap: () => context.pop(ThreadFloorInteractionMode.tapToReply),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
