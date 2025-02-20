part of 'models.dart';

/// Platforms mark.
@MappableEnum()
enum Platform {
  /// Web mobile UI.
  mobileWeb(-1),

  /// default.
  unknown(0),

  /// Android client.
  android(1),

  /// IOS client.
  ios(2);

  const Platform(this.code);

  /// Code name of the platform.
  final int code;
}

/// Mapper on [Platform] for dart_mappable.
final class _PlatformMapper extends SimpleMapper<Platform> with LoggerMixin {
  const _PlatformMapper();

  @override
  Platform decode(Object value) {
    if (value is! int) {
      return Platform.unknown;
    }

    return Platform.values.firstWhereOrNull((v) => v.code == value) ?? Platform.unknown;
  }

  @override
  Object? encode(Platform self) {
    return self.code;
  }
}

/// Post model v2.
///
/// Each instance represents a floor in thread which called a post.
@MappableClass(includeCustomMappers: [_PlatformMapper(), _ScoreMapMapper()])
final class PostV2 with PostV2Mappable {
  /// Constructor.
  const PostV2({
    required this.id,
    required this.author,
    required this.authorId,
    required this.authorTitle,
    required this.authorGid,
    required this.authorNickname,
    required this.avatar,
    required this.timestamp,
    required this.title,
    required this.body,
    required this.first,
    required this.floor,
    required this.platform,
    required this.rateList,
    required this.totalRate,
  });

  /// Post ID.
  @MappableField(key: 'pid')
  final String id;

  /// Author name.
  @MappableField(key: 'author')
  final String author;

  /// Author user id.
  @MappableField(key: 'authorid')
  final String authorId;

  /// Author title.
  ///
  /// 头衔
  ///
  /// HTML text.
  @MappableField(key: 'authortitle')
  final String authorTitle;

  /// Author group id.
  @MappableField(key: 'authorgid')
  final String authorGid;

  /// Author nickname.
  @MappableField(key: 'author_nickname')
  final String authorNickname;

  /// Author avatar url.
  final String avatar;

  /// Timestamp in seconds.
  final String timestamp;

  /// Optional title of the post.
  ///
  /// Only not null with the first floor.
  @MappableField(key: 'subject')
  final String? title;

  /// Post body data.
  ///
  /// HTML text.
  @MappableField(key: 'message')
  final String body;

  /// Is first floor or not.
  final String first;

  /// Floor number.
  final int floor;

  /// Platform the user is using.
  final Platform platform;

  /// All rate history.
  @MappableField(key: 'ratelog')
  final List<SingleRateV2> rateList;

  /// Total rate statistics.
  @MappableField(key: 'ratelogextcredits')
  final ScoreMap totalRate;
}
