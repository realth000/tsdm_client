import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/forum/bloc/forum_group_bloc.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/widgets/card/forum_card.dart';

/// The forum group page is the page corresponding to urls with `gid` query parameter.
class ForumGroupPage extends StatefulWidget {
  /// Constructor.
  const ForumGroupPage({required this.gid, this.title, super.key});

  /// Optional initial title.
  ///
  /// Usually is the title of forum group.
  final String? title;

  /// The group id to fetch data.
  final String gid;

  @override
  State<ForumGroupPage> createState() => _ForumGroupPageState();
}

class _ForumGroupPageState extends State<ForumGroupPage> {
  Widget _buildContent(BuildContext context, ForumGroup forumGroup) {
    return ListView.separated(
      padding: edgeInsetsL12T4R12.add(context.safePadding()),
      itemCount: forumGroup.forumList.length,
      itemBuilder: (_, index) => ForumCard(forumGroup.forumList[index]),
      separatorBuilder: (_, _) => sizedBoxW4H4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForumGroupBloc(context.repo())..add(ForumGroupLoadRequested(widget.gid)),
      child: BlocBuilder<ForumGroupBloc, ForumGroupBaseState>(
        builder: (context, state) {
          final body = switch (state) {
            ForumGroupInitial() || ForumGroupLoading() => const Center(child: CircularProgressIndicator()),
            ForumGroupSuccess(:final forumGroup) => _buildContent(context, forumGroup),
            ForumGroupFailure() => buildRetryButton(
              context,
              () => context.read<ForumGroupBloc>().add(ForumGroupLoadRequested(widget.gid)),
            ),
          };

          final String? title;
          if (state case ForumGroupSuccess()) {
            title = state.forumGroup.name;
          } else {
            title = null;
          }

          return Scaffold(
            appBar: AppBar(title: Text(title ?? widget.title ?? '')),
            body: SafeArea(bottom: false, child: body),
          );
        },
      ),
    );
  }
}
