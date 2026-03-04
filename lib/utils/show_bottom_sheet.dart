import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show None, Some;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/cache/bloc/image_cache_trigger_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/models/models.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';

/// Show a bottom sheet with given [title] and build children
/// with [childrenBuilder].
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required String title,
  List<Widget> Function(BuildContext context)? childrenBuilder,
  Widget Function(BuildContext context)? builder,
  Widget? bottomBar,
  BottomSheetTopBar? topBar,
}) async {
  assert(builder != null || childrenBuilder != null, 'must provide builder or childrenBuilder');
  final Widget content;
  if (builder != null) {
    content = builder.call(context);
  } else {
    content = ListView(
      shrinkWrap: true,
      padding: context.safePadding(),
      children: childrenBuilder!(context),
    );
  }

  // Copied from [showHeroDialog]
  final ret = Navigator.push<T>(
    context,
    ModalSheetRoute(
      maintainState: false,
      swipeDismissible: true,
      // Here we do not have a context carrying expected padding values.
      // Set the maximum height to 80% to avoid covered by status bar.
      viewportBuilder: (context, child) => SheetViewport(
        padding: EdgeInsets.only(
          // Add a top padding to avoid the status bar.
          top: MediaQuery.viewPaddingOf(context).top,
        ),
        child: child,
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: Sheet(
            decoration: const MaterialSheetDecoration(size: SheetSize.stretch),
            // snapGrid: const SheetSnapGrid(snaps: [SheetOffset(0.5), SheetOffset(1)]),
            // Specify a scroll configuration to make the sheet scrollable.
            scrollConfiguration: const SheetScrollConfiguration(),
            // Sheet widget works with any scrollable widget such as
            // ListView, GridView, CustomScrollView, etc.
            child: SheetContentScaffold(
              backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
              topBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight + (topBar?.height ?? 0)),
                // preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Stack(
                  children: [
                    Align(
                      alignment: .topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                    if (topBar != null) Positioned(top: kToolbarHeight, child: topBar),
                    Positioned(
                      top: 12,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close_outlined),
                        tooltip: context.t.general.close,
                        onPressed: () async => context.pop(),
                      ),
                    ),
                  ],
                ),
              ),
              body: content,
              bottomBar: bottomBar,
            ),
          ),
        );
      },
      // transitionsBuilder: (context, ani1, ani2, child) {
      //   return FadeTransition(opacity: CurveTween(curve: Curves.easeIn).animate(ani1), child: child);
      // },
    ),
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
  final tr = context.t.imageBottomSheet;

  await showCustomBottomSheet<void>(
    context: context,
    title: tr.title,
    childrenBuilder: (context) => [
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
      ListTile(
        leading: const Icon(Icons.save_outlined),
        title: Text(tr.saveImage),
        onTap: () async {
          final imageProvider = getIt.get<ImageCacheProvider>();
          switch (await imageProvider.getOrMakeCache(ImageCacheGeneralRequest(imageUrl))) {
            case None():
              {
                if (context.mounted) {
                  showSnackBar(context: context, message: tr.failedToSaveImage);
                }
              }
            case Some<Uint8List>(value: final data):
              {
                final fileName =
                    imageUrl.tryParseAsUri()?.pathSegments.lastOrNull ??
                    'tsdm_client_image_${DateTime.now().microsecondsSinceEpoch}.jpg';
                if (isDesktop) {
                  // On desktop platforms, `saveFiles` only return the selected path.
                  final filePath = await FilePicker.platform.saveFile(dialogTitle: tr.saveImage, fileName: fileName);
                  if (filePath == null) {
                    return;
                  }

                  await File(filePath).writeAsBytes(data, flush: true);
                  if (context.mounted) {
                    context.pop();
                    showSnackBar(
                      context: context,
                      message: tr.imageSaved(filePath: filePath),
                    );
                  }
                } else {
                  // Mobile in one step.
                  final filePath = await FilePicker.platform.saveFile(
                    dialogTitle: tr.saveImage,
                    fileName: fileName,
                    bytes: data,
                  );
                  if (filePath != null && context.mounted) {
                    context.pop();
                    showSnackBar(
                      context: context,
                      message: tr.imageSaved(filePath: filePath),
                    );
                  }
                }
              }
          }
        },
      ),
    ],
  );
}

/// Show a bottom sheet for url info and related actions.
Future<void> showUrlInfoBottomSheet({
  required BuildContext context,
  required String url,
}) async {
  final tr = context.t.urlInfoBottomSheet;
  final theme = Theme.of(context);

  final route = url.parseUrlToRoute();
  final isInternal = route != null;
  final parseResultTitle = isInternal ? tr.urlTypes.internal.title : tr.urlTypes.external.title;
  final parseResultDetail = isInternal ? tr.urlTypes.internal.detail : tr.urlTypes.external.detail;

  await showCustomBottomSheet<void>(
    context: context,
    title: tr.title,
    childrenBuilder: (context) {
      return [
        Container(
          width: double.infinity,
          padding: edgeInsetsL12T12R12B12.add(edgeInsetsL8R8),
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(160),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              SingleLineText(url, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
              Container(
                padding: edgeInsetsL8R8.add(edgeInsetsL4R4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(parseResultTitle, style: theme.textTheme.labelSmall),
              ),
              Text(parseResultDetail, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        sizedBoxW12H12,
        ListTile(
          leading: const Icon(Symbols.open_in_phone),
          title: Text(tr.open),
          onTap: () async {
            await context.dispatchAsUrl(url);
            if (context.mounted) {
              context.pop();
            }
          },
        ),
        ListTile(
          leading: const Icon(Symbols.open_in_browser),
          title: Text(tr.openInBrowser),
          onTap: () async {
            await context.dispatchAsUrl(url, external: true);
            if (context.mounted) {
              context.pop();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.copy_outlined),
          title: Text(tr.copyUrl),
          onTap: () async {
            await context.dispatchAsUrl(url);
            if (!context.mounted) {
              return;
            }
            context.pop();
            await copyToClipboard(context, url);
          },
        ),
      ];
    },
  );
}

/// The top bar of custom bottom sheet
///
/// Only use this widget in [showCustomBottomSheet]'s `topBar`.
class BottomSheetTopBar extends StatelessWidget {
  /// Constructor.
  const BottomSheetTopBar({required this.height, required this.child, this.alignment, super.key});

  /// Preferred height of top bar content.
  final double height;

  /// Content child widget.
  final Widget child;

  /// Horizontal alignment.
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height, maxWidth: MediaQuery.widthOf(context)),
        child: alignment != null ? Align(alignment: alignment!, child: child) : child,
      ),
    );
  }
}
