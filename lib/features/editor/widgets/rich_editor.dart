import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return BBCodeEditor(
      controller: controller,
      focusNode: focusNode,
      autoFocus: autoFocus,
      initialText: initialText,
      scrollController: scrollController,
      emojiProvider: (context, code) {
        // code is supposed in
        // {:${group_id}_${emoji_id}:}
        // format.
        return FutureBuilder(
          future:
              getIt.get<ImageCacheProvider>().getEmojiCacheFromRawCode(code),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return sizedCircularProgressIndicator;
            }
            return Image.memory(snapshot.data!);
          },
        );
      },
      // TODO: Implement imageBuilder in editor package.
      // imageBuilder: (String url) => CachedImageProvider(url, context),
      urlLauncher: (url) async => context.dispatchAsUrl(url),
      userMentionHandler: (username) => context.dispatchAsUrl(
        '$usernameProfilePage$username',
      ),
    );
  }
}
