import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/clipboard.dart';
import 'package:tsdm_client/widgets/annimate/animated_visibility.dart';

/// Link prefix, originally in quill_flutter.
const _linkPrefixes = [
  'mailto:', // email
  'tel:', // telephone
  'sms:', // SMS
  'callto:',
  'wtai:',
  'market:',
  'geopoint:',
  'ymsgr:',
  'msnim:',
  'gtalk:', // Google Talk
  'skype:',
  'sip:', // Lync
  'whatsapp:',
  'http',
  'https',
];

/// Show a url dialog.
///
/// * [url] is optional initial url.
/// * [description] is optional description text.
///
/// Optional parameters above are used when editing an already inserted url.
Future<PickUrlResult?> showUrlPicker(
  BuildContext context, {
  required String? url,
  required String? description,
}) async => showDialog<PickUrlResult>(
  context: context,
  builder: (context) => RootPage(DialogPaths.urlPicker, UrlDialog(initialUrl: url, initialDescription: description)),
);

/// Show a dialog to insert url and description.
class UrlDialog extends StatefulWidget {
  /// Constructor.
  const UrlDialog({required this.initialUrl, required this.initialDescription, super.key});

  /// Optional initial url to fill in dialog.
  final String? initialUrl;

  /// Optional initial description text to fill in dialog.
  final String? initialDescription;

  @override
  State<UrlDialog> createState() => _UrlDialogState();
}

class _UrlDialogState extends State<UrlDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController descController;
  late final TextEditingController urlController;

  /// Regex to capture url and description in bilibili share text content.
  final _bilibiliShareRe = RegExp(r'^【(?<desc>.+)】 (?<url>https://www\.bilibili\.com/video/\w+)');

  var _bilibiliTipExpanded = false;

  @override
  void initState() {
    super.initState();

    // Because initial description may be the selected text in editor, when initial url is empty and description is
    // valid url or recognized app route, consider `initialDescription` to be the url.
    if (widget.initialDescription != null &&
        widget.initialUrl == null &&
        (_linkPrefixes.any((e) => widget.initialDescription!.startsWith('$e://')) ||
            widget.initialDescription?.prependHost().parseUrlToRoute() != null)) {
      descController = TextEditingController();
      urlController = TextEditingController(text: widget.initialDescription);
    } else {
      descController = TextEditingController(text: widget.initialDescription);
      urlController = TextEditingController(text: widget.initialUrl);
    }
  }

  @override
  void dispose() {
    descController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.bbcodeEditor.url;
    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      title: Text(context.t.bbcodeEditor.url.title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: descController,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.description_outlined),
                labelText: tr.description,
              ),
            ),
            TextFormField(
              controller: urlController,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.link_outlined), labelText: tr.link),
              validator: (v) => v!.trim().isNotEmpty ? null : tr.errorEmpty,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      child: Text(tr.autoPaste.tip),
                      onPressed: () async {
                        final bilibiliText = await getPlainTextFromClipboard();
                        if (bilibiliText == null) {
                          return;
                        }

                        final reMatch = _bilibiliShareRe.firstMatch(bilibiliText);
                        if (reMatch == null) {
                          return;
                        }

                        final desc = reMatch.namedGroup('desc')!;
                        final url = reMatch.namedGroup('url')!;
                        setState(() {
                          descController.text = desc;
                          urlController.text = url;
                        });
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => setState(() => _bilibiliTipExpanded = !_bilibiliTipExpanded),
                    ),
                  ],
                ),
                AnimatedVisibility(
                  visible: _bilibiliTipExpanded,
                  duration: duration200,
                  child: Text(tr.autoPaste.detail, style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(child: Text(context.t.general.cancel), onPressed: () => context.pop()),
                TextButton(
                  child: Text(context.t.general.ok),
                  onPressed: () async {
                    if (formKey.currentState == null || !(formKey.currentState!).validate()) {
                      return;
                    }
                    if (!context.mounted) {
                      return;
                    }
                    context.pop(
                      PickUrlResult(
                        url: urlController.text,
                        description: switch (descController.text) {
                          '' => urlController.text,
                          final String v => v,
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ].insertBetween(sizedBoxW12H12),
        ),
      ),
    );
  }
}
