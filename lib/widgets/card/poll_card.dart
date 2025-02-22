import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Card indicating post info.
class PollCard extends StatelessWidget {
  /// Constructor.
  const PollCard(this.pid, {super.key});

  /// The post id to redirect to as we do not support polls.
  final String pid;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.pollCard;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final primaryStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor);

    return Card(
      child: Padding(
        padding: edgeInsetsL16T16R16B16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart_outlined, color: primaryColor),
                sizedBoxW8H8,
                Text(tr.title, style: primaryStyle),
              ],
            ),
            sizedBoxW12H12,
            Text(tr.detail),
            sizedBoxW12H12,
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_browser_outlined),
              label: Text(tr.openInBrowser),
              onPressed: () async => launchUrlString('$baseUrl/forum.php?mod=redirect&goto=findpost&pid=$pid'),
            ),
          ],
        ),
      ),
    );
  }
}
