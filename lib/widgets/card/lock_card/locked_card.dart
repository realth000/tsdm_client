import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/purchase/bloc/purchase_bloc.dart';
import 'package:tsdm_client/features/purchase/repository/purchase_repository.dart';
import 'package:tsdm_client/features/thread/bloc/thread_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/show_dialog.dart';

// TODO: Separate purchase widget.
/// Widget shows a locked area in `post`.
class LockedCard extends StatefulWidget {
  /// Constructor.
  const LockedCard(this.locked, {super.key});

  /// Locked area model.
  final Locked locked;

  @override
  State<LockedCard> createState() => _LockedCardState();
}

class _LockedCardState extends State<LockedCard> {
  Future<void> _purchaseFetchConfirmInfo(BuildContext context) async {
    context.read<PurchaseBloc>().add(
          PurchaseFetchConfirmInfoRequested(
            tid: widget.locked.tid!,
            pid: widget.locked.pid!,
          ),
        );
  }

  Widget _buildPurchaseBody(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => PurchaseRepository(),
        ),
        BlocProvider(
          create: (context) =>
              PurchaseBloc(purchaseRepository: RepositoryProvider.of(context)),
        ),
      ],
      child: BlocListener<PurchaseBloc, PurchaseState>(
        listener: (context, state) async {
          if (state.status == PurchaseStatus.gotInfo) {
            // Ask the user.
            final info = state.confirmInfo!;

            final purchase = await showQuestionDialog(
              context: context,
              title: context.t.lockedCard.purchase.confirmPurchase,
              message: context.t.lockedCard.purchase.confirmInfo(
                author: info.author ?? '',
                price: info.price ?? '',
                authorProfit: info.authorProfit ?? '',
                coinsLast: info.coinsLast ?? '',
              ),
            );
            if (!context.mounted) {
              return;
            }

            if (purchase == null || !purchase) {
              // User canceled purchasing, reset purchase state.
              context.read<PurchaseBloc>().add(PurchasePurchasedCanceled());
            } else {
              context.read<PurchaseBloc>().add(PurchasePurchaseRequested());
            }
            return;
          } else if (state.status == PurchaseStatus.success) {
            await showMessageSingleButtonDialog(
              context: context,
              title: context.t.lockedCard.purchase.successPurchase,
              message: context.t.lockedCard.purchase.successPurchaseInfo,
            );
            if (!context.mounted) {
              return;
            }
            context.read<ThreadBloc>().add(ThreadRefreshRequested());
          } else if (state.status == PurchaseStatus.failed) {
            await showMessageSingleButtonDialog(
              context: context,
              title: context.t.lockedCard.purchase.failedPurchase,
              message: context.t.lockedCard.purchase.failedPurchase,
            );
            if (!context.mounted) {
              return;
            }
            // Reset purchase state.
            context.read<PurchaseBloc>().add(PurchasePurchasedCanceled());
            return;
          }
        },
        child: BlocBuilder<PurchaseBloc, PurchaseState>(
          builder: (context, state) {
            if (state.status == PurchaseStatus.loading) {
              return const SizedBox(
                width: sizeButtonInCardMinWidth,
                child: Center(child: sizedCircularProgressIndicator),
              );
            }

            return SizedBox(
              width: sizeButtonInCardMinWidth,
              child: FilledButton.icon(
                icon: const Icon(FontAwesomeIcons.coins),
                label: Text('${widget.locked.price}'),
                onPressed: switch (state.status) {
                  PurchaseStatus.initial || PurchaseStatus.failed => () async =>
                      _purchaseFetchConfirmInfo(context),
                  PurchaseStatus.loading ||
                  PurchaseStatus.gotInfo ||
                  PurchaseStatus.success =>
                    null,
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    if (widget.locked.lockedWithPoints) {
      widgets.addAll([
        Text(
          context.t.lockedCard.points.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          context.t.lockedCard.points.detail(
            requiredPoints: widget.locked.requiredPoints!,
            points: widget.locked.points!,
          ),
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ]);
    } else if (widget.locked.lockedWithPurchase) {
      widgets.addAll([
        Text(
          context.t.lockedCard.purchase.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          context.t.lockedCard.purchase
              .purchasedInfo(num: widget.locked.purchasedCount!),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        _buildPurchaseBody(context),
      ]);
    } else if (widget.locked.lockedWithReply) {
      widgets.addAll([
        Text(
          context.t.lockedCard.reply.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          context.t.lockedCard.reply.detail,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ]);
    } else if (widget.locked.lockedWithAuthor) {
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline),
            sizedBoxW5H5,
            Text(
              context.t.lockedCard.author.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets.insertBetween(sizedBoxW5H5),
        ),
      ),
    );
  }
}
