import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/widgets/section_switch_list_tile.dart';
import 'package:tsdm_client/widgets/tips.dart';

/// Show a picture dialog to add picture into editor.
Future<BBCodeImageInfo?> showImagePicker(BuildContext context, {String? url, int? width, int? height}) async =>
    showDialog<BBCodeImageInfo>(
      context: context,
      builder: (context) => RootPage(DialogPaths.imagePicker, _ImageDialog(url: url, width: width, height: height)),
    );

/// Show a dialog to insert picture and description.
class _ImageDialog extends StatefulWidget {
  const _ImageDialog({required this.url, required this.width, required this.height});

  final String? url;
  final int? width;
  final int? height;

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> with LoggerMixin, SingleTickerProviderStateMixin {
  final urlForm = GlobalKey<FormState>();
  final urlFieldKey = GlobalKey<FormFieldState<String>>();
  final smmsFieldKey = GlobalKey<FormFieldState<String>>();

  late TextEditingController urlController;
  late TextEditingController widthController;
  late TextEditingController heightController;
  late TextEditingController pathController;

  late TabController tabController;
  late Uint8List imageData;

  /// Flag indicating automatically fill image size.
  ///
  /// This is achieved by downloading the image cache and calculate its size.
  /// Only fill the image size in bbcode (if size enabled):
  ///
  /// ```console
  /// [img=$WIDTH,$HEIGHT}$IMAGE_URL[/img]
  /// ```
  ///
  /// Usually this width/height equals to original image size, which means size
  /// overflow is not considered here, because the server only render images in
  /// acceptable width:
  ///
  /// Now the max image width is 550.
  ///
  /// * If image width is no larger than max image width, both original width
  ///   and height are used.
  /// * If image width is larger than the max image width, set rendered width to
  ///   max image width and adjust height to MAX_IMAGE_WIDTH / ORIGINAL_WIDTH *
  ///   ORIGINAL HEIGHT, this keeps the same image width/height ratio and limit
  ///   image width to max image width.
  ///
  /// So fill with original image size is fine.
  bool autoFillSize = true;

  /// Automatically determine the width.
  ///
  /// Fill a zero value in bbcode.
  ///
  /// This can not be true when [autoScaleHeight] is true.
  bool autoScaleWidth = false;

  /// Automatically determine the height.
  ///
  /// Fill a zero value in bbcode.
  ///
  /// This can not be true when [autoScaleWidth] is true.
  bool autoScaleHeight = false;

  /// Flag indicating in auto-fill-size progress.
  bool fillingSize = false;

  /// Current tab index.
  int index = 0;

  Future<void> _fillImageSize(String url) async {
    try {
      final imageData = (await getIt.get<ImageCacheProvider>().getOrMakeCache(
        ImageCacheGeneralRequest(url),
        force: true,
      )).getOrElse(() => Uint8List(0));
      if (imageData.isEmpty) {
        return;
      }
      final uiImage = await decodeImageFromList(imageData);
      if (!mounted) {
        return;
      }
      setState(() {
        widthController.text = '${uiImage.width}';
        heightController.text = '${uiImage.height}';
      });
      // Intend to catch all exceptions only be aware of a manual required
      // state.
      // ignore: avoid_catches_without_on_clauses
    } catch (e, _) {
      // Directly cache Future.error.
      error('failed to fill image size: invalid image: $e');
      return;
    }
  }

  Widget _buildUrlField(BuildContext context) {
    final tr = context.t.bbcodeEditor.image;
    return TextFormField(
      key: urlFieldKey,
      controller: urlController,
      autofocus: true,
      decoration: InputDecoration(prefixIcon: const Icon(Icons.image_outlined), labelText: tr.link),
      validator: (v) => v!.trim().isNotEmpty ? null : tr.errorEmpty,
      onChanged: (v) async {
        // Try fill image size from image file.
        if (!autoFillSize) {
          return;
        }
        final cs = urlFieldKey.currentState;
        if (cs == null || !cs.validate()) {
          return;
        }
        // Try get image size when image url changes.
        setState(() {
          fillingSize = true;
        });
        await _fillImageSize(v);
        if (!mounted) {
          return;
        }
        setState(() {
          fillingSize = false;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(text: widget.url);
    widthController = TextEditingController(text: '${widget.width ?? ""}');
    heightController = TextEditingController(text: '${widget.height ?? ""}');
    pathController = TextEditingController();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    urlController.dispose();
    widthController.dispose();
    heightController.dispose();
    pathController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.bbcodeEditor.image;

    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.title),
          // TabBar(
          //   controller: tabController,
          //   tabs: [
          //     Tab(text: 'url'),
          //     Tab(text: 'smms'),
          //   ],
          //   onTap: (v) {
          //     if (v == index) {
          //       return;
          //     }
          //     setState(() {
          //       index = v;
          //     });
          //   },
          // ),
        ],
      ),
      content: Form(
        key: urlForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IndexedStack(
              index: index,
              children: [
                _buildUrlField(context),
                // _buildSmmsField(context),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widthController,
                    enabled: !autoScaleWidth,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]+'))],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.horizontal_distribute_outlined),
                      labelText: tr.width,
                    ),
                    validator: (v) {
                      if (autoScaleWidth) {
                        return null;
                      }
                      if (v == null || v.trim().isEmpty) {
                        return tr.errorEmpty;
                      }
                      final vv = double.tryParse(v);
                      if (vv == null || vv <= 0) {
                        return tr.errorInvalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                Checkbox(
                  value: autoScaleWidth,
                  onChanged: (v) {
                    if (v == null) {
                      return;
                    }

                    setState(() {
                      if (autoScaleHeight) {
                        autoScaleHeight = false;
                      }
                      autoScaleWidth = v;
                    });
                  },
                ),
                Text(tr.auto),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: heightController,
                    enabled: !autoScaleHeight,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]+'))],
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.add), labelText: tr.height),
                    validator: (v) {
                      if (autoScaleHeight) {
                        return null;
                      }
                      if (v == null || v.trim().isEmpty) {
                        return tr.errorEmpty;
                      }
                      final vv = double.tryParse(v);
                      if (vv == null || vv <= 0) {
                        return tr.errorInvalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                Checkbox(
                  value: autoScaleHeight,
                  onChanged: (v) {
                    if (v == null) {
                      return;
                    }

                    setState(() {
                      if (autoScaleWidth) {
                        autoScaleWidth = false;
                      }
                      autoScaleHeight = v;
                    });
                  },
                ),
                Text(tr.auto),
              ],
            ),
            Tips(tr.autoSingleDirectionSize),
            SectionSwitchListTile(
              title: Text(tr.autoFillSize),
              subtitle: Text(tr.autoFillSizeDetail),
              value: autoFillSize,
              onChanged: (v) {
                setState(() {
                  autoFillSize = v;
                });
              },
            ),
          ].insertBetween(sizedBoxW12H12),
        ),
      ),
      actions: [
        if (fillingSize) sizedCircularProgressIndicator,
        TextButton(child: Text(context.t.general.cancel), onPressed: () => context.pop()),
        TextButton(
          child: Text(context.t.general.ok),
          onPressed: () async {
            if (urlForm.currentState == null || !(urlForm.currentState!).validate()) {
              return;
            }

            final width = int.tryParse(widthController.text);
            final height = int.tryParse(heightController.text);

            context.pop(
              BBCodeImageInfo(
                urlController.text,
                width: autoScaleWidth ? 0 : width,
                height: autoScaleHeight ? 0 : height,
              ),
            );
          },
        ),
      ],
    );
  }
}
