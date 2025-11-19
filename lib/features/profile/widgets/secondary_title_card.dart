import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/profile/bloc/my_titles_cubit.dart';
import 'package:tsdm_client/features/profile/models/secondary_title.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';

/// Card to show a secondary title.
class SecondaryTitleCard extends StatefulWidget {
  /// Constructor.
  const SecondaryTitleCard(this.title, {super.key});

  /// The title.
  final SecondaryTitle title;

  @override
  State<SecondaryTitleCard> createState() => _SecondaryTitleCardState();
}

class _SecondaryTitleCardState extends State<SecondaryTitleCard> {
  bool _activated = false;

  @override
  void initState() {
    super.initState();
    _activated = widget.title.activated;
  }

  @override
  Widget build(BuildContext context) {
    _activated = context.select<MyTitlesCubit, bool>(
      (cubit) => cubit.state.titles.firstWhereOrNull((e) => e.id == widget.title.id)?.activated ?? false,
    );
    final loading = context.select<MyTitlesCubit, bool>((cubit) => cubit.state.status == MyTitlesStatus.switchingTitle);

    final card = Card(
      clipBehavior: Clip.hardEdge,
      color: loading ? Theme.of(context).colorScheme.surfaceContainer : null,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: loading ? null : () async => context.read<MyTitlesCubit>().setSecondaryTitle(widget.title.id),
        child: Padding(
          padding: edgeInsetsL12T12R12B12,
          child: Column(
            children: [
              NetworkIndicatorImage(widget.title.imageUrl),
              sizedBoxW8H8,
              Text(
                style: TextStyle(
                  color: loading
                      ? Colors.grey[400]
                      : _activated
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                ),
                '${widget.title.name} (${widget.title.id})',
              ),
            ],
          ),
        ),
      ),
    );

    return ConstrainedBox(
      // A secondary title image is 184x100. Set a larger size for titles and spaces.
      constraints: const BoxConstraints(
        minHeight: 130,
      ),
      child: _activated
          ? ClipRect(
              child: Banner(
                message: context.t.myTitlesPage.current,
                location: BannerLocation.topEnd,
                child: card,
              ),
            )
          : card,
    );
  }
}
