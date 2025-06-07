import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/post/view/fast_reply_edit_template_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/show_dialog.dart';

/// Actions in popup menu.
enum _MenuAction {
  /// Edit current template.
  edit,

  /// Delete current template.
  delete,
}

/// Card showing fast reply template content.
class FastReplyTemplateCard extends StatefulWidget {
  /// Constructor.
  const FastReplyTemplateCard({required this.replyTemplate, this.allowEdit = false, super.key});

  /// The initial rate template.
  final FastReplyTemplateModel replyTemplate;

  /// Flag indicating the template card is editable or not.
  ///
  /// Only set to true when need it.
  final bool allowEdit;

  @override
  State<FastReplyTemplateCard> createState() => _FastReplyTemplateCardState();
}

class _FastReplyTemplateCardState extends State<FastReplyTemplateCard> {
  late FastReplyTemplateModel replyTemplate;

  Future<void> openMenu(TapUpDetails details) async {
    final tr = context.t.fastReplyTemplate;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) {
      return;
    }

    final action = await showMenu<_MenuAction>(
      context: context,
      position: RelativeRect.fromRect(details.globalPosition & const Size(40, 40), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(value: _MenuAction.edit, child: Text(tr.edit)),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: Text(tr.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ],
    );

    if (action == null || !mounted) {
      return;
    }

    switch (action) {
      case _MenuAction.edit:
        final editResult = await context.pushNamed<FastReplyTemplateModel>(
          ScreenPaths.fastReplyTemplateEdit,
          pathParameters: {'editType': '${FastReplyTemplateEditType.edit.index}'},
          extra: replyTemplate,
        );
        if (editResult == null || !context.mounted) {
          return;
        }
        // Save added result.
        await getIt.get<StorageProvider>().deleteFastReplyTemplateByName(replyTemplate.name).run();
        await getIt.get<StorageProvider>().saveFastReplyTemplate(editResult).run();
      case _MenuAction.delete:
        final delete = await showQuestionDialog(
          context: context,
          title: tr.delete,
          richMessage: tr.deleteConfirm(
            name: TextSpan(
              text: replyTemplate.name,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          dangerous: true,
        );
        if (delete != true || !context.mounted) {
          return;
        }
        await getIt.get<StorageProvider>().deleteFastReplyTemplateByName(replyTemplate.name).run();
    }
  }

  Future<void> popBack() async {
    context.pop(replyTemplate);
  }

  @override
  void initState() {
    super.initState();
    replyTemplate = widget.replyTemplate;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTapUp: !widget.allowEdit ? (_) => popBack() : openMenu,
        child: Padding(
          padding: edgeInsetsL12T12R12B12,
          child: Column(
            children: [
              Text(
                replyTemplate.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              sizedBoxW8H8,
              Text(maxLines: 3, replyTemplate.data.truncate(40, ellipsis: true)),
            ],
          ),
        ),
      ),
    );
  }
}
