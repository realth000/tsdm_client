import 'package:flutter/material.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:url_launcher/url_launcher.dart';

/// Munch the html node [rootElement] and its children nodes into a flutter
/// widget.
///
/// Main entry of this package.
Widget munchElement(BuildContext context, uh.Element rootElement) {
  final muncher = Muncher(
    context,
  );

  final widgets = <Widget>[];
  for (final node in rootElement.nodes) {
    muncher.munchNode(context, node, widgets);
  }
  return Column(children: widgets);
}

/// State of [Muncher].
class MunchState {
  MunchState();

  bool strong = false;
}

/// Munch html nodes into flutter widgets.
class Muncher {
  Muncher(this.context);

  final BuildContext context;
  final MunchState state = MunchState();

  void munchNode(
      BuildContext context, uh.Node? node, List<Widget> contextWidgets) {
    if (node == null) {
      // Reach end.
      return;
    }
    if (node.nodeType == uh.Node.ELEMENT_NODE) {
      final e = node as uh.Element;
      if (e.localName == 'a') {
        if (node.nodeType == uh.Node.ELEMENT_NODE) {
          if (node.localName == 'a') {
            if (node.attributes.containsKey('href')) {
              contextWidgets.add(
                InkWell(
                  splashColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  child: Text(
                    node.text?.trim() ?? '',
                    style: TextStyle(
                      overflow: TextOverflow.fade,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onTap: () async {
                    await launchUrl(
                      Uri.parse(node.attributes['href']!),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              );
            }
            return;
          } else if (node.localName == 'img') {
            final imageSource = node.attributes['data-original'] ??
                node.attributes['src'] ??
                node.attributes['file'] ??
                '';
            if (imageSource.isNotEmpty) {
              contextWidgets.add(
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: NetworkIndicatorImage(imageSource),
                ),
              );
            }
            return;
          }
        } else if (node.nodeType == uh.Node.TEXT_NODE) {
          contextWidgets.add(Text(node.text!.trim()));
        }
      }
    }
    return;
  }
}
