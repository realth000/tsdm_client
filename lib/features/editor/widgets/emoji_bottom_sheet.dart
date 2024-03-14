import 'package:flutter/material.dart';
import 'package:flutter_bbcode_editor/flutter_bbcode_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/editor/bloc/emoji_bloc.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/utils/retry_button.dart';

/// Show a bottom sheet that provides emojis in editor.
Future<void> showEmojiBottomSheet(
  BuildContext context,
  BBCodeEditorController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => _EmojiBottomSheet(context, controller),
  );
}

/// Widget to show all available emojis can use in editor.
class _EmojiBottomSheet extends StatefulWidget {
  /// Constructor.
  const _EmojiBottomSheet(this.context, this.controller);

  final BuildContext context;

  final BBCodeEditorController controller;

  @override
  State<_EmojiBottomSheet> createState() => _EmojiBottomSheetState();
}

class _EmojiBottomSheetState extends State<_EmojiBottomSheet>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  /// When calling this function, assume all emoji is available.
  Widget _buildEmojiTab(BuildContext context, EmojiState state) {
    final emojiGroupList = state.emojiGroupList!;
    tabController ??= TabController(
      length: emojiGroupList.length,
      vsync: this,
    );

    final tabs = emojiGroupList.map((e) => Tab(child: Text(e.name)));
    final tabViews = emojiGroupList.map(
      (e) => GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 50,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 50,
        ),
        itemBuilder: (context, index) {
          final data = getIt.get<ImageCacheProvider>().getEmojiCacheSync(
                e.id,
                e.emojiList[index].id,
              );
          if (data == null) {
            return Text(
              '${e.id}_${e.emojiList[index].id}',
            );
          }
          return GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await widget.controller.insertEmoji(e.emojiList[index].code);
            },
            child: ClipOval(
              child: Image.memory(
                data,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        itemCount: e.emojiList.length,
      ),
    );

    return Column(
      children: [
        TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          controller: tabController,
          tabs: tabs.toList(),
        ),
        sizedBoxW10H10,
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: tabViews.toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, EmojiState state) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Center(
            child: Text(
              context.t.bbcodeEditor.emoji.title,
            ),
          ),
        ),
        sizedBoxW10H10,
        Expanded(child: _buildEmojiTab(context, state)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmojiBloc(
        editRepository: RepositoryProvider.of(context),
      )..add(EmojiFetchFromCacheEvent()),
      child: BlocBuilder<EmojiBloc, EmojiState>(
        builder: (context, state) {
          final body = switch (state.status) {
            EmojiStatus.initial || EmojiStatus.loading => Center(
                child: Padding(
                  padding: edgeInsetsL20R20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      sizedBoxW10H10,
                      Expanded(
                        child: Text(
                          context.t.bbcodeEditor.emoji.downloading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            EmojiStatus.failed => buildRetryButton(context, () {
                context.read<EmojiBloc>().add(EmojiFetchFromServerEvent());
              }),
            EmojiStatus.success => _buildBody(context, state),
          };

          return Scaffold(
            body: Padding(
              padding: edgeInsetsL15T15R15B15,
              child: body,
            ),
          );
        },
      ),
    );
  }
}
