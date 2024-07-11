import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/user_brief_profile.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';

/// Show a dialog to display user brief profile.
///
/// Data only available in thread page on all replied users.
Future<void> showUserBriefProfileDialog(
  BuildContext context,
  UserBriefProfile userBriefProfile,
  String userSpaceUrl, {
  // Hero tag for user avatar.
  required String avatarHeroTag,
  // Hero tag for user name.
  required String nameHeroTag,
}) async {
  await Navigator.push<void>(
    context,
    PageRouteBuilder(
      opaque: false,
      // Fix barrier color.
      // ref: flutter/lib/src/material/dialog.dart: showDialog()
      barrierColor:
          Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
      barrierDismissible: true,
      pageBuilder: (context, _, __) => _UserBriefProfileDialog(
        userBriefProfile,
        userSpaceUrl,
        avatarHeroTag,
        nameHeroTag,
      ),
      // fullscreenDialog: true,
      transitionsBuilder: (context, ani1, ani2, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeIn).animate(ani1),
          child: child,
        );
      },
    ),
  );
}

class _UserBriefProfileDialog extends StatelessWidget {
  const _UserBriefProfileDialog(
    this.profile,
    this.userSpaceUrl,
    this.avatarHeroTag,
    this.nameHeroTag,
  );

  final UserBriefProfile profile;

  final String userSpaceUrl;

  final String avatarHeroTag;
  final String nameHeroTag;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.postCard.profileDialog;

    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: avatarHeroTag,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedImageProvider(
                    profile.avatarUrl ?? noAvatarUrl,
                    context,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.email_outlined),
                onPressed: () => context.pushNamed(
                  ScreenPaths.chat,
                  pathParameters: {
                    'uid': profile.uid,
                  },
                  extra: <String, dynamic>{
                    'username': profile.username,
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () async => context.dispatchAsUrl(userSpaceUrl),
              ),
            ],
          ),
          sizedBoxW15H15,
          // Fix text style lost.
          // ref: https://github.com/flutter/flutter/issues/30647#issuecomment-480980280
          Hero(
            tag: nameHeroTag,
            flightShuttleBuilder: (_, __, ___, ____, toHeroContext) =>
                DefaultTextStyle(
              style: DefaultTextStyle.of(toHeroContext).style,
              child: toHeroContext.widget,
            ),
            child: Text(
              profile.username,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          sizedBoxW5H5,
          Text(
            'UID ${profile.uid}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _UserProfilePair(
                Icons.group_outlined,
                tr.group,
                profile.userGroup,
                style: _UserProfileAttrStyle.primary,
              ),
              if (profile.title != null)
                _UserProfilePair(
                  Icons.badge_outlined,
                  tr.title,
                  profile.title,
                  style: _UserProfileAttrStyle.primary,
                ),
              _UserProfilePair(
                MdiIcons.idCard,
                tr.nickname,
                profile.nickname,
                style: _UserProfileAttrStyle.primary,
              ),
              _UserProfilePair(
                Icons.thumb_up_outlined,
                tr.recommended,
                profile.recommended,
                style: _UserProfileAttrStyle.primary,
              ),
              _UserProfilePair(
                Icons.book_outlined,
                tr.thread,
                profile.threadCount,
                style: _UserProfileAttrStyle.primary,
              ),
              _UserProfilePair(
                MdiIcons.commentEditOutline,
                tr.post,
                profile.postCount,
                style: _UserProfileAttrStyle.primary,
              ),
              _UserProfilePair(
                Icons.emoji_people_outlined,
                tr.famous,
                profile.famous,
                style: _UserProfileAttrStyle.secondary,
              ),
              _UserProfilePair(
                FontAwesomeIcons.coins,
                tr.coins,
                profile.coins,
                style: _UserProfileAttrStyle.secondary,
              ),
              _UserProfilePair(
                Icons.campaign_outlined,
                tr.publicity,
                profile.publicity,
                style: _UserProfileAttrStyle.secondary,
              ),
              _UserProfilePair(
                Icons.water_drop_outlined,
                tr.natural,
                profile.natural,
                style: _UserProfileAttrStyle.secondary,
              ),
              _UserProfilePair(
                MdiIcons.dominoMask,
                tr.scheming,
                profile.natural,
                style: _UserProfileAttrStyle.secondary,
              ),
              _UserProfilePair(
                Icons.stream_outlined,
                tr.spirit,
                profile.spirit,
                style: _UserProfileAttrStyle.secondary,
              ),
              // Special attr, dynamic and not translated.
              _UserProfilePair(
                MdiIcons.heartOutline,
                profile.specialAttrName,
                profile.specialAttr,
                style: _UserProfileAttrStyle.secondary,
              ),
              if (profile.couple != null && profile.couple!.isNotEmpty)
                _UserProfilePair(
                  Icons.diversity_1_outlined,
                  tr.cp,
                  profile.couple,
                  style: _UserProfileAttrStyle.tertiary,
                ),
              _UserProfilePair(
                Icons.feedback_outlined,
                tr.privilege,
                profile.privilege,
                style: _UserProfileAttrStyle.tertiary,
              ),
              _UserProfilePair(
                Icons.event_note_outlined,
                tr.registration,
                profile.registrationDate,
                style: _UserProfileAttrStyle.tertiary,
              ),
              if (profile.comeFrom != null)
                _UserProfilePair(
                  Icons.pin_drop_outlined,
                  tr.from,
                  profile.comeFrom,
                  style: _UserProfileAttrStyle.tertiary,
                ),
              _UserProfilePair(
                Icons.online_prediction_outlined,
                tr.status.title,
                profile.online ? tr.status.online : tr.status.offline,
                style: _UserProfileAttrStyle.tertiary,
              ),
            ].insertBetween(sizedBoxW5H5),
          ),
        ),
      ),
    );
  }
}

enum _UserProfileAttrStyle {
  primary,
  secondary,
  tertiary,
  normal,
}

class _UserProfilePair extends StatelessWidget {
  const _UserProfilePair(
    this.iconData,
    this.name,
    this.value, {
    this.style = _UserProfileAttrStyle.normal,
  });

  final IconData iconData;
  final String name;
  final String? value;
  final _UserProfileAttrStyle style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (style) {
      _UserProfileAttrStyle.primary => colorScheme.primary,
      _UserProfileAttrStyle.secondary => colorScheme.secondary,
      _UserProfileAttrStyle.tertiary => colorScheme.tertiary,
      _UserProfileAttrStyle.normal => null,
    };

    return Row(
      children: [
        Icon(iconData, size: 18, color: color),
        sizedBoxW5H5,
        Text(name, style: TextStyle(color: color)),
        sizedBoxW10H10,
        Expanded(child: Text(value ?? '', style: TextStyle(color: color))),
      ],
    );
  }
}
