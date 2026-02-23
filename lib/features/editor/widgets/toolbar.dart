import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_bbcode_parser/dart_bbcode_parser.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/features/editor/widgets/color_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/emoji_bottom_sheet.dart';
import 'package:tsdm_client/features/editor/widgets/image_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/url_dialog.dart';
import 'package:tsdm_client/features/editor/widgets/username_picker_dialog.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/tips_card.dart';

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
class EditorToolbar extends StatelessWidget with LoggerMixin {
  /// Constructor.
  const EditorToolbar({
    required this.bbcodeController,
    this.disabledFeatures = const {},
    this.afterButtonPressed,
    this.editorFocusNode,
    this.applyDocumentMetadata,
    this.collectDocumentMetadata,
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

  /// Optional callback function, collect document metadata info from UI.
  ///
  /// Use this function to send quill delta json document metadata from outside
  /// toolbar.
  final EditorDocumentMetadata Function()? collectDocumentMetadata;

  /// Optional callback function, apply document metadata on UI.
  ///
  /// Use this function to update UI with values in metadata.
  final void Function(EditorDocumentMetadata metadata)? applyDocumentMetadata;

  bool _hasFeature(EditorFeatures feature) => !disabledFeatures.contains(feature);

  /// The callback function when portation button is clicked.
  ///
  /// Show a bottom sheet provides (copy/paste + import/export) -> (bbcode/quill delta)
  ///
  /// To support versioned quill delta document files, provides optional parameters:
  ///
  /// * [collectMetadata] callback function that provides document metadata to
  ///   save in the quill delta document. Caller may use this parameter where
  ///   UI have document metadata.
  /// * [applyMetadata] callback function to apply document metadata on UI. Caller
  ///   may use this parameter where updating metadata in UI is needed.
  ///
  /// No matter [collectMetadata] and [applyMetadata] are provided or not, the exported
  /// quill delta document will always in the latest format, not orignial quill delta json.
  Future<void> _onPortationButtonClicked(
    BuildContext context,
    BBCodeEditorController controller, {
    EditorDocumentMetadata Function()? collectMetadata,
    void Function(EditorDocumentMetadata)? applyMetadata,
  }) async {
    final tr = context.t.postEditPage.portation;

    final topBar = BottomSheetTopBar(
      height: 110,
      alignment: .center,
      child: Padding(
        padding: edgeInsetsL12R12,
        child: Align(
          child: Column(
            spacing: 10,
            children: [
              TipsCard(
                iconData: Icons.warning_outlined,
                tips: '${tr.tip}  ',
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              TipsCard(
                tips: '${tr.typesTip}  ',
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );

    await showCustomBottomSheet<void>(
      title: tr.title,
      topBar: topBar,
      context: context,
      childrenBuilder: (_) => [
        ListTile(
          title: Text(tr.copyBBCode),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: controller.toBBCode()));
            if (!context.mounted) {
              return;
            }
            showSnackBar(context: context, message: context.t.general.copiedToClipboard);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(tr.pasteBBCode),
          onTap: () async {
            final bbcode = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
            if (bbcode == null) {
              return;
            }
            try {
              final delta = parseBBCodeTextToDelta(bbcode.replaceAll('\r', ''));
              controller.setDocumentFromDelta(delta);
            } on Exception catch (e, st) {
              error('failed to paste bbcode: exception thrown');
              handleRaw(e, st);
              return;
            }

            if (!context.mounted) {
              return;
            }
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(tr.exportBBCode),
          onTap: () async {
            await _exportFile(context, 'bbcode_', 'txt', controller.toBBCode());
            if (!context.mounted) {
              return;
            }
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(tr.importBBCode),
          onTap: () async {
            final data = await _importFile(context, ['txt']);
            if (data == null) {
              return;
            }
            if (!context.mounted) {
              return;
            }
            try {
              final delta = parseBBCodeTextToDelta(data.replaceAll('\r', ''));
              controller.setDocumentFromDelta(delta);
            } on Exception catch (e, st) {
              error('failed to import bbcode: exception thrown');
              handleRaw(e, st);
              return;
            }
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(tr.copyQuilllDelta),
          onTap: () async {
            final data = EditorDocument.build(collectMetadata?.call(), controller.toQuillDeltaJson());
            await Clipboard.setData(ClipboardData(text: data.toJson()));
            if (!context.mounted) {
              return;
            }
            showSnackBar(context: context, message: context.t.general.copiedToClipboard);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(tr.pasteQuillDelta),
          onTap: () async {
            final data = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
            if (data == null) {
              return;
            }
            try {
              final d = jsonDecode(data.replaceAll('\r', ''));
              if (d is List<Map<String, dynamic>>) {
                // Not versioned.
                final delta = Delta.fromJson(d);
                controller.setDocumentFromDelta(delta);
              } else if (d is Map<String, dynamic>) {
                // Versioned.
                final doc = EditorDocumentMapper.fromMap(d);
                applyMetadata?.call(doc.metadata);
                final delta = Delta.fromJson(doc.operations);
                controller.setDocumentFromDelta(delta);
              } else {
                throw FormatException('invalid quill delta document type ${d.runtimeType}');
              }
            } on Exception catch (e, st) {
              error('failed to paste quill delta: exception thrown');
              handleRaw(e, st);
              return;
            }

            if (!context.mounted) {
              return;
            }
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(tr.exportQuillDelta),
          onTap: () async {
            final data = EditorDocument.build(collectMetadata?.call(), controller.toQuillDeltaJson());
            await _exportFile(context, 'quilldata_', 'json', data.toJson());
            if (!context.mounted) {
              return;
            }
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(tr.importQuillDelta),
          onTap: () async {
            final data = await _importFile(context, ['json']);
            if (data == null) {
              return;
            }
            if (!context.mounted) {
              return;
            }

            try {
              final d = jsonDecode(data.replaceAll('\r', ''));
              if (d is List<dynamic>) {
                // Not versioned.
                final delta = Delta.fromJson(d);
                controller.setDocumentFromDelta(delta);
              } else if (d is Map<String, dynamic>) {
                // Versioned.
                final doc = EditorDocumentMapper.fromMap(d);
                applyMetadata?.call(doc.metadata);
                final delta = Delta.fromJson(doc.operations);
                controller.setDocumentFromDelta(delta);
              } else {
                throw FormatException('invalid quill delta document type ${d.runtimeType}');
              }
            } on Exception catch (e, st) {
              error('failed to import quill delta: exception thrown');
              handleRaw(e, st);
              return;
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

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
      onPortationButtonClicked: (_, controller) async => _onPortationButtonClicked(
        context,
        controller,
        collectMetadata: collectDocumentMetadata,
        applyMetadata: applyDocumentMetadata,
      ),
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

Future<String?> _importFile(BuildContext context, List<String> exts) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: exts);
  if (result == null) {
    return null;
  }
  return File(result.files.single.path!).readAsString();
}

Future<void> _exportFile(BuildContext context, String prefix, String ext, String data) async {
  final result = await FilePicker.platform.saveFile(
    fileName: '$prefix${DateTime.now().yyyyMMDDHHMMSSPlain()}.$ext',
    bytes: Uint8List.fromList(utf8.encode(data)),
  );
  if (result == null) {
    return;
  }
  await File(result).writeAsString(data);
}
