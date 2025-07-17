import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/open_in_app/models/openable_forum_resource_model.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/widgets/tips.dart';

/// A button opens route to [OpenInAppPage],
class OpenInAppPageButton extends StatelessWidget {
  /// Constructor.
  const OpenInAppPageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.open_in_new),
      tooltip: context.t.openInAppPage.entryTooltip,
      onPressed: () async => context.pushNamed(ScreenPaths.openInApp),
    );
  }
}

/// A page accept different kinds of user input and try parse the desired forum resource then open in app.
///
/// Supported inputs:
///
/// * Forum url.
///   * Should be recognized by url dispatcher.
/// * User id.
/// * Username.
/// * Forum id.
/// * Thread id.
/// * Post id.
class OpenInAppPage extends StatefulWidget {
  /// Constructor.
  const OpenInAppPage({super.key});

  @override
  State<OpenInAppPage> createState() => _OpenInAppPageState();
}

class _OpenInAppPageState extends State<OpenInAppPage> {
  final formKey = GlobalKey<FormState>();

  /// Controller of target content text.
  late final TextEditingController targetController;

  /// Current resource type in [availableResources].
  int currentResourceIndex = 0;

  /// Current parsed and recognized route parsed from user input url.
  RecognizedRoute? currentRoute;

  final List<OpenableForumResource<dynamic>> availableResources = [
    UrlResource(),
    UsernameResource(),
    UidResource(),
    FidResource(),
    TidResource(),
    PidResource(),
  ];

  @override
  void initState() {
    super.initState();
    targetController = TextEditingController();
  }

  @override
  void dispose() {
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.openInAppPage;
    return Scaffold(
      appBar: AppBar(title: Text(tr.title)),
      body: ListView(
        padding: context.safePadding().add(edgeInsetsL12R12),
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: availableResources
                .mapIndexed(
                  (idx, v) => FilterChip(
                    label: Text(v.typename(context)),
                    onSelected: (selected) => selected ? setState(() => currentResourceIndex = idx) : null,
                    selected: currentResourceIndex == idx,
                  ),
                )
                .toList(),
          ),
          sizedBoxW8H8,
          Tips(availableResources[currentResourceIndex].detail(context), enablePadding: false),
          sizedBoxW16H16,
          Form(
            key: formKey,
            child: TextFormField(
              controller: targetController,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: availableResources[currentResourceIndex].typename(context)),
              validator: (v) => availableResources[currentResourceIndex].validator()(context, v).match((e) => e, (v) {
                setState(() => currentRoute = v);
                return null;
              }),
            ),
          ),
          sizedBoxW24H24,
          FilledButton.icon(
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
      ),
    );
  }
}
