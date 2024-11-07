import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';

part 'munch_options.mapper.dart';

/// All available options that controls and changes the behavior when munching
/// html document.
@MappableClass()
final class MunchOptions with MunchOptionsMappable {
  /// Constructor.
  const MunchOptions({
    this.renderUrl = true,
    this.onUrlLaunched,
  });

  /// Render <a> tags when munching html document.
  ///
  /// Disable this flag will not render url highlight or any other url
  /// specified contents, only render as plain text, no url launching when tap,
  /// neither.
  ///
  /// Default is true.
  final bool renderUrl;

  /// Callback on url launched.
  final VoidCallback? onUrlLaunched;
}
