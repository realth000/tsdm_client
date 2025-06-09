import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/post/view/fast_reply_edit_template_page.dart';
import 'package:tsdm_client/features/post/widgets/fast_reply_template_card.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Page to view all templates for fast reply.
class FastReplyTemplatePage extends StatefulWidget {
  /// Constructor.
  const FastReplyTemplatePage({required this.pick, super.key});

  /// Pick template or edit one.
  final bool pick;

  @override
  State<FastReplyTemplatePage> createState() => _FastReplyTemplatePageState();
}

class _FastReplyTemplatePageState extends State<FastReplyTemplatePage> with LoggerMixin {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.fastReplyTemplate;
    final stream = getIt.get<StorageProvider>().watchAllFastReplyTemplate();

    final body = StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          error('failed to load fast reply templates: ${snapshot.error!}');
          return Center(child: Text(context.t.general.failedToLoad));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTemplates = snapshot.data!;

        if (allTemplates.isEmpty) {
          return Center(
            child: Text(
              tr.empty,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: edgeInsetsL12T8R12,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTemplates
                  .map(
                    (e) => FastReplyTemplateCard(
                      key: ValueKey('FastReplyTemplateCard_${e.name}'),
                      replyTemplate: e,
                      allowEdit: !widget.pick,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pick ? tr.pick : tr.title),
        actions: [
          // Add new reply template.
          IconButton(
            icon: const Icon(Icons.add_outlined),
            tooltip: tr.editPageTitle,
            onPressed: () async {
              final editResult = await context.pushNamed<FastReplyTemplateModel>(
                ScreenPaths.fastReplyTemplateEdit,
                pathParameters: {'editType': '${FastReplyTemplateEditType.create.index}'},
              );

              if (editResult == null || !context.mounted) {
                return;
              }

              await getIt.get<StorageProvider>().saveFastReplyTemplate(editResult).run();
              if (!context.mounted) {
                return;
              }
              showSnackBar(context: context, message: tr.editPageTemplateAdded);
            },
          ),
        ],
      ),
      body: SafeArea(bottom: false, top: false, child: body),
    );
  }
}
