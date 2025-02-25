import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';
import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/features/checkin/widgets/auto_checkin_user_card.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/widgets/tips.dart';

/// Page to display info about auto checkin status.
class AutoCheckinPage extends StatefulWidget {
  /// Constructor.
  const AutoCheckinPage({super.key});

  @override
  State<AutoCheckinPage> createState() => _AutoCheckinPageState();
}

class _AutoCheckinPageState extends State<AutoCheckinPage> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.autoCheckinPage;
    return BlocBuilder<AutoCheckinBloc, AutoCheckinState>(
      builder: (BuildContext context, state) {
        var waitingList = <UserLoginInfo>[];
        var runningList = <UserLoginInfo>[];
        var succeededList = <(UserLoginInfo, CheckinResult)>[];
        var failedList = <(UserLoginInfo, CheckinResult)>[];
        switch (state) {
          case AutoCheckinStateInitial() || AutoCheckinStatePreparing():
            // Do nothing.
            break;
          case AutoCheckinStateLoading(:final info):
            waitingList = info.waiting;
            runningList = info.running;
            succeededList = info.succeeded;
            failedList = info.failed;
          case AutoCheckinStateFinished(succeeded: final s, failed: final f):
            succeededList = s;
            failedList = f;
        }
        return Scaffold(
          appBar: AppBar(title: Text(tr.title)),
          body: SafeArea(
            child: ListView(
              padding: edgeInsetsL12T4R12B4,
              children: <Widget>[
                Tips(tr.detail, enablePadding: false),
                ...runningList.map((e) => AutoCheckinUserCard(e, tr.user.running)),
                ...waitingList.map((e) => AutoCheckinUserCard(e, tr.user.waiting)),
                ...succeededList.map(
                  (e) => AutoCheckinUserCard(
                    // Ok to use record.
                    // ignore: avoid_positional_fields_in_records
                    e.$1,
                    // Ok to use record.
                    // ignore: avoid_positional_fields_in_records
                    CheckinResult.message(context, e.$2),
                    failure: false,
                  ),
                ),
                ...failedList.map(
                  (e) => AutoCheckinUserCard(
                    // Ok to use record.
                    // ignore: avoid_positional_fields_in_records
                    e.$1,
                    // Ok to use record.
                    // ignore: avoid_positional_fields_in_records
                    CheckinResult.message(context, e.$2),
                    // Ok to use record.
                    // ignore: avoid_positional_fields_in_records
                    failure: e.$2 is! CheckinResultAlreadyChecked,
                  ),
                ),
              ].insertBetween(sizedBoxW8H8),
            ),
          ),
        );
      },
    );
  }
}
