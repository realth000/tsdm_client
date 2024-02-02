import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Card to display code block, from html node type <div class="blockcode">.
class CodeCard extends StatelessWidget {
  /// Constructor.
  const CodeCard({required this.code, super.key});

  /// Code text to show.
  final String code;

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: code),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.t.aboutPage.copiedToClipboard,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.t.codeCard.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                sizedBoxW5H5,
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () async => _copyToClipboard(context),
                ),
              ],
            ),
            sizedBoxW5H5,
            Text(code),
          ],
        ),
      ),
    );
  }
}
