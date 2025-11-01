import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/date_time.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/settings/models/historical_log.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_toast.dart';

/// Debug page for show all caught log since this start.
class DebugLogPage extends StatefulWidget {
  /// Constructor.
  const DebugLogPage({super.key});

  @override
  State<DebugLogPage> createState() => _DebugLogPageState();
}

class _DebugLogPageState extends State<DebugLogPage> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.debugLogPage;
    return TalkerScreen(talker: talker, appBarTitle: tr.title);
  }
}

/// Page showing all historical logs.
class DebugHistoricalLogPage extends StatelessWidget with LoggerMixin {
  /// Constructor.
  const DebugHistoricalLogPage({super.key});

  Future<List<HistoricalLog>> _loadLogFiles() async {
    final logDir = await getLogDir();
    if (!logDir.existsSync()) {
      error('log directory not found: ${logDir.path}');
      return [];
    }

    final logFiles = <HistoricalLog>[];

    final nameRe = RegExp(r'^tsdm_client_(?<year>\d\d\d\d)(?<month>\d\d)(?<day>\d\d).log$');
    for (final logFile in logDir.listSync()) {
      if (logFile.statSync().type != FileSystemEntityType.file) {
        continue;
      }
      final fileName = path.basename(logFile.path);
      final m = nameRe.firstMatch(fileName);
      if (m == null) {
        continue;
      }

      final year = m.namedGroup('year')!.parseToInt()!;
      final month = m.namedGroup('month')!.parseToInt()!;
      final day = m.namedGroup('day')!.parseToInt()!;

      final logTime = DateTime(year, month, day);
      logFiles.add(HistoricalLog(logTime, File(logFile.path)));
    }

    return logFiles;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.debugSection.viewHistoryLog;
    final body = FutureBuilder(
      future: _loadLogFiles(),
      builder: (BuildContext context, AsyncSnapshot<List<HistoricalLog>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          error('failed to load logs: ${snapshot.error}');
          return Center(child: Text('${context.t.general.failedToLoad}: ${snapshot.error}'));
        }

        final logFiles = snapshot.data!;

        return ListView.builder(
          padding: context.safePadding(),
          itemCount: logFiles.length,
          itemBuilder: (context, idx) => ListTile(
            title: Text(logFiles[idx].time.yyyyMMDD()),
            onTap: () async => context.pushNamed(ScreenPaths.debugHistoricalLogDetail, extra: logFiles[idx]),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(tr.historicalLogs)),
      body: SafeArea(bottom: false, child: body),
    );
  }
}

/// Page to show the detail of historical log.
///
/// The caller MUST ensure corresponding log file is accessible.
class DebugHistoricalLogDetailPage extends StatefulWidget {
  /// Constructor.
  const DebugHistoricalLogDetailPage(this.log, {super.key});

  /// The log to show page.
  final HistoricalLog log;

  @override
  State<DebugHistoricalLogDetailPage> createState() => _DebugHistoricalLogDetailPageState();
}

class _DebugHistoricalLogDetailPageState extends State<DebugHistoricalLogDetailPage> with LoggerMixin {
  /// Log content.
  String? _logData;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.debugSection.viewHistoryLog;
    final body = FutureBuilder(
      future: File(widget.log.file.path).readAsString(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          error('failed to load log ${widget.log.time.yyyyMMDD()}: ${snapshot.error}');
          return Center(child: Text('${context.t.general.failedToLoad}: ${snapshot.error}'));
        }

        _logData = snapshot.data;

        return SingleChildScrollView(child: SelectableText(_logData!));
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.log.time.yyyyMMDD()),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: () async {
              if (_logData == null) {
                showSnackBar(context: context, message: 'Log is empty');
                return;
              }
              await FilePicker.platform.saveFile(
                fileName: 'log_${widget.log.time.yyyyMMDD()}.txt',
                bytes: utf8.encode(_logData!),
              );
            },
            tooltip: tr.export,
          ),
        ],
      ),
      body: SafeArea(bottom: false, child: body),
    );
  }
}
