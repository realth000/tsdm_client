import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/profile/bloc/switch_user_group_bloc.dart';
import 'package:tsdm_client/features/profile/repository/switch_user_group_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/section_list_tile.dart';
import 'package:tsdm_client/widgets/section_title_text.dart';

/// Page to switch user group, if any.
final class SwitchUserGroupPage extends StatefulWidget {
  /// Constructor.
  const SwitchUserGroupPage({super.key});

  @override
  State<SwitchUserGroupPage> createState() => _SwitchUserGroupPageState();
}

class _SwitchUserGroupPageState extends State<SwitchUserGroupPage> with LoggerMixin {
  Widget _buildContent(BuildContext context, SwitchUserGroupState state) {
    final tr = context.t.switchUserGroupPage;
    final colorScheme = Theme.of(context).colorScheme;
    final bodyTheme = Theme.of(context).textTheme.bodyMedium;

    return ListView(
      children: [
        SectionTitleText(tr.currentGroup),
        SectionListTile(
          title: Text(state.currentUserGroup, style: bodyTheme?.copyWith(color: colorScheme.secondary)),
        ),
        if (state.status == SwitchUserGroupStatus.switching)
          Row(children: [SectionTitleText(tr.availableGroups), sizedCircularProgressIndicator])
        else
          SectionTitleText(tr.availableGroups),
        if (state.availableGroups.isEmpty)
          SectionListTile(
            title: Text(tr.nonAvailable, style: bodyTheme?.copyWith(color: colorScheme.outline)),
          )
        else
          ...state.availableGroups.map(
            (e) => SectionListTile(
              title: Text(e.name),
              subtitle: Text('GID: ${e.gid}'),
              enabled: state.status != SwitchUserGroupStatus.switching,
              onTap: () async {
                final confirmed = await showQuestionDialog(
                  context: context,
                  title: tr.title,
                  message: tr.confirmMessage(from: state.currentUserGroup, to: e.name),
                );
                if (confirmed != true || !context.mounted) {
                  return;
                }
                context.read<SwitchUserGroupBloc>().add(
                  SwitchUserGroupRunSwitchRequested(e.name, e.gid, state.formHash),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => const SwitchUserGroupRepository()),
        BlocProvider(create: (context) => SwitchUserGroupBloc(context.repo())..add(SwitchUserGroupLoadInfoRequested())),
      ],
      child: BlocConsumer<SwitchUserGroupBloc, SwitchUserGroupState>(
        listener: (context, state) {
          final tr = context.t.switchUserGroupPage;
          if (state.status == SwitchUserGroupStatus.success) {
            if (state.destination != null) {
              showSnackBar(
                context: context,
                message: tr.switchSucceeded(to: state.destination!),
              );
            } else {
              warning('switch user group succeeded but the destination null. Did you forget to set it?');
            }
            context.pop();
          }
        },
        builder: (context, state) {
          final tr = context.t.switchUserGroupPage;

          final body = switch (state.status) {
            SwitchUserGroupStatus.initial ||
            SwitchUserGroupStatus.loadingInfo => const Center(child: CircularProgressIndicator()),
            SwitchUserGroupStatus.waitingSwitchAction ||
            SwitchUserGroupStatus.switching ||
            SwitchUserGroupStatus.success => _buildContent(context, state),
            SwitchUserGroupStatus.failure => buildRetryButton(
              context,
              () => context.read<SwitchUserGroupBloc>().add(SwitchUserGroupLoadInfoRequested()),
              message: tr.switchFailed,
            ),
          };
          return Scaffold(
            appBar: AppBar(title: Text(tr.title)),
            body: SafeArea(bottom: false, child: body),
          );
        },
      ),
    );
  }
}
