import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/features/checkin/bloc/auto_checkin_bloc.dart';

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
    return BlocBuilder<AutoCheckinBloc, AutoCheckinState>(
      builder: (BuildContext context, state) {
        return Scaffold(
          appBar: AppBar(),
        );
      },
    );
  }
}
