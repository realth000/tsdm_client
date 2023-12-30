import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/locked.dart';
import 'package:tsdm_client/providers/purchase_provider.dart';
import 'package:tsdm_client/providers/screen_state_provider.dart';
import 'package:tsdm_client/utils/show_dialog.dart';

class LockedCard extends ConsumerStatefulWidget {
  const LockedCard(this.locked, {super.key});

  final Locked locked;

  @override
  ConsumerState<LockedCard> createState() => _LockedCardState();
}

class _LockedCardState extends ConsumerState<LockedCard> {
  var _loading = false;

  Widget _buildPurchaseButton(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(FontAwesomeIcons.coins),
      label: Text('${widget.locked.price}'),
      onPressed: () async {
        // Check info.
        if (!widget.locked.isValid()) {
          await showMessageSingleButtonDialog(
            context: context,
            title: context.t.lockedCard.purchase.failedPurchase,
            message: context.t.lockedCard.purchase.failedParsingPurchase,
          );
          setState(() {
            _loading = false;
          });
          return;
        }

        setState(() {
          _loading = true;
        });

        // Fetch confirm info.
        final info =
            await ref.read(purchaseProvider.notifier).conformBeforePurchase(
                  tid: widget.locked.tid!,
                  pid: widget.locked.pid!,
                );

        if (info == null) {
          setState(() {
            _loading = false;
          });
          if (!mounted) {
            return;
          }
          await showMessageSingleButtonDialog(
            context: context,
            title: context.t.lockedCard.purchase.failedPurchase,
            message: context.t.lockedCard.purchase.failedParsingConfirmInfo,
          );
          setState(() {
            _loading = false;
          });
          return;
        }

        if (!mounted) {
          return;
        }

        // Confirm purchase.
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

        if (purchase != true) {
          setState(() {
            _loading = false;
          });
          return;
        }
        if (!mounted) {
          return;
        }

        setState(() {
          _loading = true;
        });

        final purchaseResult =
            await ref.read(purchaseProvider.notifier).purchase(
                  formHash: info.formHash,
                  referer: info.referer,
                  tid: info.tid,
                  handleKey: info.handleKey,
                );

        if (!mounted) {
          return;
        }

        if (purchaseResult is PurchaseFailed) {
          await showMessageSingleButtonDialog(
            context: context,
            title: context.t.lockedCard.purchase.failedPurchase,
            message: purchaseResult.message,
          );
        } else {
          // TODO: Refresh current page after purchase success.
          await showMessageSingleButtonDialog(
            context: context,
            title: context.t.lockedCard.purchase.successPurchase,
            message: context.t.lockedCard.purchase.successPurchaseInfo,
          );

          // Use the specified provider container to access this provider.
          screenStateContainer
              .read(screenStateProvider.notifier)
              .add(ScreenStateEvent.refresh);
        }
        setState(() {
          _loading = false;
        });
      },
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
        SizedBox(
          width: sizeButtonInCardMinWidth,
          child: _loading
              ? const Center(child: sizedCircularProgressIndicator)
              : _buildPurchaseButton(context),
        ),
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
