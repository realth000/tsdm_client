import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
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

  @override
  Widget build(BuildContext context) {
    return BBCodeEditor(
      controller: controller,
      focusNode: focusNode,
      autoFocus: autoFocus,
      initialText: initialText,
      scrollController: scrollController,
      imageProvider: (context, url) => CachedImage(url),
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
      // TODO: Implement imageBuilder in editor package.
      // imageBuilder: (String url) => CachedImageProvider(url, context),
      urlLauncher: (url) async => context.dispatchAsUrl(url),
      userMentionHandler: (username) => context.dispatchAsUrl(
        '$usernameProfilePage$username',
      ),
      imageConstraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
    );
  }
}
