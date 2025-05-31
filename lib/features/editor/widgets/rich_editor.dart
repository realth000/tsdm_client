import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/editor/widgets/color_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/emoji_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/image_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/url_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/username_picker_dialog.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';

/// Wrapped bbcode editor.
class RichEditor extends StatelessWidget {
  /// Constructor.
  const RichEditor({
    required this.controller,
    this.scrollController,
    this.editorFocusNode,
    this.autoFocus = false,
    super.key,
  });

  /// The readonly constructor.
  RichEditor.readonly({
    String? initialText,
    Delta? initialDelta,
    this.scrollController,
    this.editorFocusNode,
    this.autoFocus = false,
    super.key,
  }) : controller = buildBBCodeEditorController(readOnly: true, initialText: initialText, initialDelta: initialDelta);

  /// Editor controller.
  final BBCodeEditorController controller;

  /// Editor scroll controller.
  final ScrollController? scrollController;

  /// Editor focus.
  final FocusNode? editorFocusNode;

  /// Automatically focus the editor.
  final bool autoFocus;

  static const _defaultEmojiWidth = 50.0;
  static const _defaultEmojiHeight = 50.0;

  /// The maximum height of image.
  ///
  /// As noted somewhere else before:
  ///
  /// On the web side, images are rendered under a limit of maximum width,
  /// currently is 550.
  ///
  /// If the width of image:
  ///
  /// * larger than this limit, images are scalded down to the maximum width
  ///   while keeping the same width/height ratio.
  /// * smaller than this limit, images are rendered in the original width, no
  ///   matter the height of image.
  static const _imageMaxWidth = 550.0;

  @override
  Widget build(BuildContext context) {
    return BBCodeEditor(
      controller: controller,
      focusNode: editorFocusNode,
      autoFocus: autoFocus,
      scrollController: scrollController,
      imageProvider: (context, url, width, height) {
        // Requirements:
        //
        // 1. If width is not larger than max width, keep the original width and height.
        // 2. If width is larger than max width, set width to max width and scale height down to the same ratio.
        // 3. Width and height can not be 0 at the same time.

        final w = width?.toDouble();
        final h = height?.toDouble();
        double? maxHeight;
        if (w != null && h != null) {
          if (w == 0) {
            // Auto width, do not limit max height.
            maxHeight = h;
          } else if (w > _imageMaxWidth && h != 0) {
            // Width too large, it will be set to max allowed width, scale down the height.
            maxHeight = h * (_imageMaxWidth / w);
          } else if (h == 0) {
            // Auto height.
            maxHeight = double.infinity;
          } else {
            // Normal height.
            maxHeight = h;
          }
        }

        return CachedImage(
          url,
          width: (w == null || w <= 0) ? null : w,
          height: maxHeight == null ? maxHeight : null,
          maxWidth: _imageMaxWidth,
          maxHeight: maxHeight,
        );
      },
      // Enable this constraints if needed.
      // imageConstraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
      imagePicker: (context, url, width, height) => showImagePicker(context, url: url, width: width, height: height),
      emojiProvider: (context, code) {
        // code is supposed in
        // {:${group_id}_${emoji_id}:}
        // format.
        final data = getIt.get<ImageCacheProvider>().getEmojiCacheFromRawCodeSync(code);
        if (data == null) {
          return Text(code);
        }
        return Image.memory(data, width: _defaultEmojiWidth, height: _defaultEmojiHeight);
      },
      usernamePicker: showUsernamePickerDialog,
      // TODO: Implement imageBuilder in editor package.
      // imageBuilder: (String url) => CachedImageProvider(url, context),
      urlLauncher: (url) async => context.dispatchAsUrl(url),
      userMentionHandler: (username) => context.dispatchAsUrl('$usernameProfilePage$username'),
      emojiPicker: (context) async => showEmojiPicker(context),
      colorPicker: (context, initialColor) async => showColorPicker(context, initialColor, PickerType.foreground),
      backgroundColorPicker: (context, initialColor) async =>
          showColorPicker(context, initialColor, PickerType.background),
      urlPicker: (context, url, description) async => showUrlPicker(context, url: url, description: description),
    );
  }
}
