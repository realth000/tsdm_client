import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/tips.dart';

/// A button provides a dialog that let user input a url and parse it, if that
/// url is a valid recognized url, open that url page in app.
class ParseUrlDialogButton extends StatelessWidget {
  /// Constructor.
  const ParseUrlDialogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.open_in_new),
      tooltip: context.t.parseUrlDialog.entryTooltip,
      onPressed: () async => _showParseUrlDialog(context),
    );
  }
}

/// Open a dialog that let user input and parse a url, if the url is valid
/// recognized routes in app, redirect to thr relevant route page.
Future<void> _showParseUrlDialog(BuildContext context) async =>
    showDialog<void>(context: context, builder: (_) => const RootPage(DialogPaths.parseUrl, _ParseUrlDialog()));

/// A dialog let user input a url, try to parse the url into a app route. If is,
/// redirect to the relevant page.
///
/// Requires input url to be in form of recognized urls.
class _ParseUrlDialog extends StatefulWidget {
  const _ParseUrlDialog();

  @override
  State<_ParseUrlDialog> createState() => _ParseUrlDialogState();
}

class _ParseUrlDialogState extends State<_ParseUrlDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController urlController;

  /// Current parsed and recognized route parsed from user input url.
  RecognizedRoute? currentRoute;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.parseUrlDialog;
    return AlertDialog(
      title: Text(tr.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(tr.detail, style: Theme.of(context).textTheme.bodyMedium),
          Tips(tr.detail, enablePadding: false),
          sizedBoxW24H24,
          Form(
            key: formKey,
            child: TextFormField(
              controller: urlController,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: tr.url),
              validator: (v) {
                if (v == null) {
                  return tr.unsupportedUrl;
                }

                final parsedRoute = v.parseUrlToRoute();
                if (parsedRoute == null) {
                  return tr.unsupportedUrl;
                }
                currentRoute = parsedRoute;
                return null;
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          label: Text(tr.open),
          icon: const Icon(Icons.open_in_new),
          onPressed: () async {
            if (formKey.currentState!.validate() != true) {
              return;
            }
            if (currentRoute == null) {
              return;
            }

            await context.pushNamed(
              currentRoute!.screenPath,
              pathParameters: currentRoute!.pathParameters,
              queryParameters: currentRoute!.queryParameters,
            );
            if (!context.mounted) {
              return;
            }
            context.pop();
          },
        ),
      ],
    );
  }
}
