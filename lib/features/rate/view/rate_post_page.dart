import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/rate/bloc/rate_bloc.dart';
import 'package:tsdm_client/features/rate/models/models.dart';
import 'package:tsdm_client/features/rate/repository/rate_repository.dart';
import 'package:tsdm_client/features/root/view/root_page.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';
import 'package:tsdm_client/widgets/section_switch_list_tile.dart';

/// Page to rate a post in thread.
class RatePostPage extends StatefulWidget {
  /// Constructor.
  const RatePostPage({
    required this.username,
    required this.pid,
    required this.floor,
    required this.rateAction,
    super.key,
  });

  /// Username.
  final String username;

  /// Post id.
  final String pid;

  /// Post floor.
  final String floor;

  /// Url to do the rate action.
  final String rateAction;

  @override
  State<RatePostPage> createState() => _RatePostPageState();
}

class _RatePostPageState extends State<RatePostPage> with LoggerMixin {
  final formKey = GlobalKey<FormState>();

  Map<String, TextEditingController>? scoreMap;
  final reasonController = TextEditingController();

  /// Config to notice author about the rate action.
  ///
  /// Set default to true to behave like web side.
  /// This is also a part of rate action post form. DO NOT FORGET THIS!
  bool noticeAuthor = true;

  Widget _buildScoreWidget(BuildContext context, RateWindowScore score) {
    final tr = context.t.ratePostPage;
    return TextFormField(
      controller: scoreMap![score.id],
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      decoration: InputDecoration(
        labelText: score.name,
        helperText: tr.scoreTodayRemaining(score: score.remaining),
        helperStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
        suffixText: '${score.allowedRangeDescription} ',
        suffixStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
      ),
      validator: (v) {
        if (v?.contains('.') ?? true) {
          return tr.onlyAllowIntegers;
        }
        final vv = v!.trim().parseToInt();
        if (vv == null) {
          return tr.invalidNumber;
        }
        final allowedList = score.allowedRangeDescription.split('~');
        final allowedMinValue = allowedList.firstOrNull?.trim().parseToInt();
        final allowedMaxValue = allowedList.lastOrNull?.trim().parseToInt();
        if (allowedMinValue == null || allowedMaxValue == null) {
          return tr.unknownAllowedRange(range: score.allowedRangeDescription);
        }
        if (vv < allowedMinValue || vv > allowedMaxValue) {
          return tr.notInAllowedRange(range: score.allowedRangeDescription);
        }
        return null;
      },
    );
  }

  Future<void> _rate(BuildContext context, RateWindowInfo info) async {
    if (formKey.currentState == null || !(formKey.currentState!).validate()) {
      error('rate post page validate failed');
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
    for (final e in scoreMap!.entries) {
      // "0" should make an empty value.
      final v = '${e.value.text.parseToInt()}';
      body[e.key] = v == '0' ? '' : v;
    }
    body['sendreasonpm'] = noticeAuthor ? 'on' : 'off';
    debug('going to rate: $body');

    context.read<RateBloc>().add(RateRateRequested(body));
  }

  Widget _buildBody(BuildContext context, RateState state) {
    final tr = context.t.ratePostPage;

    if (state.status == RateStatus.gotInfo) {
      scoreMap ??= Map.fromEntries(state.info!.scoreList.map((e) => MapEntry(e.id, TextEditingController(text: '0'))));
    }

    if (state.status == RateStatus.initial || state.status == RateStatus.fetchingInfo) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == RateStatus.failed) {
      return const Center(child: CircularProgressIndicator());
    }

    final scoreWidgetList = state.info!.scoreList.map((e) => _buildScoreWidget(context, e)).toList();

    Widget? defaultReasonButton;
    if (state.info?.defaultReasonList.isNotEmpty ?? false) {
      defaultReasonButton = Focus(
        canRequestFocus: false,
        descendantsAreFocusable: false,
        child: IconButton(
          icon: const Icon(Icons.arrow_drop_down_outlined),
          onPressed:
              () async => showDialog(
                context: context,
                builder:
                    (_) => RootPage(
                      DialogPaths.selectRateReason,
                      AlertDialog(
                        title: Text(tr.reason),
                        scrollable: true,
                        content: Column(
                          children:
                              state.info!.defaultReasonList
                                  .map(
                                    (e) => ListTile(
                                      title: Text(e),
                                      onTap: () {
                                        context.pop();
                                        setState(() {
                                          reasonController.text = e;
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
              ),
        ),
      );
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxW12H12,
          // Body title.
          Row(
            children: [
              sizedBoxW12H12,
              Expanded(
                child: Text(
                  tr.description(username: widget.username, floor: widget.floor),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              sizedBoxW12H12,
            ],
          ),
          sizedBoxW12H12,
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 80,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              padding: edgeInsetsL12T8R12,
              children: scoreWidgetList,
            ),
          ),
          sizedBoxW8H8,
          Row(
            children: [
              sizedBoxW12H12,
              Expanded(
                child: TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(labelText: tr.reason, suffixIcon: defaultReasonButton),
                ),
              ),
              sizedBoxW12H12,
            ],
          ),
          SectionSwitchListTile(
            value: noticeAuthor,
            title: Text(tr.noticeAuthor),
            onChanged: (value) {
              setState(() {
                noticeAuthor = value;
              });
            },
          ),
          sizedBoxW12H12,
          Row(
            children: [
              sizedBoxW12H12,
              Expanded(
                child: DebounceFilledButton(
                  shouldDebounce: state.status.isLoading(),
                  onPressed: () async => _rate(context, state.info!),
                  child: Text(tr.title),
                ),
              ),
              sizedBoxW12H12,
            ],
          ),
          Padding(padding: context.safePadding()),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    reasonController.dispose();
    if (scoreMap != null) {
      for (final e in scoreMap!.entries) {
        e.value.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.ratePostPage;

    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => RateRepository()),
        BlocProvider(
          create:
              (context) =>
                  RateBloc(rateRepository: context.repo())
                    ..add(RateFetchInfoRequested(pid: widget.pid, rateAction: widget.rateAction)),
        ),
      ],
      child: BlocListener<RateBloc, RateState>(
        listener: (context, state) {
          if (state.status == RateStatus.failed) {
            // Show reason and pop back if we should not retry.
            showSnackBar(context: context, message: state.failedReason ?? tr.failedToRate);
            if (state.shouldRetry == false) {
              Navigator.of(context).pop();
              return;
            }
            context.read<RateBloc>().add(RateFetchInfoRequested(pid: widget.pid, rateAction: widget.rateAction));
          } else if (state.status == RateStatus.success) {
            showSnackBar(context: context, message: tr.success);
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<RateBloc, RateState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text(tr.title)),
              body: SafeArea(bottom: false, child: _buildBody(context, state)),
            );
          },
        ),
      ),
    );
  }
}
