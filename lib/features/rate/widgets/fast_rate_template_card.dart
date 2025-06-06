import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/rate/view/fast_rate_edit_template_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/attr_block.dart';

/// Actions in popup menu.
enum _MenuAction {
  /// Edit current template.
  edit,

  /// Delete current template.
  delete,
}

/// Card displaying a single fast rate template.
///
/// Can be used in both applying templates and editing templates. When editing one, an extra edit dialog is available
/// when tapping the card.
class FastRateTemplateCard extends StatefulWidget {
  /// Constructor.
  const FastRateTemplateCard({required this.rateTemplate, this.allowEdit = false, super.key});

  /// The initial rate template.
  final FastRateTemplateModel rateTemplate;

  /// Flag indicating the template card is editable or not.
  ///
  /// Only set to true when need it.
  final bool allowEdit;

  @override
  State<FastRateTemplateCard> createState() => _FastRateTemplateCardState();
}

class _FastRateTemplateCardState extends State<FastRateTemplateCard> {
  /// Current rate template used as state.
  late FastRateTemplateModel rateTemplate;

  Future<void> openMenu(TapUpDetails details) async {
    final tr = context.t.fastRateTemplate;
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
        final editResult = await context.pushNamed<FastRateTemplateModel>(
          ScreenPaths.fastRateTemplateEdit,
          pathParameters: {'editType': '${FastRateTemplateEditType.edit.index}'},
          extra: rateTemplate,
        );
        if (editResult == null || !context.mounted) {
          return;
        }
        // Save added result.
        await getIt.get<StorageProvider>().deleteFastRateTemplateByName(rateTemplate.name).run();
        await getIt.get<StorageProvider>().saveFastRateTemplate(editResult).run();
      case _MenuAction.delete:
        final delete = await showQuestionDialog(
          context: context,
          title: tr.delete,
          message: tr.deleteConfirm,
          dangerous: true,
        );
        if (delete != true || !context.mounted) {
          return;
        }
        await getIt.get<StorageProvider>().deleteFastRateTemplateByName(rateTemplate.name).run();
    }
  }

  Future<void> popBack() async {
    context.pop(rateTemplate);
  }

  @override
  void initState() {
    super.initState();
    rateTemplate = widget.rateTemplate;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.fastRateTemplate;
    final nameStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline);
    final valueStyle = Theme.of(context).textTheme.labelMedium;

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
                rateTemplate.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              sizedBoxW8H8,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AttrBlock(name: tr.ww, value: '${rateTemplate.ww}', nameStyle: nameStyle, valueStyle: valueStyle),
                  AttrBlock(name: tr.tsb, value: '${rateTemplate.tsb}', nameStyle: nameStyle, valueStyle: valueStyle),
                  AttrBlock(name: tr.xc, value: '${rateTemplate.xc}', nameStyle: nameStyle, valueStyle: valueStyle),
                  AttrBlock(name: tr.tr, value: '${rateTemplate.tr}', nameStyle: nameStyle, valueStyle: valueStyle),
                  AttrBlock(name: tr.fh, value: '${rateTemplate.fh}', nameStyle: nameStyle, valueStyle: valueStyle),
                  AttrBlock(name: tr.jl, value: '${rateTemplate.jl}', nameStyle: nameStyle, valueStyle: valueStyle),
                  AttrBlock(
                    name: tr.special,
                    value: '${rateTemplate.special}',
                    nameStyle: nameStyle,
                    valueStyle: valueStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
