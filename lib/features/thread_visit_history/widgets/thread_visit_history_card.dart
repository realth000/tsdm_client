import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/themes/widget_themes.dart';

/// Card to show a record of thread visit history.
class ThreadVisitHistoryCard extends StatelessWidget {
  /// Constructor.
  const ThreadVisitHistoryCard(this.model, {super.key});

  /// History data to show.
  final ThreadVisitHistoryModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () async => context.pushNamed(
          ScreenPaths.threadV1,
          queryParameters: {'tid': '${model.threadId}'},
        ),
        child: Padding(
          padding: edgeInsetsL12T12R12B12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  model.threadTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              sizedBoxW12H12,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: smallIconSize),
                    sizedBoxW4H4,
                    Text(model.username),
                    sizedBoxW12H12,
                    const Icon(Icons.forum_outlined, size: smallIconSize),
                    sizedBoxW4H4,
                    Text(model.forumName),
                    sizedBoxW12H12,
                    const Icon(
                      Icons.access_time_outlined,
                      size: smallTextSize,
                    ),
                    sizedBoxW4H4,
                    Text(model.visitTime.yyyyMMDDHHMMSS()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
