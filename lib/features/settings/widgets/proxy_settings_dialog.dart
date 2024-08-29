import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/settings/bloc/settings_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Dialog for proxy settings.
///
/// Set proxy address including host name and port.
class ProxySettingsDialog extends StatefulWidget {
  /// Constructor.
  const ProxySettingsDialog({this.host, this.port, super.key});

  /// Initial  host value, if any.
  final String? host;

  /// Initial port value if any.
  final String? port;

  @override
  State<ProxySettingsDialog> createState() => _ProxySettingsDialogState();
}

class _ProxySettingsDialogState extends State<ProxySettingsDialog> {
  late TextEditingController hostController;
  late TextEditingController portController;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    hostController = TextEditingController(text: widget.host);
    portController = TextEditingController(text: widget.port);
  }

  @override
  void dispose() {
    hostController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.advancedSection.proxySettings;
    return AlertDialog(
      scrollable: true,
      title: Text(tr.title),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: hostController,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: Icon(MdiIcons.ipNetworkOutline),
                labelText: tr.host,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty || v.contains(':')) {
                  return tr.invalidHostOrIp;
                }
                return null;
              },
            ),
            sizedBoxW16H16,
            TextFormField(
              controller: portController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.network_ping_outlined),
                labelText: tr.port,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return tr.invalidPort;
                }
                final p = int.tryParse(v);
                if (p == null || !(0 < p && p < 65535)) {
                  return tr.invalidPort;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Clear proxy settings.
            context.read<SettingsBloc>().add(
                  const SettingsValueChanged(SettingsKeys.netClientProxy, ''),
                );
            showSnackBar(
              context: context,
              message: context.t.general.affectAfterRestart,
            );
            context.pop();
          },
          child: Text(context.t.general.reset),
        ),
        sizedBoxW24H24,
        TextButton(
          onPressed: () => context.pop(),
          child: Text(context.t.general.cancel),
        ),
        TextButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) {
              return;
            }
            context.read<SettingsBloc>().add(
                  SettingsValueChanged(
                    SettingsKeys.netClientProxy,
                    '${hostController.text.trim()}:'
                    '${portController.text.trim()}',
                  ),
                );
            showSnackBar(
              context: context,
              message: context.t.general.affectAfterRestart,
            );
            context.pop();
          },
          child: Text(context.t.general.ok),
        ),
      ],
    );
  }
}
