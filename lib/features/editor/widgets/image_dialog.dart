import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Show a picture dialog to add picture into editor.
Future<void> showImageDialog(
  BuildContext context,
  BBCodeEditorController controller,
) async =>
    showDialog<void>(
      context: context,
      builder: (context) => _ImageDialog(controller),
    );

/// Show a dialog to insert picture and description.
class _ImageDialog extends StatefulWidget {
  const _ImageDialog(this.bbCodeEditorController);

  final BBCodeEditorController bbCodeEditorController;

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  final formKey = GlobalKey<FormState>();
  final imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tr = context.t.bbcodeEditor.image;
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      title: Text(tr.title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: imageUrlController,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.image_outlined),
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
                    final String url;
                    if (imageUrlController.text.startsWith('http://') ||
                        imageUrlController.text.startsWith('https://')) {
                      url = imageUrlController.text;
                    } else {
                      url = 'https://${imageUrlController.text}';
                    }
                    await widget.bbCodeEditorController
                        .insertImage(url, 100, 100);
                    if (!context.mounted) {
                      return;
                    }
                    context.pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
