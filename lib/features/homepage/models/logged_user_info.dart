import 'package:equatable/equatable.dart';

/// Info of the logged user in homepage.
///
/// * Maybe have a logged user.
/// * The logged user may have an avatar url or not, depending on the theme of
///   website.
final class LoggedUserInfo extends Equatable {
  const LoggedUserInfo({
    required this.username,
    required this.relatedLinkPairList,
    this.avatarUrl,
  });

  /// User name.
  final String username;

  /// Related links.
  final List<(String title, String url)> relatedLinkPairList;

  /// Optional user avatar url, depending on the theme used in website.
  final String? avatarUrl;

  @override
  List<Object?> get props => [username, relatedLinkPairList, avatarUrl];
}
