import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/copy_content_dialog.dart';

/// Show a dialog to copy thread info.
Future<void> showCopyThreadInfoDialog({
  required BuildContext context,
  required String? tid,
  required String? title,
}) async {
  final tr = context.t.threadPage.threadInfo;
  await showCopyContentDialog(
    context: context,
    title: tr.title,
    contents: [
      CopyableContent(name: tr.threadTitle, data: title ?? ''),
      if (tid != null) ...[
        CopyableContent(name: tr.threadID, data: tid),
        CopyableContent(name: tr.threadUrl, data: 'forum.php?mod=viewthread&tid=$tid'),
        CopyableContent(name: tr.threadUrlWithDomain, data: '$baseUrl/forum.php?mod=viewthread&tid=$tid'),
      ],
      if (tid != null && title != null) ...[
        CopyableContent(name: tr.threadUrlBBCode, data: '[url=forum.php?mod=viewthread&tid=$tid]$title[/url]'),
        CopyableContent(
          name: tr.threadUrlBBCodeWithDomain,
          data: '[url=$baseUrl/forum.php?mod=viewthread&tid=$tid]$title[/url]',
        ),
      ],
    ],
  );
}
