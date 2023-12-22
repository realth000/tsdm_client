import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// Card to display code block, from html node type <div class="blockcode">.
class CodeCard extends ConsumerWidget {
  const CodeCard({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _copyToClipboard() async {
      await Clipboard.setData(
        ClipboardData(text: code),
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          context.t.aboutPage.copiedToClipboard,
        ),
      ));
    }

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
                  onPressed: () async => _copyToClipboard(),
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
