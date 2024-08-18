import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Show a [MentionUserDialog].
Future<void> showMentionUserDialog(
  BuildContext context,
  BBCodeEditorController controller,
) async =>
    showDialog(
      context: context,
      builder: (context) => MentionUserDialog(controller),
    );

/// Show a dialog to require and insert mention user span.
class MentionUserDialog extends StatefulWidget {
  /// Constructor.
  const MentionUserDialog(this.bbCodeController, {super.key});

  /// The bbcode editor controller used after dialog closed.
  final BBCodeEditorController bbCodeController;

  @override
  State<MentionUserDialog> createState() => _MentionUserDialogState();
}

class _MentionUserDialogState extends State<MentionUserDialog> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tr = context.t.bbcodeEditor.mentionUser;
    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      title: Text(tr.title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: usernameController,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                labelText: tr.username,
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
                    // await widget.bbCodeController.insertMentionUSer(
                    //   usernameController.text,
                    // );
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
