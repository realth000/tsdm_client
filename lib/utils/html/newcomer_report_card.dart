import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Table info in newcomer report table.
///
/// Each info occupies a row in table.
class NewcomerReportInfo {
  /// Constructor.
  NewcomerReportInfo({
    required this.title,
    required this.data,
  });

  /// Info title.
  final String title;

  /// Info data, may be empty string.
  final String data;
}

/// Card for newcomer report table in thread.
///
/// Only used in newcomer subreddit.
class NewcomerReportCard extends StatelessWidget {
  /// Constructor.
  const NewcomerReportCard(this.data, {super.key});

  /// Data in table.
  final List<NewcomerReportInfo> data;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: edgeInsetsL12T12R12B12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.article_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                sizedBoxW4H4,
                Text(
                  context.t.html.newcomerReportCard.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            sizedBoxW8H8,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(100),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: data
                    .mapIndexed(
                      (idx, e) => TableRow(
                        decoration: BoxDecoration(
                          color: idx.isOdd
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh
                              : null,
                        ),
                        children: [
                          TableCell(
                            child: Text(
                              e.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              e.data,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
