import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/rate/bloc/rate_bloc.dart';
import 'package:tsdm_client/features/rate/models/models.dart';
import 'package:tsdm_client/features/rate/repository/rate_repository.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/debounce_buttons.dart';

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
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      decoration: InputDecoration(
        labelText: score.name,
        helperText: tr.scoreTodayRemaining(score: score.remaining),
        suffixText: '${score.allowedRangeDescription} ',
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
    if (state.status == RateStatus.gotInfo) {
      scoreMap ??= Map.fromEntries(
        state.info!.scoreList
            .map((e) => MapEntry(e.id, TextEditingController(text: '0'))),
      );
    }

    if (state.status == RateStatus.initial ||
        state.status == RateStatus.fetchingInfo) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == RateStatus.failed) {
      return const Center(child: CircularProgressIndicator());
    }

    final scoreWidgetList = state.info!.scoreList
        .map((e) => _buildScoreWidget(context, e))
        .toList();

    Widget? defaultReasonButton;
    if (state.info?.defaultReasonList.isNotEmpty ?? false) {
      defaultReasonButton = Focus(
        canRequestFocus: false,
        descendantsAreFocusable: false,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            padding: edgeInsetsR8,
            onChanged: (v) {
              if (v == null) {
                return;
              }
              setState(() {
                reasonController.text = v;
              });
            },
            items: state.info?.defaultReasonList
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
          ),
          // icon: const Icon(Icons.expand_more_outlined),
        ),
      );
    }

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
          sizedBoxW4H4,
          ...scoreWidgetList.insertBetween(sizedBoxW4H4),
          if (scoreWidgetList.isNotEmpty) sizedBoxW4H4,
          TextFormField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: context.t.ratePostPage.reason,
              suffixIcon: defaultReasonButton,
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
          DebounceFilledButton(
            shouldDebounce: state.status.isLoading(),
            onPressed: () async => _rate(context, state.info!),
            child: Text(context.t.ratePostPage.title),
          ),
        ].insertBetween(sizedBoxW12H12),
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
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (_) => RateRepository(),
        ),
        BlocProvider(
          create: (context) =>
              RateBloc(rateRepository: RepositoryProvider.of(context))
                ..add(
                  RateFetchInfoRequested(
                    pid: widget.pid,
                    rateAction: widget.rateAction,
                  ),
                ),
        ),
      ],
      child: BlocListener<RateBloc, RateState>(
        listener: (context, state) {
          if (state.status == RateStatus.failed) {
            // Show reason and pop back if we should not retry.
            showSnackBar(
              context: context,
              message:
                  state.failedReason ?? context.t.ratePostPage.failedToRate,
            );
            if (state.shouldRetry == false) {
              Navigator.of(context).pop();
              return;
            }
            context.read<RateBloc>().add(
                  RateFetchInfoRequested(
                    pid: widget.pid,
                    rateAction: widget.rateAction,
                  ),
                );
          } else if (state.status == RateStatus.success) {
            showSnackBar(
              context: context,
              message: context.t.ratePostPage.success,
            );
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<RateBloc, RateState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(context.t.ratePostPage.title),
              ),
              body: Padding(
                padding: edgeInsetsL16T16R16B16,
                child: _buildBody(context, state),
              ),
            );
          },
        ),
      ),
    );
  }
}
