import 'package:dart_mappable/dart_mappable.dart';

part '../../../generated/widgets/card/thread_card/thread_card_config.mapper.dart';

/// Layout configuration.
@MappableClass()
final class ThreadCardConfiguration with ThreadCardConfigurationMappable {
  /// Constructor.
  const ThreadCardConfiguration({
    this.infoRowAlignCenter = true,
    this.showLastReplyAuthor = false,
  });

  /// Layout style of the card.
  final bool infoRowAlignCenter;

  /// Show the name of last reply author.
  final bool showLastReplyAuthor;
}
