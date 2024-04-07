import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/features/editor/widgets/color_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/emoji_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/image_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/mention_user_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/url_dialog.dart';
import 'package:tsdm_client/widgets/annimate/animated_visibility.dart';
import 'package:tsdm_client/widgets/scroll_behavior.dart';

/// Toolbar for the bbcode editor.
class EditorToolbar extends StatefulWidget {
  /// Constructor.
  const EditorToolbar({required this.bbcodeController, super.key});

  /// Controller of the editor.
  final BBCodeEditorController bbcodeController;

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

  Widget _buildEditorTextControlRow(BuildContext context) {
    final textItems = [
      // Font size.
      Badge(
        isLabelVisible: fontSizeLevel != null,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        label: Text(
          '$fontSizeLevel',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        child: GestureDetector(
          onDoubleTap: () async {
            // Double click to clear font size style.
            await widget.bbcodeController.clearFontSize();
            setState(() {});
          },
          child: IconButton(
            icon: const Icon(Icons.format_size_outlined),
            isSelected: fontSizeLevel != null,
            onPressed: widget.bbcodeController.collapsed
                ? null
                : () async {
                    await widget.bbcodeController.setNextFontSizeLevel();
                    setState(() {});
                  },
          ),
        ),
      ),
      // Foreground color.
      Badge(
        isLabelVisible: foregroundColor != null,
        backgroundColor: foregroundColor,
        child: IconButton(
          icon: const Icon(Icons.format_color_text_outlined),
          isSelected: foregroundColor != null,
          onPressed: () async => showForegroundColorBottomSheet(
            context,
            widget.bbcodeController,
          ),
        ),
      ),
      Badge(
        isLabelVisible: backgroundColor != null,
        backgroundColor: backgroundColor,
        child: IconButton(
          icon: const Icon(Icons.format_color_fill_outlined),
          isSelected: backgroundColor != null,
          onPressed: () async => showBackgroundColorBottomSheet(
            context,
            widget.bbcodeController,
          ),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.format_bold_outlined),
        isSelected: widget.bbcodeController.bold,
        onPressed: () {
          // ignore:unnecessary_lambdas
          setState(() {
            widget.bbcodeController.triggerBold();
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.format_italic_outlined),
        isSelected: widget.bbcodeController.italic,
        onPressed: () {
          // ignore:unnecessary_lambdas
          setState(() {
            widget.bbcodeController.triggerItalic();
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.format_underline_outlined),
        isSelected: widget.bbcodeController.underline,
        onPressed: () {
          // ignore:unnecessary_lambdas
          setState(() {
            widget.bbcodeController.triggerUnderline();
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.format_strikethrough_outlined),
        isSelected: widget.bbcodeController.strikethrough,
        onPressed: () {
          // ignore:unnecessary_lambdas
          setState(() {
            widget.bbcodeController.triggerStrikethrough();
          });
        },
      ),
    ];

    return ScrollConfiguration(
      behavior: AllDraggableScrollBehavior(),
      child: SingleChildScrollView(
        primary: false,
        scrollDirection: Axis.horizontal,
        child: Row(children: textItems),
      ),
    );
  }

  void updateBBCodeStatus() {
    // Only update text style attributes here.
    if (!showTextAttributeButtons) {
      return;
    }

    setState(() {
      foregroundColor = widget.bbcodeController.foregroundColor;
      backgroundColor = widget.bbcodeController.backgroundColor;
      fontSizeLevel = widget.bbcodeController.fontSizeLevel;
    });
  }

  Widget _buildEditorControlRow(BuildContext context) {
    final otherItems = [
      IconButton(
        icon: const Icon(Icons.text_format_outlined),
        isSelected: showTextAttributeButtons,
        onPressed: () {
          // ignore:unnecessary_lambdas
          setState(() {
            showTextAttributeButtons = !showTextAttributeButtons;
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.emoji_emotions_outlined),
        onPressed: () async {
          await showEmojiBottomSheet(context, widget.bbcodeController);
        },
      ),
      IconButton(
        icon: const Icon(Icons.link_outlined),
        onPressed: () async => showUrlDialog(context, widget.bbcodeController),
      ),
      IconButton(
        icon: Icon(
          Icons.image_outlined,
          color: widget.bbcodeController.strikethrough
              ? Theme.of(context).primaryColor
              : null,
        ),
        onPressed: () async =>
            showImageDialog(context, widget.bbcodeController),
      ),
      // IconButton(
      //   icon: Icon(
      //     Icons.expand_circle_down_outlined,
      //     color: widget.bbcodeController.strikethrough
      //         ? Theme.of(context).primaryColor
      //         : null,
      //   ),
      //   onPressed: () {
      //     // ignore:unnecessary_lambdas
      //     setState(() {
      //       widget.bbcodeController.triggerStrikethrough();
      //     });
      //   },
      // ),
      // IconButton(
      //   icon: Icon(
      //     Icons.lock_outline,
      //     color: widget.bbcodeController.strikethrough
      //         ? Theme.of(context).primaryColor
      //         : null,
      //   ),
      //   onPressed: () {
      //     // ignore:unnecessary_lambdas
      //     setState(() {
      //       widget.bbcodeController.triggerStrikethrough();
      //     });
      //   },
      // ),
      IconButton(
        icon: const Icon(Icons.alternate_email_outlined),
        onPressed: () async => showMentionUserDialog(
          context,
          widget.bbcodeController,
        ),
      ),
      // IconButton(
      //   icon: Icon(
      //     Icons.format_list_bulleted_outlined,
      //     color: widget.bbcodeController.strikethrough
      //         ? Theme.of(context).primaryColor
      //         : null,
      //   ),
      //   onPressed: () {
      //     // ignore:unnecessary_lambdas
      //     setState(() {
      //       widget.bbcodeController.triggerStrikethrough();
      //     });
      //   },
      // ),
      // IconButton(
      //   icon: Icon(
      //     Icons.format_list_numbered_outlined,
      //     color: widget.bbcodeController.strikethrough
      //         ? Theme.of(context).primaryColor
      //         : null,
      //   ),
      //   onPressed: () {
      //     // ignore:unnecessary_lambdas
      //     setState(() {
      //       widget.bbcodeController.triggerStrikethrough();
      //     });
      //   },
      // ),
      // IconButton(
      //   icon: Icon(
      //     Icons.table_rows_outlined,
      //     color: widget.bbcodeController.strikethrough
      //         ? Theme.of(context).primaryColor
      //         : null,
      //   ),
      //   onPressed: () {
      //     // ignore:unnecessary_lambdas
      //     setState(() {
      //       widget.bbcodeController.triggerStrikethrough();
      //     });
      //   },
      // ),
    ];
    return ScrollConfiguration(
      behavior: AllDraggableScrollBehavior(),
      child: SingleChildScrollView(
        primary: false,
        scrollDirection: Axis.horizontal,
        child: Row(children: otherItems),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.bbcodeController.addListener(updateBBCodeStatus);
  }

  @override
  void dispose() {
    widget.bbcodeController.removeListener(updateBBCodeStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedVisibility(
          visible:
              widget.bbcodeController.editorVisible && showTextAttributeButtons,
          child: _buildEditorTextControlRow(context),
        ),
        AnimatedVisibility(
          visible: widget.bbcodeController.editorVisible,
          child: _buildEditorControlRow(context),
        ),
      ],
    );
  }
}
