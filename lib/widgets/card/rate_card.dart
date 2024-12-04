import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

/// Widget to show the rate statistics for a post.
class RateCard extends StatelessWidget {
  /// Constructor.
  const RateCard(this.rate, {super.key});

  /// Rate model.
  final Rate rate;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Column width.
    // The first column is user info and last column is always "rate reason",
    // these two columns should have a flex column width.
    // The rest columns are always short enough to constrains in fixed width.
    final fixedColumnWidths = List.filled(rate.attrList.length - 1, 50);
    final columnWidths = <int, TableColumnWidth>{
      for (final (i, v) in fixedColumnWidths.indexed)
        i + 1: FixedColumnWidth(v.toDouble()),
    };
    columnWidths[0] = const FixedColumnWidth(150);
    columnWidths[rate.attrList.length + 1] = const FixedColumnWidth(200);

    // ,
    final tableHeaders = [
      context.t.rateCard.user,
      ...rate.attrList,
    ]
        .map<Widget>(
          (e) => Text(
            e,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: secondaryColor),
          ),
        )
        .toList();

    final bottom = Text(
      context.t.rateCard.total(total: rate.rateStatus ?? '-'),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: secondaryColor,
          ),
    );

    final tableContent = rate.records
        .mapIndexed(
          (idx, e) => TableRow(
            decoration: BoxDecoration(
              color: idx.isOdd
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : null,
            ),
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    child: Center(
                      child: GestureDetector(
                        onTap: () async => context.dispatchAsUrl(e.user.url),
                        // TODO: Add hero here.
                        child: CircleAvatar(
                          backgroundImage: CachedImageProvider(
                            e.user.avatarUrl ?? noAvatarUrl,
                            fallbackImageUrl: noAvatarUrl,
                            usage: ImageUsageInfoUserAvatar(e.user.name),
                          ),
                        ),
                      ),
                    ),
                  ),
                  sizedBoxW4H4,
                  Expanded(
                    child: GestureDetector(
                      onTap: () async => context.dispatchAsUrl(e.user.url),
                      child: Row(
                        children: [
                          Text(
                            e.user.name,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ...e.attrValueList.map(Text.new),
            ],
          ),
        )
        .toList();

    return Card(
      child: Padding(
        padding: edgeInsetsL16T16R16B16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rate_review_outlined, color: primaryColor),
                sizedBoxW8H8,
                Text(
                  context.t.rateCard.title(userCount: '${rate.userCount}'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: primaryColor),
                ),
              ],
            ),
            sizedBoxW12H12,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                columnWidths: columnWidths,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(children: tableHeaders),
                  ...tableContent,
                ],
              ),
            ),
            sizedBoxW12H12,
            bottom,
          ],
        ),
      ),
    );
  }
}
