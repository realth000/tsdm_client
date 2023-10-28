import 'package:collection/collection.dart';
import 'package:universal_html/html.dart';

/// Extension for [Element] type to access children.
extension AccessExtension on Element {
  /// Get the child at [index] in [children], return null if not exist.
  Element? childAtOrNull(int index) => children.elementAtOrNull(index);

  String innerHtmlEx() => innerHtml ?? '';
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

  bool _traverseIf(
    Element? element,
    Element root,
    bool Function(Element element) work,
  ) {
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
  /// If any of key or value is null, return null.
  (String key, String value)? parseLiEmNode() {
    if (childAtOrNull(0)?.localName != 'em') {
      return null;
    }

    final key = childAtOrNull(0)?.text?.trim();
    late final String? value;
    if (children.length > 1) {
      // The value here is not a plain text, it's a normal node.
      // TODO: If we have a normal node value, parse it's link, img even styles.
      value = childAtOrNull(1)?.firstEndDeepText();
    } else {
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
    return attributes['data-original'] ?? attributes['src'] ?? '';
  }

  String? imageUrl() {
    return attributes['data-original'] ??
        attributes['src'] ??
        attributes['file'];
  }
}
