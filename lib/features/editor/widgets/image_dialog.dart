import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

const _maxAllowedWidth = 160;
const _maxAllowedHeight = 90;
// const _ratio = _maxAllowedWidth / _maxAllowedHeight;
const _defaultWidth = _maxAllowedWidth;
const _defaultHeight = _maxAllowedHeight;

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
  final widthController = TextEditingController(text: '$_defaultWidth');
  final heightController = TextEditingController(text: '$_defaultHeight');

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
            TextFormField(
              controller: widthController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[0-9]+'),
                ),
              ],
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.horizontal_distribute_outlined),
                labelText: tr.width,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return tr.errorEmpty;
                }
                final vv = double.tryParse(v);
                if (vv == null || vv <= 0) {
                  return tr.errorInvalidNumber;
                }
                return null;
              },
            ),
            TextFormField(
              controller: heightController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[0-9]+'),
                ),
              ],
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.vertical_distribute_outlined),
                labelText: tr.height,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return tr.errorEmpty;
                }
                final vv = double.tryParse(v);
                if (vv == null || vv <= 0) {
                  return tr.errorInvalidNumber;
                }
                return null;
              },
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
                    // if (formKey.currentState == null ||
                    //     !(formKey.currentState!).validate()) {
                    //   return;
                    // }
                    // final String url;
                    // if (imageUrlController.text.startsWith('http://') ||
                    //     imageUrlController.text.startsWith('https://')) {
                    //   url = imageUrlController.text;
                    // } else {
                    //   url = 'https://${imageUrlController.text}';
                    // }
                    // final width = int.parse(widthController.text);
                    // final height = int.parse(heightController.text);
                    // assert(height != 0, 'image height should not be zero');
                    // final actualRatio = width / height;

                    // final double displayWidth;
                    // final double displayHeight;
                    // if (actualRatio <= _ratio) {
                    //   // Image size is more in height.
                    //   displayWidth = width * height / _maxAllowedHeight;
                    //   displayHeight = _maxAllowedHeight.toDouble();
                    // } else {
                    //   // Image size is more in width.
                    //   displayWidth = _maxAllowedWidth.toDouble();
                    //   displayHeight = height * width / _maxAllowedWidth;
                    // }
                    // // TODO: Implement
                    // // await widget.bbCodeEditorController.insertImage(
                    // //   url: url,
                    // //   width: width,
                    // //   height: height,
                    // //   displayWith: displayWidth,
                    // //   displayHeight: displayHeight,
                    // // );
                    // if (!context.mounted) {
                    //   return;
                    // }
                    // context.pop();
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
