import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/features/post/bloc/post_edit_bloc.dart';
import 'package:tsdm_client/features/post/models/post_edit_type.dart';
import 'package:tsdm_client/features/post/repository/post_edit_repository.dart';

/// Page lets the user to edit a post.
///
/// This is a full screen page, as an alternative choice to edit a post.
///
/// Not only edit the post:
///
/// * Write a new post.
/// * Edit an existing post.
/// * Write a new thread. Because the "thread" is a special post that at the
///   first floor.
///
/// Though writing a new thread looks like a different reason, it is the same
/// with editing a new post.
///
/// # Pop back
///
/// This page is allowed to pop when editing, which means:
///
/// * The user is writing something new, new post or new thread.
/// * The user want to write the post without this page (e.g. in a `ReplyBar`).
///
/// Here we need to ensure:
///
/// * Pop the edit page safely.
/// * Pass the latest edit content back to where user enter this page.
///
/// So when pop back: let the route return value to be a valid object
/// representing the latest edit content.
///
/// Note that this kind of return value is NEVER going to happen when editing
/// something already existed (e.g. edit post and thread) because the all edit
/// ability MUST be in the page. And in this situation we need to notify
/// the user "You are going to leave this page and everything you edited will
/// lost".
class PostEditPage extends StatelessWidget {
  /// Constructor.
  const PostEditPage({
    required this.editType,
    required this.fid,
    required this.tid,
    required this.pid,
    super.key,
  });

  /// Reason to enter [PostEditPage].
  ///
  /// This page is used by multiple reasons:
  ///
  /// * Write a new post.
  /// * Edit an existing post.
  final PostEditType editType;

  /// Forum id of the post.
  final String fid;

  /// Thread id of the post.
  final String tid;

  /// Post id of the post.
  final String pid;

  static String _formatDataUrl({
    required String fid,
    required String tid,
    required String pid,
  }) {
    return '$baseUrl/forum.php?mod=post&action=edit&fid=$fid&tid=$tid&pid=$pid';
  }

  Widget _buildBody(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => PostEditRepository(),
        ),
        BlocProvider(
          create: (context) => PostEditBloc(
            postEditRepository: RepositoryProvider.of(context),
          )..add(
              PostEditLoadDataRequested(
                _formatDataUrl(fid: fid, tid: tid, pid: pid),
              ),
            ),
        ),
      ],
      child: BlocListener<PostEditBloc, PostEditState>(
        listener: (context, state) {
          if (state.status == PostEditStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('failed to load post edit data')),
            );
          }
        },
        child: BlocBuilder<PostEditBloc, PostEditState>(
          builder: (context, state) {
            if (state.status == PostEditStatus.initial ||
                state.status == PostEditStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Text('post edit page1');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }

        // TODO: Control the pop back.
        // * Return the value we need to pass the the caller route if writing
        //   something new.
        // * Let user confirm the pop back if editing something already existed.
        // * If possible save the edit content into draft.
        context.pop();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: _buildBody(context),
      ),
    );
  }
}
