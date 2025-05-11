import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// Page showing changelog bundled with app.
class LocalChangelogPage extends StatelessWidget {
  /// Constructor.
  const LocalChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.t.settingsPage.othersSection;
    return Scaffold(
      appBar: AppBar(title: Text(tr.changelog)),
      body: FutureBuilder(
        future: compute(readChangelogContent, ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Unreachable.
            return Text('error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Markdown(data: snapshot.data!);
        },
      ),
    );
  }
}
