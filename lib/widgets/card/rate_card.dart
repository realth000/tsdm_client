import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/thread/v1/bloc/thread_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

/// Widget to show the rate statistics for a post.
class RateCard extends StatelessWidget {
  /// Constructor.
  const RateCard(this.rate, this.pid, {super.key});

  /// Id of post the rate info lives on.
  final String pid;

  /// Rate model.
  final Rate rate;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final threadInfo = context.readOrNull<ThreadBloc>()?.state;
    final tid = threadInfo?.tid;
    final threadTitle = threadInfo?.title;
    final pid = this.pid;

    // Column width.
    // The first column is user info and last column is always "rate reason",
    // these two columns should have a flex column width.
    // The rest columns are always short enough to constrains in fixed width.
    final columnWidths = <int, TableColumnWidth>{
      for (final i in List.generate(rate.attrList.length - 1, (v) => v)) i + 1: const IntrinsicColumnWidth(),
    };
    columnWidths[0] = const FixedColumnWidth(150);
    columnWidths[rate.attrList.length + 1] = const FixedColumnWidth(200);

    // ,
    final tableHeaders = [context.t.rateCard.user, ...rate.attrList]
        .map<Widget>(
          (e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: secondaryColor)),
              sizedBoxW8H8,
            ],
          ),
        )
        .toList();

    final bottom = Text(
      context.t.rateCard.total(total: rate.rateStatus ?? '-'),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryColor),
    );

    final tableContent = rate.records
        .mapIndexed(
          (idx, e) => TableRow(
            decoration: BoxDecoration(color: idx.isOdd ? Theme.of(context).colorScheme.surfaceContainerHigh : null),
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
                  sizedBoxW8H8,
                  Expanded(
                    child: GestureDetector(
                      onTap: () async => context.dispatchAsUrl(e.user.url),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(e.user.name, textAlign: TextAlign.left),
                      ),
                    ),
                  ),
                ],
              ),
              ...e.attrValueList.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [Text(e), sizedBoxW8H8])),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
                ),
                TextButton(
                  onPressed: tid == null
                      ? null
                      : () async => context.pushNamed(
                          ScreenPaths.rateLog,
                          pathParameters: {'tid': tid, 'pid': pid},
                          queryParameters: {'threadTitle': threadTitle, 'total': rate.rateStatus},
                        ),
                  child: Text(context.t.rateCard.viewAll),
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
