import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/editor/widgets/color_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/emoji_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/image_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/url_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/username_picker_dialog.dart';
import 'package:tsdm_client/utils/platform.dart';

/// Representing all features types.
enum EditorFeatures {
  /// Bold in text style.
  bold,

  /// Italic in text style.
  italic,

  /// Underline in text style.
  underline,

  /// Strikethrough in text style.
  strikethrough,

  /// Font family in text style.
  fontFamily,

  /// Font size in text style.
  fontSize,

  /// Superscript in text style.
  superscript,

  /// Text color in text style.
  color,

  /// Background color in text style.
  backgroundColor,

  /// Clear text format button.
  clearFormat,

  /// Emoji.
  emoji,

  /// Url link.
  url,

  /// Url for online pictures.
  image,

  /// Mention user aka "@".
  userMention,

  /// Undo button.
  undo,

  /// Redo button.
  redo,

  /// Align left
  alignLeft,

  /// Align center
  alignCenter,

  /// Align right
  alignRight,

  /// ```console
  /// 1.
  /// 2.
  /// ```
  orderedList,

  /// ```console
  /// *.
  /// *.
  /// ```
  bulletList,

  /// Multiline code.
  codeBlock,

  /// Quote code.
  quoteBlock,

  /// Cut clipboard.
  cut,

  /// Copy clipboard.
  copy,

  /// Paste clipboard.
  paste,

  /// Free area.
  free,
}

/// Toolbar for the bbcode editor.
class EditorToolbar extends StatelessWidget {
  /// Constructor.
  const EditorToolbar({
    required this.bbcodeController,
    this.disabledFeatures = const {},
    this.afterButtonPressed,
    this.editorFocusNode,
    super.key,
  });

  /// Controller of the editor.
  final BBCodeEditorController bbcodeController;

  /// All editor features to disable.
  ///
  /// All [EditorFeatures] exist in this list will be disabled and the
  /// corresponding widget will NOT be invisible.
  final Set<EditorFeatures> disabledFeatures;

  /// Callback when button pressed.
  final VoidCallback? afterButtonPressed;

  /// The focus node shared with editor.
  ///
  /// Use This field to update editor focus state.
  final FocusNode? editorFocusNode;

  bool _hasFeature(EditorFeatures feature) => !disabledFeatures.contains(feature);

  @override
  Widget build(BuildContext context) {
    final toolbar = BBCodeEditorToolbar(
      afterButtonPressed: afterButtonPressed,
      focusNode: editorFocusNode,
      controller: bbcodeController,
      emojiPicker: (context) async => showEmojiPicker(context),
      colorPicker: (context, initialColor) async => showColorPicker(context, initialColor, PickerType.foreground),
      urlPicker: (context, url, description) async => showUrlPicker(context, url: url, description: description),
      backgroundColorPicker: (context, initialColor) async =>
          showColorPicker(context, initialColor, PickerType.background),
      imagePicker: (context, url, width, height) => showImagePicker(context, url: url, width: width, height: height),
      usernamePicker: showUsernamePickerDialog,
      // Features.
      showUndo: _hasFeature(EditorFeatures.undo),
      showRedo: _hasFeature(EditorFeatures.redo),
      showFontFamily: _hasFeature(EditorFeatures.fontFamily),
      showFontSize: _hasFeature(EditorFeatures.fontSize),
      showBoldButton: _hasFeature(EditorFeatures.bold),
      showItalicButton: _hasFeature(EditorFeatures.italic),
      showUnderlineButton: _hasFeature(EditorFeatures.underline),
      showStrikethroughButton: _hasFeature(EditorFeatures.strikethrough),
      showSuperscriptButton: _hasFeature(EditorFeatures.superscript),
      showColorButton: _hasFeature(EditorFeatures.color),
      showBackgroundColorButton: _hasFeature(EditorFeatures.backgroundColor),
      showClearFormatButton: _hasFeature(EditorFeatures.clearFormat),
      showImageButton: _hasFeature(EditorFeatures.image),
      showEmojiButton: _hasFeature(EditorFeatures.emoji),
      showLeftAlignButton: _hasFeature(EditorFeatures.alignLeft),
      showCenterAlignButton: _hasFeature(EditorFeatures.alignCenter),
      showRightAlignButton: _hasFeature(EditorFeatures.alignRight),
      showOrderedListButton: _hasFeature(EditorFeatures.orderedList),
      showBulletListButton: _hasFeature(EditorFeatures.bulletList),
      showUrlButton: _hasFeature(EditorFeatures.url),
      showCodeBlockButton: _hasFeature(EditorFeatures.codeBlock),
      showQuoteBlockButton: _hasFeature(EditorFeatures.quoteBlock),
      showClipboardCutButton: _hasFeature(EditorFeatures.cut),
      showClipboardCopyButton: _hasFeature(EditorFeatures.copy),
      showClipboardPasteButton: _hasFeature(EditorFeatures.paste),
      showUserMentionButton: _hasFeature(EditorFeatures.userMention),
      showFree: _hasFeature(EditorFeatures.free),
    );

    if (isMobile) {
      return Column(mainAxisSize: MainAxisSize.min, children: [toolbar, sizedBoxW24H24]);
    }

    return toolbar;
  }
}
