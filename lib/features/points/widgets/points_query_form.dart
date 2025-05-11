import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/points/bloc/points_bloc.dart';
import 'package:tsdm_client/features/points/models/models.dart';
import 'package:tsdm_client/features/points/repository/model/models.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';
import 'package:tsdm_client/widgets/selectable_list_tile.dart';

/// Form to make the user points changelog query filter.
///
/// Combines and format a query form.
class PointsQueryForm extends StatefulWidget {
  /// Constructor.
  const PointsQueryForm(this.allParameters, {super.key});

  /// All available parameters that can use in query.
  final ChangelogAllParameters allParameters;

  @override
  State<PointsQueryForm> createState() => _PointsQueryFormState();
}

final class _PointsQueryFormState extends State<PointsQueryForm> {
  /// Key of the query form.
  final formKey = GlobalKey<FormState>();

  /// Current points type.
  late ChangelogPointsType? pointsType;

  /// Current operation type.
  late ChangelogOperationType? operationType;

  /// Start time of the duration of query parameter.
  String startTime = '';

  /// End time of the duration of query parameter.
  String endTime = '';

  /// Current event change type.
  late ChangelogChangeType? changeType;
  PointsChangeType pointsChangeType = PointsChangeType.unlimited;

  /// Flag to control the visibility of query filter.
  bool showQueryFilter = false;

  /// Show a modal bottom sheet of all points ext type choices.
  Future<void> pickExtType(BuildContext context) async {
    return showCustomBottomSheet(
      context: context,
      title: context.t.pointsPage.changelogTab.operationType,
      childrenBuilder: (context) {
        return widget.allParameters.extTypeList
            .map(
              (e) => SelectableListTile(
                title: Text(e.name),
                selected: e == pointsType,
                onTap: () {
                  setState(() {
                    pointsType = e;
                  });
                  context.pop();
                },
              ),
            )
            .toList();
      },
    );
  }

  /// Let user pick the operation type query parameter.
  Future<void> pickOperationType(BuildContext context) async {
    return showCustomBottomSheet(
      context: context,
      title: context.t.pointsPage.changelogTab.operationType,
      childrenBuilder: (context) {
        return widget.allParameters.operationTypeList
            .map(
              (e) => SelectableListTile(
                title: Text(e.name),
                selected: e == operationType,
                onTap: () {
                  setState(() {
                    operationType = e;
                  });
                  context.pop();
                },
              ),
            )
            .toList();
      },
    );
  }

  Future<void> pickChangeType(BuildContext context) async {
    return showCustomBottomSheet(
      context: context,
      title: context.t.pointsPage.changelogTab.changeType,
      childrenBuilder: (context) {
        return widget.allParameters.changeTypeList
            .map(
              (e) => SelectableListTile(
                title: Text(e.name),
                selected: e == changeType,
                onTap: () {
                  setState(() {
                    changeType = e;
                  });
                  context.pop();
                },
              ),
            )
            .toList();
      },
    );
  }

  Future<void> pickDateRange(BuildContext context) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000, 1, 2),
      lastDate: DateTime.now(),
    );
    if (dateRange == null) {
      return;
    }
    setState(() {
      startTime = dateRange.start.yyyyMMDD();
      endTime = dateRange.end.yyyyMMDD();
    });
  }

  List<Widget> _buildContent(BuildContext context, PointsChangelogState state) {
    VoidCallback? queryCallback;
    if (pointsType != null && operationType != null && changeType != null && state.status != PointsStatus.loading) {
      queryCallback =
          () => context.read<PointsChangelogBloc>().add(
            PointsChangelogQueryRequested(
              ChangelogParameter(
                extType: pointsType!.extType,
                operation: operationType!.operation,
                changeType: changeType!.changeType,
                startTime: startTime,
                endTime: endTime,
                pageNumber: 1,
              ),
            ),
          );
    }

    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async => pickExtType(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: context.t.pointsPage.changelogTab.extType,
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
                ),
                child: Text(pointsType?.name ?? ''),
              ),
            ),
          ),
          sizedBoxW4H4,
          Expanded(
            child: GestureDetector(
              onTap: () async => pickChangeType(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: context.t.pointsPage.changelogTab.changeType,
                  prefixIcon: const Icon(Icons.ssid_chart_outlined),
                  suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
                ),
                child: Text(changeType?.name ?? ''),
              ),
            ),
          ),
        ],
      ),
      GestureDetector(
        onTap: () async => pickOperationType(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: context.t.pointsPage.changelogTab.operationType,
            prefixIcon: const Icon(Icons.select_all_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
          ),
          child: Text(operationType?.name ?? ''),
        ),
      ),
      GestureDetector(
        onTap: () async => pickDateRange(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: context.t.pointsPage.changelogTab.dateRange,
            prefixIcon: const Icon(Icons.date_range_outlined),
          ),
          child: Text('$startTime - $endTime'),
        ),
      ),
      Row(
        children: [
          Expanded(child: FilledButton(onPressed: queryCallback, child: Text(context.t.pointsPage.changelogTab.query))),
        ],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    pointsType = widget.allParameters.extTypeList.firstOrNull;
    operationType = widget.allParameters.operationTypeList.firstOrNull;
    changeType = widget.allParameters.changeTypeList.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    // Reset the null value parameters to prevent disabled query state.
    pointsType ??= widget.allParameters.extTypeList.firstOrNull;
    operationType ??= widget.allParameters.operationTypeList.firstOrNull;
    changeType ??= widget.allParameters.changeTypeList.firstOrNull;

    return BlocBuilder<PointsChangelogBloc, PointsChangelogState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Text(context.t.pointsPage.changelogTab.query, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon:
                      showQueryFilter ? const Icon(Icons.expand_less_outlined) : const Icon(Icons.expand_more_outlined),
                  onPressed: () {
                    setState(() {
                      showQueryFilter = !showQueryFilter;
                    });
                  },
                ),
              ],
            ),
            if (showQueryFilter) ..._buildContent(context, state),
          ].insertBetween(sizedBoxW12H12),
        );
      },
    );
  }
}
