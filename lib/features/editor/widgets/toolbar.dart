import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/features/editor/widgets/color_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/emoji_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/image_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/url_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/username_picker_dialog.dart';

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
}

/// Toolbar for the bbcode editor.
class EditorToolbar extends StatefulWidget {
  /// Constructor.
  const EditorToolbar({
    required this.bbcodeController,
    this.disabledFeatures = const {},
    super.key,
  });

  /// Controller of the editor.
  final BBCodeEditorController bbcodeController;

  /// All editor features to disable.
  ///
  /// All [EditorFeatures] exist in this list will be disabled and the
  /// corresponding widget will NOT be invisible.
  final Set<EditorFeatures> disabledFeatures;

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  /// Enable using testing bbcode editor.
  ///
  /// This flag is for testing only and SHOULD remove before next release.
  bool useExperimentalEditor = false;

  /// Show text attribute control button or not.
  bool showTextAttributeButtons = false;

  // BBCode text attribute status.
  Color? foregroundColor;
  Color? backgroundColor;
  int? fontSizeLevel;

  // Widget _buildEditorTextControlRow(BuildContext context) {
  //   final textItems = [
  //     // Font size.
  //     if (!_disabledFeatures.contains(EditorFeatures.fontSize))
  //       Badge(
  //         isLabelVisible: fontSizeLevel != null,
  //         backgroundColor: Theme.of(context).colorScheme.primaryContainer,
  //         label: Text(
  //           '$fontSizeLevel',
  //           style: TextStyle(color: Theme.of(context).primaryColor),
  //         ),
  //         child: GestureDetector(
  //           onDoubleTap: () async {
  //             // Double click to clear font size style.
  //             await widget.bbcodeController.clearFontSize();
  //             setState(() {});
  //           },
  //           child: IconButton(
  //             icon: const Icon(Icons.format_size),
  //             isSelected: fontSizeLevel != null,
  //             onPressed: widget.bbcodeController.collapsed
  //                 ? null
  //                 : () async {
  //                     await widget.bbcodeController.setNextFontSizeLevel();
  //                     setState(() {});
  //                   },
  //           ),
  //         ),
  //       ),
  //     // Foreground color.
  //     if (!_disabledFeatures.contains(EditorFeatures.foregroundColor))
  //       Badge(
  //         isLabelVisible: foregroundColor != null,
  //         backgroundColor: foregroundColor,
  //         child: IconButton(
  //           icon: const Icon(Icons.format_color_text),
  //           isSelected: foregroundColor != null,
  //           onPressed: () async => showForegroundColorBottomSheet(
  //             context,
  //             widget.bbcodeController,
  //           ),
  //         ),
  //       ),
  //     // Background color.
  //     if (!_disabledFeatures.contains(EditorFeatures.backgroundColor))
  //       Badge(
  //         isLabelVisible: backgroundColor != null,
  //         backgroundColor: backgroundColor,
  //         child: IconButton(
  //           icon: const Icon(Icons.format_color_fill),
  //           isSelected: backgroundColor != null,
  //           onPressed: () async => showBackgroundColorBottomSheet(
  //             context,
  //             widget.bbcodeController,
  //           ),
  //         ),
  //       ),
  //     // Bold
  //     if (!_disabledFeatures.contains(EditorFeatures.bold))
  //       IconButton(
  //         icon: const Icon(Icons.format_bold),
  //         isSelected: widget.bbcodeController.bold,
  //         onPressed: () {
  //           // ignore:unnecessary_lambdas
  //           setState(() {
  //             widget.bbcodeController.triggerBold();
  //           });
  //         },
  //       ),
  //     // Italic
  //     if (!_disabledFeatures.contains(EditorFeatures.italic))
  //       IconButton(
  //         icon: const Icon(Icons.format_italic),
  //         isSelected: widget.bbcodeController.italic,
  //         onPressed: () {
  //           // ignore:unnecessary_lambdas
  //           setState(() {
  //             widget.bbcodeController.triggerItalic();
  //           });
  //         },
  //       ),
  //     // Underline
  //     if (!_disabledFeatures.contains(EditorFeatures.underline))
  //       IconButton(
  //         icon: const Icon(Icons.format_underline),
  //         isSelected: widget.bbcodeController.underline,
  //         onPressed: () {
  //           // ignore:unnecessary_lambdas
  //           setState(() {
  //             widget.bbcodeController.triggerUnderline();
  //           });
  //         },
  //       ),
  //     // Strikethrough
  //     if (!_disabledFeatures.contains(EditorFeatures.strikethrough))
  //       IconButton(
  //         icon: const Icon(Icons.format_strikethrough),
  //         isSelected: widget.bbcodeController.strikethrough,
  //         onPressed: () {
  //           // ignore:unnecessary_lambdas
  //           setState(() {
  //             widget.bbcodeController.triggerStrikethrough();
  //           });
  //         },
  //       ),
  //   ];

  //   return ScrollConfiguration(
  //     behavior: AllDraggableScrollBehavior(),
  //     child: SingleChildScrollView(
  //       primary: false,
  //       scrollDirection: Axis.horizontal,
  //       child: Row(children: textItems),
  //     ),
  //   );
  // }

  // void updateBBCodeStatus() {
  //   // Only update text style attributes here.
  //   if (!showTextAttributeButtons) {
  //     return;
  //   }

  //   setState(() {
  //     foregroundColor = widget.bbcodeController.foregroundColor;
  //     backgroundColor = widget.bbcodeController.backgroundColor;
  //     fontSizeLevel = widget.bbcodeController.fontSizeLevel;
  //   });
  // }

  // Widget _buildEditorControlRow(BuildContext context) {
  //   final otherItems = [
  //     // Text style
  //     if (!_disabledFeatures.contains(EditorFeatures.textStyle))
  //       IconButton(
  //         icon: const Icon(Icons.text_format),
  //         isSelected: showTextAttributeButtons,
  //         onPressed: () {
  //           // ignore:unnecessary_lambdas
  //           setState(() {
  //             showTextAttributeButtons = !showTextAttributeButtons;
  //           });
  //         },
  //       ),
  //     // Emoji
  //     if (!_disabledFeatures.contains(EditorFeatures.emoji))
  //       IconButton(
  //         icon: const Icon(Icons.emoji_emotions),
  //         onPressed: () async {
  //           await showEmojiBottomSheet(context, widget.bbcodeController);
  //         },
  //       ),
  //     // Url link
  //     if (!_disabledFeatures.contains(EditorFeatures.link))
  //       IconButton(
  //         icon: const Icon(Icons.link),
  //         onPressed: () async =>
  //             showUrlDialog(context, widget.bbcodeController),
  //       ),
  //     // Url of online pictures.
  //     if (!_disabledFeatures.contains(EditorFeatures.picture))
  //       IconButton(
  //         icon: Icon(
  //           Icons.image,
  //           color: widget.bbcodeController.strikethrough
  //               ? Theme.of(context).primaryColor
  //               : null,
  //         ),
  //         onPressed: () async =>
  //             showImageDialog(context, widget.bbcodeController),
  //       ),
  //     // User mention
  //     if (!_disabledFeatures.contains(EditorFeatures.userMention))
  //       IconButton(
  //         icon: const Icon(Icons.alternate_email),
  //         onPressed: () async => showMentionUserDialog(
  //           context,
  //           widget.bbcodeController,
  //         ),
  //       ),
  //   ];
  //   return ScrollConfiguration(
  //     behavior: AllDraggableScrollBehavior(),
  //     child: SingleChildScrollView(
  //       primary: false,
  //       scrollDirection: Axis.horizontal,
  //       child: Row(children: otherItems),
  //     ),
  //   );
  // }

  bool hasFeature(EditorFeatures feature) =>
      !widget.disabledFeatures.contains(feature);

  @override
  void dispose() {
    // widget.bbcodeController.removeListener(updateBBCodeStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BBCodeEditorToolbar(
      controller: widget.bbcodeController,
      config: const BBCodeEditorToolbarConfiguration(),
      emojiPicker: (context) async => showEmojiPicker(context),
      colorPicker: (context) async => showColorPicker(context),
      urlPicker: (context, url, description) async =>
          showUrlPicker(context, url: url, description: description),
      backgroundColorPicker: (context) async => showColorPicker(context),
      imagePicker: (context, url, width, height) =>
          showImagePicker(context, url: url, width: width, height: height),
      usernamePicker: showUsernamePickerDialog,
      // Features.
      showUndo: hasFeature(EditorFeatures.undo),
      showRedo: hasFeature(EditorFeatures.redo),
      showFontFamily: hasFeature(EditorFeatures.fontFamily),
      showFontSize: hasFeature(EditorFeatures.fontSize),
      showBoldButton: hasFeature(EditorFeatures.bold),
      showItalicButton: hasFeature(EditorFeatures.italic),
      showUnderlineButton: hasFeature(EditorFeatures.underline),
      showStrikethroughButton: hasFeature(EditorFeatures.strikethrough),
      showSuperscriptButton: hasFeature(EditorFeatures.superscript),
      showColorButton: hasFeature(EditorFeatures.color),
      showBackgroundColorButton: hasFeature(EditorFeatures.backgroundColor),
      showClearFormatButton: hasFeature(EditorFeatures.clearFormat),
      showImageButton: hasFeature(EditorFeatures.image),
      showEmojiButton: hasFeature(EditorFeatures.emoji),
      showLeftAlignButton: hasFeature(EditorFeatures.alignLeft),
      showCenterAlignButton: hasFeature(EditorFeatures.alignCenter),
      showRightAlignButton: hasFeature(EditorFeatures.alignRight),
      showOrderedListButton: hasFeature(EditorFeatures.orderedList),
      showBulletListButton: hasFeature(EditorFeatures.bulletList),
      showUrlButton: hasFeature(EditorFeatures.url),
      showCodeBlockButton: hasFeature(EditorFeatures.codeBlock),
      showQuoteBlockButton: hasFeature(EditorFeatures.quoteBlock),
      showClipboardCutButton: hasFeature(EditorFeatures.cut),
      showClipboardCopyButton: hasFeature(EditorFeatures.copy),
      showClipboardPasteButton: hasFeature(EditorFeatures.paste),
      showUserMentionButton: hasFeature(EditorFeatures.userMention),
    );
  }
}
