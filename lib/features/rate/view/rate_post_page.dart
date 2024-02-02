import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/rate/bloc/rate_bloc.dart';
import 'package:tsdm_client/features/rate/models/rate_window_info.dart';
import 'package:tsdm_client/features/rate/repository/rate_repository.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/utils/debug.dart';
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

class _RatePostPageState extends State<RatePostPage> {
  final formKey = GlobalKey<FormState>();

  Map<String, TextEditingController>? scoreMap;
  final reasonController = TextEditingController();

  /// Config to notice author about the rate action.
  ///
  /// Set default to true to behave like web side.
  /// This is also a part of rate action post form. DO NOT FORGET THIS!
  bool noticeAuthor = true;

  Widget _buildScoreWidget(BuildContext context, RateWindowScore score) {
    return TextFormField(
      controller: scoreMap![score.id],
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
          ...state.info!.scoreList.map((e) => _buildScoreWidget(context, e)),
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
            shouldDebounce: state.status.isLoading(),
            onPressed: () async => _rate(context, state.info!),
            child: Text(context.t.ratePostPage.title),
          ),
        ].insertBetween(sizedBoxW10H10),
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
            if (state.shouldRetry == false) {
              // Show reason and pop back if we should not retry.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.failedReason ?? context.t.ratePostPage.failedToRate,
                  ),
                ),
              );
              Navigator.of(context).pop();
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t.ratePostPage.failedToRate)),
            );
            context.read<RateBloc>().add(
                  RateFetchInfoRequested(
                    pid: widget.pid,
                    rateAction: widget.rateAction,
                  ),
                );
          } else if (state.status == RateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.t.ratePostPage.success)),
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
                padding: edgeInsetsL15T15R15B15,
                child: _buildBody(context, state),
              ),
            );
          },
        ),
      ),
    );
  }
}
