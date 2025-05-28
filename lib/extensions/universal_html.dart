import 'dart:math';

import 'package:collection/collection.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:universal_html/html.dart';

/// Extension on [Document] that provides methods to grep specified elements
/// and contents inside [Document].
extension GrepDocumentExtension on Document {
  /// Parse the current page number of current document.
  int? currentPage() {
    // Should call on "this" implicitly.
    return this.querySelector('div.pg > strong')?.firstEndDeepText()?.parseToInt();
  }

  /// Parse the total pages count in current document.
  int? totalPages() {
    // Should call on "this" implicitly.
    final paginateNode = this.querySelector('div.pg');
    var currentPage = 1;
    var ret = 1;
    if (paginateNode == null) {
      return ret;
    }
    currentPage = paginateNode.querySelector('strong')?.firstEndDeepText()?.parseToInt() ?? 1;

    final lastNode = paginateNode.children.lastOrNull;
    final skippedLastNode = paginateNode.querySelector('a.last');
    if (lastNode != null && lastNode.nodeType == Node.ELEMENT_NODE && lastNode.localName == 'strong') {
      // Already in the last page.
      ret = currentPage;
    } else if (skippedLastNode != null) {
      // 1, 2, .. 100
      //           |---- Skipped to the last page
      // Fall back to 1 if parse int failed.
      ret = skippedLastNode.firstEndDeepText()?.substring(4).parseToInt() ?? 1;
    } else {
      ret = paginateNode
          .querySelectorAll('a')
          .where((e) => e.classes.isEmpty)
          .map((e) => (e.firstEndDeepText() ?? '0').parseToInt())
          .whereType<int>()
          .toList()
          .reduce(max<int>);
    }
    return ret;
  }
}

/// Extension for [Element] type to access children.
extension AccessExtension on Element {
  /// Get the child at [index] in [children], return null if not exist.
  Element? childAtOrNull(int index) => children.elementAtOrNull(index);

  /// Return the inner html string.
  ///
  /// Return empty string if unavailable.
  String innerHtmlEx() => innerHtml ?? '';

  /// Like [querySelectorAll] but only select start with current element,
  /// as having a '^' in regular expression:
  ///
  /// this.querySelectorAll('^selector').
  ElementList<Element> querySelectorRootAll(String selector) {
    final mark = 'z${DateTime.now().millisecondsSinceEpoch}';
    attributes[mark] = mark;
    final result = this.querySelectorAll('$tagName[$mark="$mark"] > $selector');
    attributes.remove(mark);
    return result;
  }
}

/// Grep extension for [Element] type.
extension GrepExtension on Element {
  /// Search the first value of attr "href" in pre-order use [Element] element
  /// as root node.
  /// * Search in first child and next siblings when next is true.
  /// * Search in previous siblings and parent when next is false.
  /// If not found, return null;
  ///
  /// <a>
  ///   <a href="0.com"></a>
  ///   <a>
  ///     <a href="1.com"></a>
  ///->   <a>
  ///       <a href="2.com"></a>
  ///     </a>
  ///     <a href="3.com"></a>
  ///   </a>
  /// </a>
  ///
  /// When start with the arrow pointed <a>:
  String? firstHref() {
    String? ret;
    bool work(Element element) {
      if (element.attributes.containsKey('href')) {
        ret = element.attributes['href'];
        return true;
      } else {
        return false;
      }
    }

    return _traverseIf(this, this, work) ? ret : null;
  }

  bool _traverseIf(Element? element, Element root, bool Function(Element element) work) {
    if (element == null) {
      return true;
    }
    if (work(element)) {
      return true;
    }
    if (element.hasChildNodes()) {
      return _traverseIf(element.childAtOrNull(0), root, work);
    } else if (element.nextElementSibling != null) {
      return _traverseIf(element.nextElementSibling, root, work);
    }
    // Go upward.
    var e = element.parent;
    while (e != root) {
      if (e!.nextElementSibling != null) {
        return _traverseIf(e.nextElementSibling, root, work);
      } else {
        e = e.parent;
      }
    }
    return true;
  }

  /// Find the deepest text, looks like in-order or post-order traversal but
  /// stops when reach the leaf child.
  /// <a>
  ///   <a>
  ///     <a>
  ///       "1"
  ///     </a>
  ///     <a>
  ///       <a>
  ///         "2"
  ///       </a>
  ///       "3"
  ///     </a>
  /// </a>
  /// Return "1".
  String? firstEndDeepText() {
    var e = this;
    var ch = e.children;
    while (ch.isNotEmpty) {
      e = ch.first;
      ch = e.children;
    }
    return e.text;
  }

  /// Parsing a li type node which contains an em node and extra text in it,
  /// returns as a key value pair.
  ///
  /// <li>
  ///   <em>here_is_key</em>
  ///   here_is_value
  /// </li>
  ///
  /// Note: Both key and value will be trimmed, which means removed white spaces
  /// around themselves.
  ///
  /// Note: Returns the html code if value is an or more Element not text node.
  ///
  /// If any of key or value is null, return null.
  ///
  /// Set [second] to true to force retrieve the second node (text) as value.
  (String key, String value)? parseLiEmNode({bool second = false}) {
    if (children.elementAtOrNull(0)?.localName != 'em') {
      return null;
    }

    final key = children.elementAtOrNull(0)?.text?.trim();
    final String? value;
    if (second) {
      value = nodes.elementAtOrNull(1)?.text;
    } else if (children.length >= 2 && !second) {
      // More than one element.
      // Try remove the first <em> element and return all html code left.
      value = nodes
          .skip(1)
          .map(
            (e) => switch (e.nodeType) {
              Node.ELEMENT_NODE => (e as Element).outerHtml,
              Node.TEXT_NODE => e.text,
              _ => '',
            },
          )
          .join();
    } else {
      // Expected value is a text node.
      // Use the trimmed text
      value = nodes.lastOrNull?.text?.trim();
    }
    if (key == null || value == null) {
      return null;
    }
    if (key.isEmpty || value.isEmpty) {
      return null;
    }
    return (key, value);
  }

  /// Return the img url in [Element]'s attribute.
  ///
  /// Priority: data-original > src.
  /// If not found, return null.
  String? dataOriginalOrSrcImgUrl() {
    return attributes['data-original'] ?? attributes['src'];
  }

  /// Return the image url in attributes in current node.
  ///
  /// There is a priority difference between different node attributes.
  ///
  /// zoomfile > data-original > src > file.
  ///
  /// Return null if no available image url found.
  String? imageUrl() {
    final str =
        attributes['zoomfile']?.prependHost() ?? attributes['data-original'] ?? attributes['src'] ?? attributes['file'];

    if (str == null) {
      return null;
    }
    if (str.startsWith('http')) {
      return str;
    }
    return '$baseUrl/$str';
  }

  /// Parse data in a table row, return the first header <th> and all data <td>.
  ///
  /// <tr>
  ///   <th>table_header</th>
  ///   <td>data1<td>
  ///   <td>data2<td>
  ///   <td>data3<td>
  /// </tr>
  (String? title, List<String> data) parseTableRow() {
    String? title;
    final data = <String>[];
    for (final node in nodes) {
      if (node.nodeType != Node.ELEMENT_NODE) {
        continue;
      }

      final e = node as Element;
      if (e.localName == 'th' && title == null) {
        title = e.text;
        continue;
      }

      if (e.localName == 'td' && e.text != null) {
        data.add(e.text!);
      }
    }
    return (title, data);
  }

  /// Parse the datetime on current node or first child.
  ///
  /// From current node `<span>`'s title attribute or first child (usually
  /// a span, too)  's title attribute.
  DateTime? dateTime() {
    if (tagName != 'SPAN') {
      return null;
    }
    if (classes.contains('xg1')) {
      final text1 = innerText.parseToDateTimeUtc8();
      if (text1 != null) {
        return text1;
      }
    }
    return children.firstOrNull?.attributes['title']?.parseToDateTimeUtc8();
  }
}
