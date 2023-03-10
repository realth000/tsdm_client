import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

import '../models/post.dart';
import '../themes/widget_themes.dart';

/// Card for a [Post] model.
///
/// Usually inside a [ThreadPage].
class PostCard extends ConsumerWidget {
  /// Constructor.
  const PostCard(this.post, {super.key});

  /// [Post] model to show.
  final Post post;

  Widget _buildPostDataWidget(
    BuildContext context,
    WidgetRef ref,
    String data,
  ) {
    final rootWidgetColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
    final rootNode = html_parser.parse(data).body!;

    void traverseNode(dom.Node? node, rootNode) {
      if (node == null) {
        return;
      }
      if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final e = node as dom.Element;
        if (e.localName == 'a') {
          if (e.attributes.containsKey('href')) {
            rootWidgetColumn.children.add(
              InkWell(
                splashColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                child: Text(
                  e.text,
                  style: hrefTextStyle(context),
                ),
                onTap: () async {
                  await launchUrl(Uri.parse(e.attributes['href']!));
                },
              ),
            );
          }
          return;
        } else if (e.localName == 'img') {
          final imageSource = e.attributes['data-original'] ??
              e.attributes['src'] ??
              e.attributes['file'] ??
              '';
          if (imageSource.isNotEmpty) {
            rootWidgetColumn.children.add(
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Image.network(
                  imageSource,
                ),
              ),
            );
          }
          return;
        }
      } else if (node.nodeType == dom.Node.TEXT_NODE) {
        rootWidgetColumn.children.add(
          Text(
            node.text!.trim(),
          ),
        );
      }
      node.nodes.forEach((element) {
        traverseNode(element, rootNode);
      });
      return;
    }

    traverseNode(rootNode, rootNode);

    return RichText(
      text: WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: rootWidgetColumn,
        ),
      ),
    );
  }

  // TODO: Handle better.
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: Column(
          children: [
            ListTile(
              leading: Image.network(post.author.avatarUrl!),
              title: Text(post.author.name),
              subtitle: Text('uid ${post.author.uid ?? ""}'),
              onTap: () {},
            ),
            _buildPostDataWidget(context, ref, post.data),
          ],
        ),
      );
}
