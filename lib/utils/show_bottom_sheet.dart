import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';

/// Show a bottom sheet with given [title] and build children
/// with [childrenBuilder].
Future<void> showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required List<Widget> Function(BuildContext context) childrenBuilder,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return Scaffold(
        body: Padding(
          padding: edgeInsetsL15T15R15B15,
          child: Column(
            children: [
              SizedBox(height: 50, child: Center(child: Text(title))),
              sizedBoxW10H10,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: childrenBuilder(context)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Show a bottom sheet offers available actions of the image.
///
/// All available actions:
///
/// * Open image in full page.
/// * Copy image url.
/// * Jump to related href url (optional).
/// * Reload image.
Future<void> showImageActionBottomSheet({
  required BuildContext context,
  required String imageUrl,
  String? hrefUrl,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      final tr = context.t.imageBottomSheet;
      return Scaffold(
        appBar: AppBar(
          title: Text(
            tr.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Padding(
                  padding: edgeInsetsL15T15R15B15,
                  child: NetworkIndicatorImage(imageUrl),
                ),
              ),
            ),
            sizedBoxW10H10,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.fullscreen_outlined),
                      title: Text(tr.checkDetail),
                      onTap: () async {
                        await context.pushNamed(
                          ScreenPaths.imageDetail,
                          pathParameters: {'imageUrl': imageUrl},
                        );
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.copy_outlined),
                      title: Text(tr.copyImageUrl),
                      onTap: () async {
                        await copyToClipboard(context, imageUrl);
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.refresh_outlined),
                      title: Text(tr.reloadImage),
                    ),
                    if (hrefUrl != null)
                      ListTile(
                        leading: const Icon(Icons.link_outlined),
                        title: Text(tr.openLink),
                        onTap: () async {
                          await context.dispatchAsUrl(hrefUrl);
                          if (context.mounted) {
                            context.pop();
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
