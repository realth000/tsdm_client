import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/features/editor/widgets/emoji_bottom_sheet.dart';

/// Representing all features types.
enum EditorFeatures {
  /// All text style.
  textStyle,

  /// Font size in text style.
  fontSize,

  /// Text color in text style.
  foregroundColor,

  /// Background color in text style.
  backgroundColor,

  /// Bold in text style.
  bold,

  /// Italic in text style.
  italic,

  /// Underline in text style.
  underline,

  /// Strikethrough in text style.
  strikethrough,

  /// Emoji.
  emoji,

  /// Url link.
  link,

  /// Url for online pictures.
  picture,

  /// Mention user aka "@".
  userMention,
}

/// Toolbar for the bbcode editor.
class EditorToolbar extends StatefulWidget {
  /// Constructor.
  const EditorToolbar({
    required this.bbcodeController,
    this.disabledFeatures = const [],
    super.key,
  });

  /// Controller of the editor.
  final BBCodeEditorController bbcodeController;

  /// All editor features to disable.
  ///
  /// All [EditorFeatures] exist in this list will be disabled and the
  /// corresponding widget will NOT be invisible.
  final List<EditorFeatures> disabledFeatures;

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

  /// All disabled features, construct from widget.
  late final List<EditorFeatures> _disabledFeatures;

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
  //             icon: const Icon(Icons.format_size_outlined),
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
  //           icon: const Icon(Icons.format_color_text_outlined),
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
  //           icon: const Icon(Icons.format_color_fill_outlined),
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
  //         icon: const Icon(Icons.format_bold_outlined),
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
  //         icon: const Icon(Icons.format_italic_outlined),
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
  //         icon: const Icon(Icons.format_underline_outlined),
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
  //         icon: const Icon(Icons.format_strikethrough_outlined),
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
  //         icon: const Icon(Icons.text_format_outlined),
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
  //         icon: const Icon(Icons.emoji_emotions_outlined),
  //         onPressed: () async {
  //           await showEmojiBottomSheet(context, widget.bbcodeController);
  //         },
  //       ),
  //     // Url link
  //     if (!_disabledFeatures.contains(EditorFeatures.link))
  //       IconButton(
  //         icon: const Icon(Icons.link_outlined),
  //         onPressed: () async =>
  //             showUrlDialog(context, widget.bbcodeController),
  //       ),
  //     // Url of online pictures.
  //     if (!_disabledFeatures.contains(EditorFeatures.picture))
  //       IconButton(
  //         icon: Icon(
  //           Icons.image_outlined,
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
  //         icon: const Icon(Icons.alternate_email_outlined),
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

  @override
  void initState() {
    super.initState();
    // widget.bbcodeController.addListener(updateBBCodeStatus);
    _disabledFeatures = widget.disabledFeatures;
  }

  @override
  void dispose() {
    // widget.bbcodeController.removeListener(updateBBCodeStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BBCodeEditorToolbar(
          controller: widget.bbcodeController,
          config: const BBCodeEditorToolbarConfiguration(),
          emojiPicker: (context) async => showEmojiBottomSheet(context),
        ),
        // FIXME: Restore all functionality.
        // AnimatedVisibility(
        //   visible:
        //       widget.bbcodeController.editorVisible && showTextAttributeButtons,
        //   child: _buildEditorTextControlRow(context),
        // ),
        // AnimatedVisibility(
        //   visible: widget.bbcodeController.editorVisible,
        //   child: _buildEditorControlRow(context),
        // ),
      ],
    );
  }
}
