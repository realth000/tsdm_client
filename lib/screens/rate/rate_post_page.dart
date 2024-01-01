import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/models/rate_window_info.dart';
import 'package:tsdm_client/providers/rate_provider.dart';
import 'package:tsdm_client/providers/rate_window_info_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:tsdm_client/utils/show_dialog.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';

/// Page to rate a post in thread.
class RatePostPage extends ConsumerStatefulWidget {
  const RatePostPage({
    required this.username,
    required this.pid,
    required this.floor,
    required this.rateAction,
    super.key,
  });

  final String username;
  final String pid;
  final String floor;
  final String rateAction;

  @override
  ConsumerState<RatePostPage> createState() => _RatePostPageState();
}

class _RatePostPageState extends ConsumerState<RatePostPage> {
  final formKey = GlobalKey<FormState>();

  late Map<String, TextEditingController> scoreMap;
  final reasonController = TextEditingController();

  /// Config to notice author about the rate action.
  ///
  /// Set default to true to behave like web side.
  /// This is also a part of rate action post form. DO NOT FORGET THIS!
  bool noticeAuthor = true;

  Widget _buildScoreWidget(BuildContext context, RateWindowScore score) {
    return TextFormField(
      controller: scoreMap[score.id],
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      decoration: InputDecoration(
        labelText: score.name,
        suffixText: score.allowedRangeDescription,
      ),
      validator: (v) {
        if (v?.contains('.') ?? true) {
          return context.t.ratePostPage.onlyAllowIntegers;
        }
        final vv = v!.trim().parseToInt();
        if (vv == null) {
          return context.t.ratePostPage.invalidNumber;
        }
        final allowedList = score.allowedRangeDescription.split('~');
        final allowedMinValue = allowedList.firstOrNull?.trim().parseToInt();
        final allowedMaxValue = allowedList.lastOrNull?.trim().parseToInt();
        if (allowedMinValue == null || allowedMaxValue == null) {
          return context.t.ratePostPage
              .unknownAllowedRange(range: score.allowedRangeDescription);
        }
        if (vv < allowedMinValue || vv > allowedMaxValue) {
          return context.t.ratePostPage
              .notInAllowedRange(range: score.allowedRangeDescription);
        }
        return null;
      },
    );
  }

  Future<void> _rate(BuildContext context, RateWindowInfo info) async {
    if (formKey.currentState == null || !(formKey.currentState!).validate()) {
      debug('rate post page validate failed');
      return;
    }
    final tid = info.tid;
    final pid = info.pid;
    final formHash = info.formHash;
    final referer = info.referer;
    final handleKey = info.handleKey;

    final body = <String, String>{
      'formhash': formHash,
      'tid': tid,
      'pid': pid,
      'referer': referer,
      'handlekey': handleKey,
      'reason': reasonController.text,
    };
    for (final e in scoreMap.entries) {
      // "0" should make an empty value.
      final v = '${e.value.text.parseToInt()}';
      body[e.key] = v == '0' ? '' : v;
    }
    body['sendreasonpm'] = noticeAuthor ? 'on' : 'off';
    debug('going to rate: $body');

    final result = await ref.read(rateProvider.notifier).rate(body);
    if (!mounted) {
      return;
    }
    if (result is RateSucceed) {
      context.pop();
      return;
    }
    final r = result as RateFailed;
    await showMessageSingleButtonDialog(
      context: context,
      title: context.t.ratePostPage.failedToRate,
      message: r.message,
    );
  }

  Widget _buildBody(BuildContext context, RateWindowInfo info) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          Text(
            context.t.ratePostPage.description(
              username: widget.username,
              floor: widget.floor,
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          sizedBoxW5H5,
          ...info.scoreList.map((e) => _buildScoreWidget(context, e)),
          TextFormField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: context.t.ratePostPage.reason,
            ),
          ),
          SwitchListTile(
            value: noticeAuthor,
            title: Text(context.t.ratePostPage.noticeAuthor),
            onChanged: (value) {
              setState(() {
                noticeAuthor = value;
              });
            },
          ),
          DebounceElevatedButton(
            shouldDebounce: ref.watch(rateProvider) is AsyncLoading,
            onPressed: () async => _rate(context, info),
            child: Text(context.t.ratePostPage.title),
          ),
        ].insertBetween(sizedBoxW10H10),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // scoreMap = Map.fromEntries(widget.info.scoreList
    //     .map((e) => MapEntry(e.id, TextEditingController(text: '0'))));
  }

  @override
  void dispose() {
    reasonController.dispose();
    for (final e in scoreMap.entries) {
      e.value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.ratePostPage.title),
      ),
      body: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: ref.watch(rateInfoProvider(widget.pid, widget.rateAction)).when(
              data: (data) {
                final info = (data as RateInfoSuccess).info;
                scoreMap = Map.fromEntries(
                  info.scoreList.map(
                      (e) => MapEntry(e.id, TextEditingController(text: '0'))),
                );
                return _buildBody(context, info);
              },
              error: (err, _) {
                return Center(child: Text('$err'));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
      ),
    );
  }
}
