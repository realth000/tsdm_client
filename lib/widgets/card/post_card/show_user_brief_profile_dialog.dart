import 'dart:math' as math;

import 'package:collection/collection.dart';
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
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/card/post_card/checkin.dart';
import 'package:tsdm_client/widgets/card/post_card/pokemon.dart';
import 'package:tsdm_client/widgets/heroes.dart';
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
    final nameStyle = textTheme.bodyMedium?.copyWith();
    final descriptionStyle = textTheme.labelSmall;
    final size = MediaQuery.sizeOf(context);
    final emptyStyle = textTheme.bodyLarge?.copyWith(color: colorScheme.outline);
    final pokemon = widget.pokemon;
    final checkin = widget.checkin;
    const emptyContentTipHeight = 40.0;

    const sectionSeparator = sizedBoxW24H24;
    const titleContentSeparator = sizedBoxW8H8;

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
                      _UserProfilePair(Icons.group_outlined, tr.group, widget.profile.userGroup),
                      if (widget.profile.title != null)
                        _UserProfilePair(Icons.badge_outlined, tr.title, widget.profile.title),
                      _UserProfilePair(MdiIcons.idCard, tr.nickname, widget.profile.nickname),
                      _UserProfilePair(Icons.thumb_up_outlined, tr.recommended, widget.profile.recommended),
                      _UserProfilePair(Icons.book_outlined, tr.thread, widget.profile.threadCount),
                      _UserProfilePair(MdiIcons.commentEditOutline, tr.post, widget.profile.postCount),
                      _UserProfilePair(Icons.emoji_people_outlined, tr.famous, widget.profile.famous),
                      _UserProfilePair(FontAwesomeIcons.coins, tr.coins, widget.profile.coins),
                      _UserProfilePair(Icons.campaign_outlined, tr.publicity, widget.profile.publicity),
                      _UserProfilePair(Icons.water_drop_outlined, tr.natural, widget.profile.natural),
                      _UserProfilePair(MdiIcons.dominoMask, tr.scheming, widget.profile.scheming),
                      _UserProfilePair(Icons.stream_outlined, tr.spirit, widget.profile.spirit),
                      // Special attr, dynamic and not translated.
                      _UserProfilePair(
                        MdiIcons.heartOutline,
                        widget.profile.specialAttrName,
                        widget.profile.specialAttr,
                      ),
                      if (widget.profile.couple != null && widget.profile.couple!.isNotEmpty)
                        _UserProfilePair(Icons.diversity_1_outlined, tr.cp, widget.profile.couple),
                      _UserProfilePair(Icons.feedback_outlined, tr.privilege, widget.profile.privilege),
                      _UserProfilePair(Icons.event_note_outlined, tr.registration, widget.profile.registrationDate),
                      if (widget.profile.comeFrom != null)
                        _UserProfilePair(Icons.pin_drop_outlined, tr.from, widget.profile.comeFrom),
                      _UserProfilePair(
                        Icons.online_prediction_outlined,
                        tr.status.title,
                        widget.profile.online ? tr.status.online : tr.status.offline,
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
                      Text(tr.medals, style: sectionTitleStyle),
                      titleContentSeparator,
                      if (widget.medals.isEmpty)
                        Center(
                          child: SizedBox(
                            height: emptyContentTipHeight,
                            child: Text(
                              context.t.postCard.profileDialog.noMedal,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                        )
                      else
                        ...widget.medals.mapIndexed(
                          (idx, e) => Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: Text(
                                  '${idx + 1}'.padLeft(2),
                                  style: nameStyle?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                ),
                              ),
                              sizedBoxW8H8,
                              CachedImage(e.image, width: medalImageSize.width, height: medalImageSize.height),
                              sizedBoxW8H8,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(e.name, style: nameStyle),
                                    Text(e.description, style: descriptionStyle),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      sectionSeparator,

                      // Signature, if any. Size is unpredicted.
                      Text(tr.tabName.signature, style: sectionTitleStyle),
                      titleContentSeparator,
                      if (widget.signature == null)
                        Center(
                          child: SizedBox(
                            height: emptyContentTipHeight,
                            child: Text(
                              context.t.postCard.profileDialog.noSig,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                        )
                      else
                        munchElement(context, parseHtmlDocument(widget.signature!).body!),

                      sectionSeparator,

                      // Pokemon
                      Text(tr.pokemon, style: sectionTitleStyle),
                      titleContentSeparator,
                      if (pokemon == null)
                        Center(
                          child: SizedBox(height: emptyContentTipHeight, child: Text(tr.noPokemon, style: emptyStyle)),
                        )
                      else ...[
                        CachedImage(
                          pokemon.primaryPokemon.image,
                          width: pokemonPrimaryImageSize.width,
                          height: pokemonPrimaryImageSize.height,
                        ),
                        Text(
                          pokemon.primaryPokemon.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
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
                      ],

                      sectionSeparator,

                      // Checkin status.
                      Text(tr.checkin, style: sectionTitleStyle),
                      titleContentSeparator,
                      if (checkin == null)
                        Center(
                          child: SizedBox(height: emptyContentTipHeight, child: Text(tr.noCheckin, style: emptyStyle)),
                        )
                      else ...[
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
                            CustomPaint(
                              painter: _SpecialChatBubbleThree(
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                alignment: Alignment.topLeft,
                                tail: true,
                              ),
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(14, 7, 7, 7),
                                child: Text(
                                  checkin.words,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
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
  const _UserProfilePair(this.iconData, this.name, this.value);

  final IconData iconData;
  final String name;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(iconData, size: 18, color: colorScheme.secondary),
        sizedBoxW4H4,
        Text(name, style: TextStyle(color: colorScheme.secondary)),
        sizedBoxW12H12,
        Expanded(child: Text(value ?? '')),
      ],
    );
  }
}

//custom painter use to create the shape of the chat bubble
///
/// [color],[alignment] and [tail] can be changed

class _SpecialChatBubbleThree extends CustomPainter {
  const _SpecialChatBubbleThree({required this.color, required this.alignment, required this.tail});

  final Color color;
  final Alignment alignment;
  final bool tail;

  static const double _radius = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    if (alignment == Alignment.topRight) {
      if (tail) {
        final path =
            Path()
              /// starting point
              ..moveTo(_radius * 2, 0)
              /// top-left corner
              ..quadraticBezierTo(0, 0, 0, _radius * 1.5)
              /// left line
              ..lineTo(0, h - _radius * 1.5)
              /// bottom-left corner
              ..quadraticBezierTo(0, h, _radius * 2, h)
              /// bottom line
              ..lineTo(w - _radius * 3, h)
              /// bottom-right bubble curve
              ..quadraticBezierTo(w - _radius * 1.5, h, w - _radius * 1.5, h - _radius * 0.6)
              /// bottom-right tail curve 1
              ..quadraticBezierTo(w - _radius * 1, h, w, h)
              /// bottom-right tail curve 2
              ..quadraticBezierTo(w - _radius * 0.8, h, w - _radius, h - _radius * 1.5)
              /// right line
              ..lineTo(w - _radius, _radius * 1.5)
              /// top-right curve
              ..quadraticBezierTo(w - _radius, 0, w - _radius * 3, 0);

        canvas
          ..clipPath(path)
          ..drawRRect(
            RRect.fromLTRBR(0, 0, w, h, Radius.zero),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );
      } else {
        final path =
            Path()
              /// starting point
              ..moveTo(_radius * 2, 0)
              /// top-left corner
              ..quadraticBezierTo(0, 0, 0, _radius * 1.5)
              /// left line
              ..lineTo(0, h - _radius * 1.5)
              /// bottom-left corner
              ..quadraticBezierTo(0, h, _radius * 2, h)
              /// bottom line
              ..lineTo(w - _radius * 3, h)
              /// bottom-right curve
              ..quadraticBezierTo(w - _radius, h, w - _radius, h - _radius * 1.5)
              /// right line
              ..lineTo(w - _radius, _radius * 1.5)
              /// top-right curve
              ..quadraticBezierTo(w - _radius, 0, w - _radius * 3, 0);

        canvas
          ..clipPath(path)
          ..drawRRect(
            RRect.fromLTRBR(0, 0, w, h, Radius.zero),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );
      }
    } else {
      if (tail) {
        final path =
            Path()
              /// starting point
              ..moveTo(_radius * 3, 0)
              /// top-left corner
              ..quadraticBezierTo(_radius, 0, _radius, _radius * 1.5)
              /// left line
              ..lineTo(_radius, h - _radius * 1.5)
              // bottom-right tail curve 1
              ..quadraticBezierTo(_radius * .8, h, 0, h)
              /// bottom-right tail curve 2
              ..quadraticBezierTo(_radius * 1, h, _radius * 1.5, h - _radius * 0.6)
              /// bottom-left bubble curve
              ..quadraticBezierTo(_radius * 1.5, h, _radius * 3, h)
              /// bottom line
              ..lineTo(w - _radius * 2, h)
              /// bottom-right curve
              ..quadraticBezierTo(w, h, w, h - _radius * 1.5)
              /// right line
              ..lineTo(w, _radius * 1.5)
              /// top-right curve
              ..quadraticBezierTo(w, 0, w - _radius * 2, 0);
        canvas
          ..clipPath(path)
          ..drawRRect(
            RRect.fromLTRBR(0, 0, w, h, Radius.zero),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );
      } else {
        final path =
            Path()
              /// starting point
              ..moveTo(_radius * 3, 0)
              /// top-left corner
              ..quadraticBezierTo(_radius, 0, _radius, _radius * 1.5)
              /// left line
              ..lineTo(_radius, h - _radius * 1.5)
              /// bottom-left curve
              ..quadraticBezierTo(_radius, h, _radius * 3, h)
              /// bottom line
              ..lineTo(w - _radius * 2, h)
              /// bottom-right curve
              ..quadraticBezierTo(w, h, w, h - _radius * 1.5)
              /// right line
              ..lineTo(w, _radius * 1.5)
              /// top-right curve
              ..quadraticBezierTo(w, 0, w - _radius * 2, 0);

        canvas
          ..clipPath(path)
          ..drawRRect(
            RRect.fromLTRBR(0, 0, w, h, Radius.zero),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
