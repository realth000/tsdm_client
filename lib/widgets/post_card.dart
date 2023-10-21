import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:tsdm_client/models/post.dart';
import 'package:tsdm_client/themes/widget_themes.dart';
import 'package:tsdm_client/widgets/cached_image_provider.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';
import 'package:url_launcher/url_launcher.dart';

/// Card for a [Post] model.
///
/// Usually inside a ThreadPage.
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
    final c = <Widget>[];
    final rootNode = html_parser.parse(data).body!;

    void traverseNode(dom.Node? node, dom.Node rootNode) {
      if (node == null) {
        return;
      }
      if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final e = node as dom.Element;
        if (e.localName == 'a') {
          if (e.attributes.containsKey('href')) {
            c.add(
              InkWell(
                splashColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                child: Text(
                  e.text.trim(),
                  style: hrefTextStyle(context),
                ),
                onTap: () async {
                  await launchUrl(
                    Uri.parse(e.attributes['href']!),
                    mode: LaunchMode.externalApplication,
                  );
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
            c.add(
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
      } else if (node.nodeType == dom.Node.TEXT_NODE) {
        c.add(
          Text(
            node.text!.trim(),
          ),
        );
      }
      for (final element in node.nodes) {
        traverseNode(element, rootNode);
      }
      return;
    }

    traverseNode(rootNode, rootNode);

    return RichText(
      text: WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: c,
          ),
        ),
      ),
    );
  }

  // TODO: Handle better.
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedImageProvider(
                  post.author.avatarUrl!,
                  ref,
                ),
              ),
              title: Text(post.author.name),
              subtitle: Text('uid ${post.author.uid ?? ""}'),
              onTap: () {},
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: _buildPostDataWidget(context, ref, post.data),
            ),
          ],
        ),
      );
}
