import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/clipboard.dart';

/// Card to display code block, from html node type <div class="blockcode">.
class CodeCard extends StatelessWidget {
  /// Constructor.
  const CodeCard({required this.code, this.elevation, super.key});

  /// Code text to show.
  final String code;

  /// Elevation of this card.
  ///
  /// Default is 1, equal to default card elevation.
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: elevation,
      child: Padding(
        padding: edgeInsetsL16T16R16B16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code_outlined, color: primaryColor),
                sizedBoxW8H8,
                Text(
                  context.t.codeCard.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
                ),
              ],
            ),
            sizedBoxW16H16,
            Text(code),
            sizedBoxW16H16,
            OutlinedButton.icon(
              icon: const Icon(Icons.copy_outlined),
              label: Text(context.t.codeCard.copy),
              onPressed: () async => copyToClipboard(context, code),
            ),
          ],
        ),
      ),
    );
  }
}
