import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Show a dialog to let user input a price for current thread.
///
/// Only use this when setting price for thread.
Future<int?> showInputPriceDialog(
  BuildContext context,
  int? initialPrice,
) async =>
    showDialog<int>(
      context: context,
      builder: (_) => _InputPriceDialog(initialPrice),
    );

class _InputPriceDialog extends StatefulWidget {
  const _InputPriceDialog(this.initialPrice);

  /// Initial value of price.
  ///
  /// Maybe some price is set before editing current thread.
  final int? initialPrice;

  @override
  State<_InputPriceDialog> createState() => _InputPriceDialogState();
}

class _InputPriceDialogState extends State<_InputPriceDialog> {
  /// Current price value, initial value from widget or user input value.
  int? currentPrice;

  final formKey = GlobalKey<FormState>();

  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    currentPrice = widget.initialPrice;
    priceController = TextEditingController(
      text: currentPrice != null && currentPrice != 0 ? '$currentPrice' : '',
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.postEditPage.priceDialog;
    return AlertDialog(
      title: Text(tr.title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: priceController,
          autofocus: true,
          decoration: InputDecoration(
            helperText: tr.maximum,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null) {
              return tr.invalidPrice;
            }
            if (v.isEmpty) {
              // An empty value means clear the price.
              currentPrice = 0;
              return null;
            }
            final iv = int.tryParse(v);
            // 65535 is the maximum price value.
            if (iv == null || iv < 0 || iv >= 65535) {
              return tr.invalidPrice;
            }
            currentPrice = iv;
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text(context.t.general.cancel),
          onPressed: () => context.pop(),
        ),
        TextButton(
          child: Text(context.t.general.ok),
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              context.pop(currentPrice);
              return;
            }
            return;
          },
        ),
      ],
    );
  }
}
