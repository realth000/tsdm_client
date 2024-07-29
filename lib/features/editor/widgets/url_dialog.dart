import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Show a url dialog.
Future<void> showUrlDialog(
  BuildContext context,
  BBCodeEditorController controller,
) async =>
    showDialog(
      context: context,
      builder: (context) => UrlDialog(controller),
    );

/// Show a dialog to insert url and description.
class UrlDialog extends StatefulWidget {
  /// Constructor.
  const UrlDialog(this.bbCodeController, {super.key});

  /// The bbcode editor controller used after dialog closed.
  final BBCodeEditorController bbCodeController;

  @override
  State<UrlDialog> createState() => _UrlDialogState();
}

class _UrlDialogState extends State<UrlDialog> {
  final formKey = GlobalKey<FormState>();
  final descController = TextEditingController();
  final urlController = TextEditingController();

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
          children: <Widget>[
            TextFormField(
              controller: descController,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.description_outlined),
                labelText: tr.description,
              ),
              validator: (v) => v!.trim().isNotEmpty ? null : tr.errorEmpty,
            ),
            TextFormField(
              controller: urlController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.link_outlined),
                labelText: tr.link,
              ),
              validator: (v) => v!.trim().isNotEmpty ? null : tr.errorEmpty,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(context.t.general.cancel),
                  onPressed: () => context.pop(),
                ),
                TextButton(
                  child: Text(context.t.general.ok),
                  onPressed: () async {
                    if (formKey.currentState == null ||
                        !(formKey.currentState!).validate()) {
                      return;
                    }
                    // TODO: Implement
                    // await widget.bbCodeController.insertUrl(
                    //   descController.text,
                    //   urlController.text,
                    // );
                    if (!context.mounted) {
                      return;
                    }
                    context.pop();
                  },
                ),
              ],
            ),
          ].insertBetween(sizedBoxW10H10),
        ),
      ),
    );
  }
}
