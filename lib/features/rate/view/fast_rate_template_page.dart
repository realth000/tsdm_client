import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/rate/view/fast_rate_edit_template_page.dart';
import 'package:tsdm_client/features/rate/widgets/fast_rate_template_card.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Page to view and edit fast rate templates.
///
/// A fast rate template is a set of values on each user attribute, user could use the template to fill the values
/// in rate page.
class FastRateTemplatePage extends StatefulWidget {
  /// Constructor.
  const FastRateTemplatePage({required this.pick, super.key});

  /// Pick template or edit one.
  final bool pick;

  @override
  State<FastRateTemplatePage> createState() => _FastRateTemplatePageState();
}

class _FastRateTemplatePageState extends State<FastRateTemplatePage> with LoggerMixin {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.fastRateTemplate;
    final stream = getIt.get<StorageProvider>().watchAllFastRateTemplate();

    final body = StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          error('failed to load fast rate templates: ${snapshot.error!}');
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
                    (e) => FastRateTemplateCard(
                      key: ValueKey('FastRateTemplateCard_${e.hashCode}'),
                      rateTemplate: e,
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
          IconButton(
            icon: const Icon(Icons.add_outlined),
            tooltip: tr.editPageTitle,
            onPressed: () async {
              final editResult = await context.pushNamed<FastRateTemplateModel>(
                ScreenPaths.fastRateTemplateEdit,
                pathParameters: {'editType': '${FastRateTemplateEditType.create.index}'},
              );
              if (editResult == null || !context.mounted) {
                return;
              }

              // Save added result.
              await getIt.get<StorageProvider>().saveFastRateTemplate(editResult).run();
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
