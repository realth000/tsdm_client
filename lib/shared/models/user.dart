// TODO: Construct from html node.
import 'package:equatable/equatable.dart';

/// Author of a thread.
///
/// Contains name and user page url.
class User extends Equatable {
  /// Freezed constructor.
  const User({
    required this.name,
    required this.url,
    this.uid,
    this.avatarUrl,
  });

  /// User name.
  final String name;

  /// User homepage url.
  final String url;

  /// User id.
  ///
  /// For somewhere we can not get user id, this can not be "required".
  final String? uid;

  /// User avatar, may be null.
  final String? avatarUrl;

  // bool isValid() {
  //   if (name.isEmpty || url.isEmpty) {
  //     return false;
  //   }
  //   return true;
  // }

  // bool isNotValid() => !isValid();

  @override
  String toString() {
    return 'User{ $name, $url, $uid, $avatarUrl }';
  }

  @override
  List<Object?> get props => [name, url, uid, avatarUrl];
}
