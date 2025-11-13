import 'package:tsdm_client/features/editor/widgets/toolbar.dart';

/// All disabled bbcode editor features in chat feature.
const Set<EditorFeatures> chatPagesDisabledFeatures = {
  EditorFeatures.italic,
  EditorFeatures.underline,
  EditorFeatures.strikethrough,
  EditorFeatures.fontFamily,
  EditorFeatures.fontSize,
  EditorFeatures.superscript,
  EditorFeatures.backgroundColor,
  EditorFeatures.clearFormat,
  EditorFeatures.userMention,
  EditorFeatures.alignLeft,
  EditorFeatures.alignCenter,
  EditorFeatures.alignRight,
  EditorFeatures.orderedList,
  EditorFeatures.bulletList,
  EditorFeatures.cut,
  EditorFeatures.copy,
  EditorFeatures.paste,
  EditorFeatures.free,
};
