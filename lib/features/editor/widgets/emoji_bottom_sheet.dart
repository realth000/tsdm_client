import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/cache/repository/image_cache_repository.dart';
import 'package:tsdm_client/features/editor/bloc/emoji_bloc.dart';
import 'package:tsdm_client/features/editor/repository/editor_repository.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';

/// Show a bottom sheet that provides emojis in editor.
Future<String?> showEmojiPicker(BuildContext context) async {
  return showCustomBottomSheet<String>(
    title: context.t.bbcodeEditor.emoji.title,
    context: context,
    builder: (context) => RootPage(DialogPaths.emojiPicker, _EmojiBottomSheet(context)),
  );
}

/// Widget to show all available emojis can use in editor.
class _EmojiBottomSheet extends StatefulWidget {
  /// Constructor.
  const _EmojiBottomSheet(this.context);

  final BuildContext context;

  @override
  State<_EmojiBottomSheet> createState() => _EmojiBottomSheetState();
}

class _EmojiBottomSheetState extends State<_EmojiBottomSheet> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  /// When calling this function, assume all emoji is available.
  Widget _buildEmojiTab(BuildContext context, EmojiState state) {
    final emojiGroupList = state.emojiGroupList!;
    tabController ??= TabController(length: emojiGroupList.length, vsync: this);

    final tabs = emojiGroupList.map((e) => Tab(child: Text(e.name)));
    final tabViews = emojiGroupList.map(
          (e) =>
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 50,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 50,
            ),
            itemBuilder: (context, index) {
              final data = RepositoryProvider.of<ImageCacheRepository>(
                context,
              ).getEmojiCacheSync(e.id, e.emojiList[index].id);
              if (data == null) {
                return Text('${e.id}_${e.emojiList[index].id}');
              }
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop(e.emojiList[index].code);
                },
                child: ClipOval(child: Image.memory(data, fit: BoxFit.cover)),
              );
            },
            itemCount: e.emojiList.length,
          ),
    );

    return Column(
      children: [
        TabBar(isScrollable: true, tabAlignment: TabAlignment.start, controller: tabController, tabs: tabs.toList()),
        sizedBoxW12H12,
        Expanded(child: TabBarView(controller: tabController, children: tabViews.toList())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<EditorRepository>(create: (_) => EditorRepository()),
        BlocProvider(create: (context) =>
        EmojiBloc(editRepository: context.repo())
          ..add(EmojiFetchFromAssetEvent())),
      ],
      child: BlocBuilder<EmojiBloc, EmojiState>(
        builder: (context, state) {
          final body = switch (state.status) {
            EmojiStatus.initial || EmojiStatus.loading =>
                Center(
                  child: Padding(
                    padding: edgeInsetsL24R24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        sizedBoxW12H12,
                        Expanded(child: Text(context.t.bbcodeEditor.emoji.loadingAssets)),
                      ],
                    ),
                  ),
                ),
            EmojiStatus.failure =>
                buildRetryButton(context, () {
                  context.read<EmojiBloc>().add(EmojiFetchFromAssetEvent());
                }),
            EmojiStatus.success => _buildEmojiTab(context, state),
          };

          return ConstrainedBox(constraints: const BoxConstraints(maxHeight: 400), child: body);
        },
      ),
    );
  }
}
