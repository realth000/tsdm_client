import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/medal.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/html/adaptive_color.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/widgets/bubble.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/card/post_card/checkin.dart';
import 'package:tsdm_client/widgets/card/post_card/pokemon.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:tsdm_client/widgets/medal_group_view.dart';
import 'package:universal_html/parsing.dart';

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
  required List<Medal> medals,
  required String? badge,
  required String? secondBadge,
  required String? signature,
  required PostFloorPokemon? pokemon,
  required PostCheckinStatus? checkin,
}) async {
  await showHeroDialog<void>(
    context,
    (context, _, __) => _UserBriefProfileDialog(
      userBriefProfile,
      userSpaceUrl,
      avatarHeroTag,
      nameHeroTag,
      medals,
      badge,
      secondBadge,
      signature,
      pokemon,
      checkin,
    ),
  );
}

class _UserBriefProfileDialog extends StatefulWidget {
  const _UserBriefProfileDialog(
    this.profile,
    this.userSpaceUrl,
    this.avatarHeroTag,
    this.nameHeroTag,
    this.medals,
    this.badge,
    this.secondBadge,
    this.signature,
    this.pokemon,
    this.checkin,
  );

  final UserBriefProfile profile;

  final String userSpaceUrl;

  final String avatarHeroTag;
  final String nameHeroTag;

  /// User medals.
  final List<Medal> medals;

  /// User group title badge image url, usually presents.
  final String? badge;

  /// User group title badge image url, optional.
  final String? secondBadge;

  /// Html format user signature.
  final String? signature;

  /// Pokemon info.
  final PostFloorPokemon? pokemon;

  /// Checkin info.
  final PostCheckinStatus? checkin;

  @override
  State<_UserBriefProfileDialog> createState() => _UserBriefProfileDialogState();
}

class _UserBriefProfileDialogState extends State<_UserBriefProfileDialog> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.postCard.profileDialog;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final primaryColor = colorScheme.primary;
    final sectionTitleStyle = textTheme.titleSmall?.copyWith(color: primaryColor);
    final size = MediaQuery.sizeOf(context);
    final pokemon = widget.pokemon;
    final checkin = widget.checkin;

    const sectionSeparator = sizedBoxW24H24;
    const titleContentSeparator = sizedBoxW8H8;

    final inDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final colorOffset = inDarkTheme ? 300 : 700;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: edgeInsetsL24T24R24B24,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: math.min(size.width * 0.7, 400), maxHeight: size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: widget.avatarHeroTag,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedImageProvider(
                        widget.profile.avatarUrl ?? noAvatarUrl,
                        usage: ImageUsageInfoUserAvatar(widget.profile.username),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.email_outlined),
                    tooltip: tr.pmTooltip,
                    onPressed:
                        () => context.pushNamed(
                          ScreenPaths.chat,
                          pathParameters: {'uid': widget.profile.uid},
                          extra: <String, dynamic>{'username': widget.profile.username},
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outlined),
                    tooltip: tr.profileTooltip,
                    onPressed: () async => context.dispatchAsUrl(widget.userSpaceUrl),
                  ),
                ],
              ),
              sizedBoxW12H12,

              // Fix text style lost.
              // ref: https://github.com/flutter/flutter/issues/30647#issuecomment-480980280
              Hero(
                tag: widget.nameHeroTag,
                flightShuttleBuilder:
                    (_, __, ___, ____, toHeroContext) =>
                        DefaultTextStyle(style: DefaultTextStyle.of(toHeroContext).style, child: toHeroContext.widget),
                child: Text(widget.profile.username, style: textTheme.titleLarge?.copyWith(color: primaryColor)),
              ),
              sizedBoxW4H4,
              Text('UID ${widget.profile.uid}', style: textTheme.labelMedium?.copyWith(color: colorScheme.outline)),

              const Divider(height: 12, thickness: 1),

              // Scrollable contents.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic user info.
                      Text(tr.tabName.info, style: sectionTitleStyle),
                      titleContentSeparator,
                      _UserProfilePair(
                        Icons.group_outlined,
                        tr.group,
                        widget.profile.userGroup,
                        inDarkTheme ? widget.profile.userGroupColor?.adaptiveDark() : widget.profile.userGroupColor,
                      ),
                      if (widget.profile.title != null)
                        _UserProfilePair(
                          Icons.badge_outlined,
                          tr.title,
                          widget.profile.title,
                          Colors.blue[colorOffset],
                        ),
                      _UserProfilePair(MdiIcons.idCard, tr.nickname, widget.profile.nickname, Colors.blue[colorOffset]),
                      _UserProfilePair(
                        Icons.thumb_up_outlined,
                        tr.recommended,
                        widget.profile.recommended,
                        Colors.red[colorOffset],
                      ),
                      _UserProfilePair(
                        Icons.book_outlined,
                        tr.thread,
                        widget.profile.threadCount,
                        Colors.green[colorOffset],
                      ),
                      _UserProfilePair(
                        MdiIcons.commentEditOutline,
                        tr.post,
                        widget.profile.postCount,
                        Colors.cyan[colorOffset],
                      ),
                      _UserProfilePair(
                        Icons.emoji_people_outlined,
                        tr.famous,
                        widget.profile.famous,
                        Colors.purple[colorOffset],
                      ),
                      _UserProfilePair(
                        FontAwesomeIcons.coins,
                        tr.coins,
                        widget.profile.coins,
                        Colors.purple[colorOffset],
                      ),
                      _UserProfilePair(
                        Icons.campaign_outlined,
                        tr.publicity,
                        widget.profile.publicity,
                        Colors.purple[colorOffset],
                      ),
                      _UserProfilePair(
                        Icons.water_drop_outlined,
                        tr.natural,
                        widget.profile.natural,
                        Colors.purple[colorOffset],
                      ),
                      _UserProfilePair(
                        MdiIcons.dominoMask,
                        tr.scheming,
                        widget.profile.scheming,
                        Colors.purple[colorOffset],
                      ),
                      _UserProfilePair(
                        Icons.stream_outlined,
                        tr.spirit,
                        widget.profile.spirit,
                        Colors.purple[colorOffset],
                      ),
                      // Special attr, dynamic and not translated.
                      _UserProfilePair(
                        MdiIcons.heartOutline,
                        widget.profile.specialAttrName,
                        widget.profile.specialAttr,
                        Colors.purple[colorOffset],
                      ),
                      if (widget.profile.couple != null && widget.profile.couple!.isNotEmpty)
                        _UserProfilePair(
                          Icons.diversity_1_outlined,
                          tr.cp,
                          widget.profile.couple,
                          Colors.pink[colorOffset],
                        ),
                      _UserProfilePair(
                        Icons.feedback_outlined,
                        tr.privilege,
                        widget.profile.privilege,
                        Colors.orange[colorOffset],
                      ),
                      _UserProfilePair(
                        Icons.event_note_outlined,
                        tr.registration,
                        widget.profile.registrationDate,
                        Colors.blue[colorOffset],
                      ),
                      if (widget.profile.comeFrom != null)
                        _UserProfilePair(
                          Icons.pin_drop_outlined,
                          tr.from,
                          widget.profile.comeFrom,
                          Colors.teal[colorOffset],
                        ),
                      _UserProfilePair(
                        Icons.online_prediction_outlined,
                        tr.status.title,
                        widget.profile.online ? tr.status.online : tr.status.offline,
                        widget.profile.online ? Colors.green[colorOffset] : Colors.grey,
                      ),

                      sectionSeparator,

                      // Badge
                      Text(tr.badges, style: sectionTitleStyle),
                      titleContentSeparator,
                      // Both the primary the secondary badge presents.
                      if (widget.badge != null && widget.secondBadge != null)
                        Row(
                          children: [
                            Expanded(
                              child: CachedImage(
                                widget.badge!,
                                width: badgeImageSize.width,
                                height: badgeImageSize.height,
                              ),
                            ),
                            Expanded(
                              child: CachedImage(
                                widget.secondBadge!,
                                width: badgeImageSize.width,
                                height: badgeImageSize.height,
                              ),
                            ),
                          ],
                        )
                      // Only the primary badge.
                      else if (widget.badge != null)
                        Row(
                          children: [
                            Expanded(
                              child: CachedImage(
                                widget.badge!,
                                width: badgeImageSize.width,
                                height: badgeImageSize.height,
                              ),
                            ),
                            const Spacer(),
                          ],
                        )
                      // Only the secondary badge.
                      else if (widget.secondBadge != null)
                        Row(
                          children: [
                            Expanded(
                              child: CachedImage(
                                widget.secondBadge!,
                                width: badgeImageSize.width,
                                height: badgeImageSize.height,
                              ),
                            ),
                            const Spacer(),
                          ],
                        )
                      // No badges at all, theoretically unreachable.
                      else
                        sizedBoxEmpty,

                      sectionSeparator,

                      // Medal
                      if (widget.medals.isNotEmpty) ...[
                        Text(tr.medals, style: sectionTitleStyle),
                        titleContentSeparator,
                        MedalGroupView(widget.medals),
                        sectionSeparator,
                      ],

                      // Signature, if any. Size is unpredicted.
                      if (widget.signature != null) ...[
                        Text(tr.tabName.signature, style: sectionTitleStyle),
                        titleContentSeparator,
                        munchElement(context, parseHtmlDocument(widget.signature!).body!),
                        sectionSeparator,
                      ],

                      // Pokemon
                      if (pokemon != null) ...[
                        Text(tr.pokemon, style: sectionTitleStyle),
                        titleContentSeparator,
                        CachedImage(
                          pokemon.primaryPokemon.image,
                          width: pokemonPrimaryImageSize.width,
                          height: pokemonPrimaryImageSize.height,
                        ),
                        Text(
                          pokemon.primaryPokemon.name,
                          style: textTheme.titleSmall?.copyWith(color: colorScheme.secondary),
                        ),
                        if (pokemon.otherPokemon != null)
                          ListView(
                            padding: edgeInsetsT4,
                            shrinkWrap: true,
                            children:
                                pokemon.otherPokemon!
                                    .map(
                                      (e) => Row(
                                        children: [
                                          CachedImage(
                                            e.image,
                                            width: pokemonNotPrimaryImageSize.width,
                                            height: pokemonNotPrimaryImageSize.height,
                                          ),
                                          sizedBoxW4H4,
                                          Text(e.name),
                                        ],
                                      ),
                                    )
                                    .toList(),
                          ),
                        sectionSeparator,
                      ],

                      // Checkin status.
                      if (checkin != null) ...[
                        Text(tr.checkin, style: sectionTitleStyle),
                        titleContentSeparator,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                CachedImage(
                                  checkin.feelingImage,
                                  width: feelingImageSize.width,
                                  height: feelingImageSize.height,
                                ),
                                sizedBoxW4H4,
                                Text(
                                  checkin.feelingName,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                ),
                              ],
                            ),
                            sizedBoxW8H8,
                            Flexible(
                              child: CustomPaint(
                                painter: BubblePainter(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  alignment: Alignment.topLeft,
                                  tail: true,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                                  child: Text(
                                    checkin.words,
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        sizedBoxW4H4,
                        // Checkin statistics info.
                        Text(checkin.statistics),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfilePair extends StatelessWidget {
  const _UserProfilePair(this.iconData, this.name, this.value, this.valueColor);

  final IconData iconData;
  final String name;
  final String? value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(iconData, size: 18, color: colorScheme.secondary),
        sizedBoxW4H4,
        Text(name, style: TextStyle(color: colorScheme.secondary)),
        sizedBoxW12H12,
        Expanded(child: Text(value ?? '', style: TextStyle(color: valueColor))),
      ],
    );
  }
}
