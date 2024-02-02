import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/rate.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

class RateCard extends StatelessWidget {
  const RateCard(this.rate, {super.key});

  final Rate rate;

  @override
  Widget build(BuildContext context) {
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
    final tableHeaders = [
      context.t.rateCard.title(userCount: '${rate.userCount}'),
      ...rate.attrList,
    ].map(Text.new).toList();

    final bottom =
        Text(context.t.rateCard.total(total: rate.rateStatus ?? '-'));

    final tableContent = rate.records
        .map((e) => TableRow(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: GestureDetector(
                          onTap: () async => context.dispatchAsUrl(e.user.url),
                          child: CircleAvatar(
                            backgroundImage: CachedImageProvider(
                              e.user.avatarUrl ?? noAvatarUrl,
                              context,
                            ),
                          ),
                        ),
                      ),
                    ),
                    sizedBoxW5H5,
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
            ),)
        .toList();

    return Card(
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            bottom,
          ],
        ),
      ),
    );
  }
}
