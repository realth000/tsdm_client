import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/purchase/bloc/purchase_bloc.dart';
import 'package:tsdm_client/features/purchase/repository/purchase_repository.dart';
import 'package:tsdm_client/features/thread/bloc/thread_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';

// TODO: Separate purchase widget.
/// Widget shows a locked area in `post`.
class LockedCard extends StatefulWidget {
  /// Constructor.
  const LockedCard(this.locked, {this.elevation, super.key});

  /// Locked area model.
  final Locked locked;

  /// Elevation of this card.
  final double? elevation;

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

  WidgetSpan _buildUnderlineText(BuildContext context, String text) {
    return WidgetSpan(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildPurchaseBody(BuildContext context) {
    final tr = context.t.lockedCard.purchase;
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
              title: tr.confirmPurchase,
              message: tr.confirmInfo(
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
            showSnackBar(
              context: context,
              message: tr.successPurchaseInfo,
            );
            if (!context.mounted) {
              return;
            }
            context.read<ThreadBloc>().add(ThreadRefreshRequested());
          } else if (state.status == PurchaseStatus.failed) {
            showSnackBar(
              context: context,
              message: tr.failedPurchase,
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
              child: OutlinedButton.icon(
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
    final tr = context.t.lockedCard;
    final widgets = <Widget>[];

    final primaryStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        );
    final secondaryStyle = Theme.of(context).textTheme.bodySmall;

    final Text title;

    if (widget.locked.lockedWithPoints) {
      title = Text(tr.points.title, style: primaryStyle);
      widgets.addAll([
        Text.rich(
          tr.points.detail(
            requiredPoints: _buildUnderlineText(
              context,
              '${widget.locked.requiredPoints!}',
            ),
            points: _buildUnderlineText(
              context,
              '${widget.locked.points!}',
            ),
          ),
          style: secondaryStyle,
        ),
      ]);
    } else if (widget.locked.lockedWithPurchase) {
      title = Text(tr.purchase.title, style: primaryStyle);
      widgets.addAll([
        Text.rich(
          tr.purchase.purchasedInfo(
            num: _buildUnderlineText(
              context,
              '${widget.locked.purchasedCount!}',
            ),
          ),
          style: secondaryStyle,
        ),
        sizedBoxW4H4,
        _buildPurchaseBody(context),
      ]);
    } else if (widget.locked.lockedWithReply) {
      title = Text(tr.reply.title, style: primaryStyle);
      widgets.addAll([
        Text.rich(
          tr.reply.detail(
            reply: _buildUnderlineText(
              context,
              tr.reply.detailReply,
            ),
          ),
          style: secondaryStyle,
        ),
      ]);
    } else if (widget.locked.lockedWithAuthor) {
      title = Text(tr.author.title, style: primaryStyle);
      widgets.addAll([
        Text.rich(
          tr.author.detail(
            author: _buildUnderlineText(
              context,
              tr.author.detailAuthor,
            ),
          ),
          style: secondaryStyle,
        ),
      ]);
    } else {
      throw UnimplementedError(
        'Widget for card type of locked card not implemented',
      );
    }

    return Card(
      elevation: widget.elevation,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: edgeInsetsL16T16R16B16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                sizedBoxW8H8,
                title,
              ],
            ),
            sizedBoxW8H8,
            ...widgets.insertBetween(sizedBoxW8H8),
          ],
        ),
      ),
    );
  }
}
