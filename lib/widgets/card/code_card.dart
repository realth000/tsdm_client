import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
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
    return Card(
      elevation: elevation,
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
                  onPressed: () async => copyToClipboard(context, code),
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
