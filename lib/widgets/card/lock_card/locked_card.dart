import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/purchase/bloc/purchase_bloc.dart';
import 'package:tsdm_client/features/purchase/repository/purchase_repository.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/features/thread/v1/bloc/thread_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/custom_alert_dialog.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/single_line_text.dart';
import 'package:universal_html/parsing.dart';

/// Each history item in sales log.
class _SaleLogItem {
  /// Constructor.
  const _SaleLogItem({required this.username, required this.uid, required this.time, required this.price});

  final String username;
  final String uid;
  final DateTime time;
  final String price;
}

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

class _LockedCardState extends State<LockedCard> with LoggerMixin {
  Future<void> _purchaseFetchConfirmInfo(BuildContext context) async {
    context.read<PurchaseBloc>().add(
      PurchaseFetchConfirmInfoRequested(tid: widget.locked.tid!, pid: widget.locked.pid!),
    );
  }

  Future<List<_SaleLogItem>> _fetchSalesHistory(String tid) async {
    final result = await getIt
        .get<NetClientProvider>()
        .get(
          '$baseUrl/forum.php?mod=misc&action=viewpayments&tid=$tid'
          '&infloat=yes&handlekey=pay&inajax=1&ajaxtarget=fwin_content_pay',
        )
        .mapHttp((v) => v.data as String)
        .map((e) => parseXmlDocument(e).documentElement?.nodes.first.text ?? '')
        .map(parseHtmlDocument)
        .map((v) => v.querySelectorAll('table.list tr'))
        .run();
    if (result.isLeft()) {
      error('failed to parse sales history item: ${result.unwrapErr()}');
      return const [];
    }

    final logItemNodes = result.unwrap();
    final logItems = <_SaleLogItem>[];

    for (final logItemNode in logItemNodes) {
      final tdNodes = logItemNode.querySelectorAll('td');
      if (tdNodes.length != 3) {
        continue;
      }
      final userNode = tdNodes.first.querySelector('a');
      final username = userNode?.innerText.trim();
      final uid = userNode?.attributes['href']?.tryParseAsUri()?.queryParameters['uid'];
      final time = tdNodes[1].dateTime();
      final price = tdNodes[2].innerText.trim();

      if (username != null && uid != null && time != null) {
        logItems.add(_SaleLogItem(username: username, uid: uid, time: time, price: price));
      }
    }

    return logItems;
  }

  WidgetSpan _buildUnderlineText(BuildContext context, String text) {
    return WidgetSpan(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface)),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Widget _buildPurchaseBody(BuildContext context) {
    final tr = context.t.lockedCard.purchase;
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => PurchaseRepository()),
        BlocProvider(create: (context) => PurchaseBloc(purchaseRepository: context.repo())),
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
            showSnackBar(context: context, message: tr.successPurchaseInfo);
            if (!context.mounted) {
              return;
            }
            context.read<ThreadBloc>().add(ThreadRefreshRequested());
          } else if (state.status == PurchaseStatus.failed) {
            showSnackBar(context: context, message: tr.failedPurchase);
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
                  PurchaseStatus.initial || PurchaseStatus.failed => () async => _purchaseFetchConfirmInfo(context),
                  PurchaseStatus.loading || PurchaseStatus.gotInfo || PurchaseStatus.success => null,
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

    final primaryStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary);
    final secondaryStyle = Theme.of(context).textTheme.bodySmall;

    final Text title;

    if (widget.locked.lockedWithPoints) {
      title = Text(tr.points.title, style: primaryStyle);
      widgets.addAll([
        Text(
          widget.locked.points != null
              ? tr.points.detail(requiredPoints: widget.locked.requiredPoints!, points: widget.locked.points!)
              : tr.points.detailPassed(requiredPoints: widget.locked.requiredPoints!),
          style: secondaryStyle,
        ),
      ]);
    } else if (widget.locked.lockedWithPurchase) {
      title = Text(tr.purchase.title, style: primaryStyle);
      widgets.addAll([
        if (widget.locked.purchasedCount != null)
          Text.rich(
            tr.purchase.purchasedInfo(num: _buildUnderlineText(context, '${widget.locked.purchasedCount!}')),
            style: secondaryStyle,
          ),
        sizedBoxW4H4,
        _buildPurchaseBody(context),
      ]);
    } else if (widget.locked.lockedWithReply) {
      title = Text(tr.reply.title, style: primaryStyle);
      widgets.addAll([
        Text.rich(tr.reply.detail(reply: _buildUnderlineText(context, tr.reply.detailReply)), style: secondaryStyle),
      ]);
    } else if (widget.locked.lockedWithAuthor) {
      title = Text(tr.author.title, style: primaryStyle);
      widgets.addAll([
        Text.rich(
          tr.author.detail(author: _buildUnderlineText(context, tr.author.detailAuthor)),
          style: secondaryStyle,
        ),
      ]);
    } else if (widget.locked.lockedWithBlocked) {
      title = Text(tr.blocked.title, style: primaryStyle);
      widgets.add(Text(tr.blocked.detail));
    } else if (widget.locked.lockedWithSale) {
      title = Text(tr.sale.title, style: primaryStyle);
      widgets.addAll([
        Text(tr.sale.detail(price: '${widget.locked.price!}', count: '${widget.locked.purchasedCount!}')),
        OutlinedButton(
          child: Text(tr.sale.viewLog),
          onPressed: () async {
            await showDialog<void>(
              context: context,
              builder: (_) => RootPage(
                DialogPaths.showThreadSalesHistory,
                CustomAlertDialog(
                  title: Text(tr.sale.dialog.title),
                  scrollable: true,
                  content: FutureBuilder(
                    future: _fetchSalesHistory(widget.locked.tid!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        error(snapshot.error);
                        return Text(context.t.general.failedToLoad);
                      }

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final salesHistory = snapshot.data!;
                      if (salesHistory.isEmpty) {
                        return Text(
                          context.t.general.noData,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: salesHistory
                            .map(
                              (v) => ListTile(
                                leading: HeroUserAvatar(username: v.username, avatarUrl: null, disableHero: true),
                                title: Text(v.username),
                                isThreeLine: true,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SingleLineText(v.time.yyyyMMDDHHMMSS()),
                                    SingleLineText(tr.sale.dialog.price(price: v.price)),
                                  ],
                                ),
                                onTap: () async =>
                                    context.pushNamed(ScreenPaths.profile, queryParameters: {'uid': v.uid}),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ]);
    } else {
      throw UnimplementedError('Widget for card type of locked card not implemented');
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
                if (widget.locked.lockedWithSale)
                  Icon(Icons.sell_outlined, color: Theme.of(context).colorScheme.primary)
                else
                  Icon(Icons.lock_outlined, color: Theme.of(context).colorScheme.primary),
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
