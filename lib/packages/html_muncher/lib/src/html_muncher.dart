import 'package:flutter/material.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/widgets/cached_image.dart';
import 'package:universal_html/html.dart' as uh;

extension MunchExtension on List<Widget> {
  void addOrAppendText(TextSpan textSpan) {
    if (isEmpty) {
      add(RichText(text: textSpan));
      return;
    }

    if (last.runtimeType != RichText) {
      add(RichText(text: textSpan));
      return;
    }

    final lastSpan = last as RichText;

    lastSpan.children.add(textSpan as Widget);
    last = lastSpan;
  }
}

abstract class HtmlSpan {
  final children = <InlineSpan>[];

  void addSpan(InlineSpan? span) {
    if (span == null) {
      return;
    }
    children.add(span);
  }

  Widget toWidget();
}

class ColumnSpan extends HtmlSpan {
  @override
  Widget toWidget() {
    return Column(children: children.map((e) => RichText(text: e)).toList());
  }
}

class RowSpan extends HtmlSpan {
  bool get isEmpty => children.isEmpty;

  bool get isNotEmpty => !isEmpty;

  void clear() {
    children.clear();
  }

  @override
  Widget toWidget() {
    return RichText(
      text: TextSpan(
        children: children,
      ),
    );
  }
}

/// Munch the html node [rootElement] and its children nodes into a flutter
/// widget.
///
/// Main entry of this package.
Widget munchElement(BuildContext context, uh.Element rootElement) {
  final muncher = Muncher(
    context,
  );

  return muncher._munch(context, rootElement);
}

/// State of [Muncher].
class MunchState {
  MunchState();

  bool strong = false;
  bool br = false;
}

/// Munch html nodes into flutter widgets.
class Muncher {
  Muncher(this.context);

  final BuildContext context;
  final MunchState state = MunchState();

  Widget _munch(BuildContext context, uh.Element rootElement) {
    final widgetList = <Widget>[];
    final rowSpan = RowSpan();

    for (final node in rootElement.nodes) {
      final span = munchNode(context, node);
      if (state.br) {
        widgetList.add(rowSpan.toWidget());
        rowSpan.clear();
      } else {
        rowSpan.addSpan(span);
      }
    }
    if (rowSpan.isNotEmpty) {
      widgetList.add(rowSpan.toWidget());
    }
    return Column(children: widgetList);
  }

  InlineSpan? munchNode(BuildContext context, uh.Node? node) {
    if (node == null) {
      // Reach end.
      return null;
    }
    switch (node.nodeType) {
      // Text node does not have children.
      case uh.Node.TEXT_NODE:
        {
          return TextSpan(
            text: node.text?.trim(),
            style: Theme.of(context).textTheme.bodySmall,
          );
        }

      case uh.Node.ELEMENT_NODE:
        {
          final element = node as uh.Element;
          final localName = element.localName;
          InlineSpan? span;

          // Parse according to element types.

          // <img>
          if (localName == 'img' && node.imageUrl() != null) {
            span = WidgetSpan(child: CachedImage(node.imageUrl()!));
          }
          return span;
        }
    }
    return null;
  }
}
