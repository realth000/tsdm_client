import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/editor/widgets/color_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/emoji_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/image_dialog.dart';
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
    this.focusNode,
    this.autoFocus = false,
    this.initialText,
    super.key,
  });

  /// Editor controller.
  final BBCodeEditorController controller;

  /// Editor scroll controller.
  final ScrollController? scrollController;

  /// Editor focus.
  final FocusNode? focusNode;

  /// Automatically focus the editor.
  final bool autoFocus;

  /// Optional initial text.
  final String? initialText;

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
      focusNode: focusNode,
      autoFocus: autoFocus,
      initialText: initialText,
      scrollController: scrollController,
      imageProvider: (context, url, width, height) {
        final w = width?.toDouble();
        final h = height?.toDouble();
        double? maxHeight;
        if (w != null && h != null && w > _imageMaxWidth) {
          maxHeight = h * (_imageMaxWidth / w);
        }
        return CachedImage(
          url,
          width: w,
          height: maxHeight == null ? h : null,
          maxWidth: _imageMaxWidth,
          maxHeight: maxHeight,
        );
      },
      // Enable this constraints if needed.
      // imageConstraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
      imagePicker: (context, url, width, height) =>
          showImagePicker(context, url: url, width: width, height: height),
      emojiProvider: (context, code) {
        // code is supposed in
        // {:${group_id}_${emoji_id}:}
        // format.
        final data =
            getIt.get<ImageCacheProvider>().getEmojiCacheFromRawCodeSync(code);
        if (data == null) {
          return Text(code);
        }
        return Image.memory(
          data,
          width: _defaultEmojiWidth,
          height: _defaultEmojiHeight,
        );
      },
      usernamePicker: showUsernamePickerDialog,
      // TODO: Implement imageBuilder in editor package.
      // imageBuilder: (String url) => CachedImageProvider(url, context),
      urlLauncher: (url) async => context.dispatchAsUrl(url),
      userMentionHandler: (username) => context.dispatchAsUrl(
        '$usernameProfilePage$username',
      ),
      emojiPicker: (context) async => showEmojiPicker(context),
      colorPicker: (context) async => showColorPicker(context),
    );
  }
}
