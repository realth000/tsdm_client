import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/profile/bloc/edit_avatar_bloc.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/section_title_text.dart';
import 'package:tsdm_client/widgets/tips.dart';

const _avatarMaxWidth = 100.0;
const _avatarMaxHeight = 150.0;

/// Page to edit user avatar.
class EditAvatarPage extends StatefulWidget {
  /// Constructor.
  const EditAvatarPage({super.key});

  @override
  State<EditAvatarPage> createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends State<EditAvatarPage> {
  late final TextEditingController _avatarController;

  /// Url of the avatar intend to preview before submit to server.
  String? _previewUrl;

  Widget _buildContent(BuildContext context, EditAvatarState state) {
    final tr = context.t.editAvatarPage;

    return ListView(
      children: [
        SectionTitleText(tr.currentAvatar),
        if (state.avatarUrl?.isNotEmpty ?? false) ...[
          Padding(
            padding: edgeInsetsL12R12,
            child: CachedImage(state.avatarUrl!, maxWidth: _avatarMaxWidth, maxHeight: _avatarMaxHeight),
          ),
          sizedBoxW12H12,
        ] else ...[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Center(
              child: Text(
                tr.noAvatar,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ),
          sizedBoxW12H12,
        ],
        Padding(
          padding: edgeInsetsL12R12,
          child: TextField(controller: _avatarController, decoration: InputDecoration(labelText: tr.avatarUrl)),
        ),
        sizedBoxW12H12,
        Padding(
          padding: edgeInsetsL12R12,
          child: Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed:
                      state.status == EditAvatarStatus.uploading || _avatarController.text.isEmpty
                          ? null
                          : () => setState(() => _previewUrl = _avatarController.text),
                  child: Text(tr.preview),
                ),
              ),
              sizedBoxW8H8,
              Expanded(
                child: FilledButton(
                  onPressed:
                      state.formHash == null || state.status == EditAvatarStatus.uploading
                          ? null
                          : () {
                            context.read<EditAvatarBloc>().add(
                              EditAvatarUploadRequested(avatarUrl: _avatarController.text, formHash: state.formHash!),
                            );
                          },
                  child: Text(tr.submit),
                ),
              ),
            ],
          ),
        ),
        sizedBoxW12H12,
        Align(
          child: TextButton(
            child: Text(tr.viewSharedAvatars, style: const TextStyle(decoration: TextDecoration.underline)),
            onPressed: () async => context.pushNamed(ScreenPaths.threadV1, queryParameters: {'tid': '1106488'}),
          ),
        ),
        sizedBoxW12H12,
        Tips(tr.clearAvatarTip),

        if (_previewUrl != null) ...[
          SectionTitleText(tr.preview),
          Padding(
            padding: edgeInsetsL12R12,
            child: CachedImage(_previewUrl!, maxWidth: _avatarMaxWidth, maxHeight: _avatarMaxHeight),
          ),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _avatarController = TextEditingController();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditAvatarBloc(context.repo())..add(const EditAvatarLoadInfoRequested()),
      child: BlocConsumer<EditAvatarBloc, EditAvatarState>(
        listenWhen: (prev, _) => prev.status == EditAvatarStatus.loading || prev.status == EditAvatarStatus.uploading,
        listener: (context, state) {
          if (state.status == EditAvatarStatus.waitingForUpload) {
            // Finished the loading state.
            setState(() {
              _avatarController.text = state.draftUrl ?? state.avatarUrl ?? '';
            });
          } else if (state.status == EditAvatarStatus.success) {
            setState(() => _previewUrl = null);
            showSnackBar(context: context, message: context.t.editAvatarPage.avatarUpdated);
            context.read<EditAvatarBloc>().add(const EditAvatarLoadInfoRequested());
          }
        },
        builder: (context, state) {
          final body = switch (state.status) {
            EditAvatarStatus.initial || EditAvatarStatus.loading => const Center(child: CircularProgressIndicator()),
            EditAvatarStatus.waitingForUpload ||
            EditAvatarStatus.success ||
            EditAvatarStatus.uploading => _buildContent(context, state),
            EditAvatarStatus.failure => buildRetryButton(
              context,
              () => context.read<EditAvatarBloc>().add(const EditAvatarLoadInfoRequested()),
            ),
          };

          return Scaffold(
            appBar: AppBar(title: Text(context.t.editAvatarPage.title)),
            body: SafeArea(top: false, bottom: false, child: body),
          );
        },
      ),
    );
  }
}
