import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_trigger_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';

/// Show a bottom sheet with given [title] and build children
/// with [childrenBuilder].
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required String title,
  PreferredSizeWidget? pinnedWidget,
  List<Widget> Function(BuildContext context)? childrenBuilder,
  Widget Function(BuildContext context)? builder,
  BoxConstraints? constraints,
  bool useExpand = true,
}) async {
  assert(builder != null || childrenBuilder != null, 'must provide builder or childrenBuilder');
  final Widget content;
  if (builder != null) {
    content = builder.call(context);
  } else {
    content = SingleChildScrollView(child: Column(children: childrenBuilder!(context)));
  }
  final ret = await showModalBottomSheet<T>(
    context: context,
    constraints: constraints,
    showDragHandle: true,
    builder: (_) {
      return Padding(
        padding: edgeInsetsL12T4R12B12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (pinnedWidget != null) ...[sizedBoxW8H8, pinnedWidget],
            sizedBoxW12H12,
            if (useExpand) Expanded(child: content) else content,
          ],
        ),
      );
    },
  );

  return ret;
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
    showDragHandle: true,
    builder: (context) {
      final tr = context.t.imageBottomSheet;
      return Padding(
        padding: edgeInsetsL12T4R12B12,
        child: Column(
          children: [
            Center(child: Text(tr.title, style: Theme.of(context).textTheme.titleLarge)),
            sizedBoxW12H12,
            Align(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: Padding(padding: edgeInsetsT4B4, child: NetworkIndicatorImage(imageUrl)),
                ),
              ),
            ),
            sizedBoxW12H12,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.fullscreen_outlined),
                      title: Text(tr.checkDetail),
                      onTap: () async {
                        await context.pushNamed(ScreenPaths.imageDetail, pathParameters: {'imageUrl': imageUrl});
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.copy_outlined),
                      title: Text(tr.copyImageUrl),
                      subtitle: Text(imageUrl),
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
                      onTap: () => context.read<ImageCacheTriggerCubit>().updateImageCache(imageUrl, force: true),
                    ),
                    if (hrefUrl != null)
                      ListTile(
                        leading: const Icon(Icons.link_outlined),
                        title: Text(tr.openLink),
                        subtitle: Text(hrefUrl),
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
