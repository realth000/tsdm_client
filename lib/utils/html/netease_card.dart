import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/providers.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/parsing.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Card to show a parsed netease iframe player.
class NeteaseCard extends StatefulWidget {
  /// Constructor.
  const NeteaseCard(this.id, {super.key});

  /// Song id.
  final String id;

  @override
  State<NeteaseCard> createState() => _NeteaseCardState();
}

class _NeteaseCardState extends State<NeteaseCard> with LoggerMixin {
  static const urlPrefix = 'https://music.163.com/song?id=';

  late String fallbackInfo;

  String _parseMusicInfo(String rawDocument) {
    final doc = parseHtmlDocument(rawDocument);
    final title = doc.querySelector('em.f-ff2')?.innerText;
    final artist = doc.querySelector('p.des.s-fc4 > span')?.title;

    if (title == null || artist == null) {
      error('failed to parse netease music info (id ${widget.id}), '
          'title=$title, artist=$artist');
      return fallbackInfo;
    }

    return '$artist - $title';
  }

  @override
  void initState() {
    super.initState();
    fallbackInfo = 'id: ${widget.id}';
  }

  @override
  Widget build(BuildContext context) {
    final infoStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async => launchUrlString('$urlPrefix${widget.id}'),
        child: Card(
          child: Padding(
            padding: edgeInsetsL12T12R12B12,
            child: Row(
              children: [
                Icon(
                  Icons.music_note_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                sizedBoxW8H8,
                Expanded(
                  child: FutureBuilder(
                    future: getIt
                        .get<NetClientProvider>(
                          instanceName: ServiceKeys.noCookie,
                        )
                        .get('$urlPrefix${widget.id}')
                        .run(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return switch (snapshot.data!) {
                          fp.Left() => Text(fallbackInfo, style: infoStyle),
                          fp.Right(:final value) => Text(
                              _parseMusicInfo(value.data as String),
                              style: infoStyle,
                            ),
                        };
                      }

                      return sizedCircularProgressIndicator;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
