import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/shared/models/medal.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/html/html_muncher.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image_provider.dart';
import 'package:tsdm_client/widgets/heroes.dart';
import 'package:universal_html/parsing.dart';

/// Medal size: 34 x 55.
const _medalHeight = 55.0;

/// Badge size: 186 x 85.
const _badgeHeight = 75.0;

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

  @override
  State<_UserBriefProfileDialog> createState() => _UserBriefProfileDialogState();
}

class _UserBriefProfileDialogState extends State<_UserBriefProfileDialog> with SingleTickerProviderStateMixin {
  late TabController tabController;

  Widget _buildInfoTab(BuildContext context) {
    final tr = context.t.postCard.profileDialog;

    return ListView(
      children: <Widget>[
        _UserProfilePair(
          Icons.group_outlined,
          tr.group,
          widget.profile.userGroup,
          style: _UserProfileAttrStyle.primary,
        ),
        if (widget.profile.title != null)
          _UserProfilePair(Icons.badge_outlined, tr.title, widget.profile.title, style: _UserProfileAttrStyle.primary),
        _UserProfilePair(MdiIcons.idCard, tr.nickname, widget.profile.nickname, style: _UserProfileAttrStyle.primary),
        _UserProfilePair(
          Icons.thumb_up_outlined,
          tr.recommended,
          widget.profile.recommended,
          style: _UserProfileAttrStyle.primary,
        ),
        _UserProfilePair(
          Icons.book_outlined,
          tr.thread,
          widget.profile.threadCount,
          style: _UserProfileAttrStyle.primary,
        ),
        _UserProfilePair(
          MdiIcons.commentEditOutline,
          tr.post,
          widget.profile.postCount,
          style: _UserProfileAttrStyle.primary,
        ),
        _UserProfilePair(
          Icons.emoji_people_outlined,
          tr.famous,
          widget.profile.famous,
          style: _UserProfileAttrStyle.secondary,
        ),
        _UserProfilePair(
          FontAwesomeIcons.coins,
          tr.coins,
          widget.profile.coins,
          style: _UserProfileAttrStyle.secondary,
        ),
        _UserProfilePair(
          Icons.campaign_outlined,
          tr.publicity,
          widget.profile.publicity,
          style: _UserProfileAttrStyle.secondary,
        ),
        _UserProfilePair(
          Icons.water_drop_outlined,
          tr.natural,
          widget.profile.natural,
          style: _UserProfileAttrStyle.secondary,
        ),
        _UserProfilePair(
          MdiIcons.dominoMask,
          tr.scheming,
          widget.profile.scheming,
          style: _UserProfileAttrStyle.secondary,
        ),
        _UserProfilePair(
          Icons.stream_outlined,
          tr.spirit,
          widget.profile.spirit,
          style: _UserProfileAttrStyle.secondary,
        ),
        // Special attr, dynamic and not translated.
        _UserProfilePair(
          MdiIcons.heartOutline,
          widget.profile.specialAttrName,
          widget.profile.specialAttr,
          style: _UserProfileAttrStyle.secondary,
        ),
        if (widget.profile.couple != null && widget.profile.couple!.isNotEmpty)
          _UserProfilePair(
            Icons.diversity_1_outlined,
            tr.cp,
            widget.profile.couple,
            style: _UserProfileAttrStyle.tertiary,
          ),
        _UserProfilePair(
          Icons.feedback_outlined,
          tr.privilege,
          widget.profile.privilege,
          style: _UserProfileAttrStyle.tertiary,
        ),
        _UserProfilePair(
          Icons.event_note_outlined,
          tr.registration,
          widget.profile.registrationDate,
          style: _UserProfileAttrStyle.tertiary,
        ),
        if (widget.profile.comeFrom != null)
          _UserProfilePair(
            Icons.pin_drop_outlined,
            tr.from,
            widget.profile.comeFrom,
            style: _UserProfileAttrStyle.tertiary,
          ),
        _UserProfilePair(
          Icons.online_prediction_outlined,
          tr.status.title,
          widget.profile.online ? tr.status.online : tr.status.offline,
          style: _UserProfileAttrStyle.tertiary,
        ),
      ].insertBetween(sizedBoxW4H4),
    );
  }

  Widget _buildMedalsTab(BuildContext context) {
    if (widget.medals.isEmpty) {
      return Center(
        child: Text(
          context.t.postCard.profileDialog.noMedal,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    final nameStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary);
    final descriptionStyle = Theme.of(context).textTheme.labelMedium;

    return SingleChildScrollView(
      child: Column(
        spacing: 4,
        children:
            widget.medals
                .mapIndexed(
                  (idx, e) => Row(
                    children: [
                      Text('${idx + 1}', style: nameStyle),
                      sizedBoxW8H8,
                      CachedImage(e.image, maxHeight: _medalHeight),
                      sizedBoxW8H8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [Text(e.name, style: nameStyle), Text(e.description, style: descriptionStyle)],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildSignature(BuildContext context) {
    if (widget.signature == null) {
      return Center(
        child: Text(
          context.t.postCard.profileDialog.noSig,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }
    return SingleChildScrollView(child: munchElement(context, parseHtmlDocument(widget.signature!).body!));
  }

  Widget _buildBadgeRow() {
    if (widget.badge != null && widget.secondBadge != null) {
      return Row(
        children: [
          Expanded(child: CachedImage(widget.badge!)),
          const VerticalDivider(),
          Expanded(child: CachedImage(widget.secondBadge!)),
        ],
      );
    } else if (widget.badge != null) {
      return Row(children: [Expanded(child: CachedImage(widget.badge!)), const Spacer()]);
    } else if (widget.secondBadge != null) {
      return Row(children: [Expanded(child: CachedImage(widget.secondBadge!)), const Spacer()]);
    }

    return sizedBoxEmpty;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.postCard.profileDialog;
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: edgeInsetsL24T24R24B24,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.width * 0.7, maxHeight: size.height * 0.7),
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
                    onPressed:
                        () => context.pushNamed(
                          ScreenPaths.chat,
                          pathParameters: {'uid': widget.profile.uid},
                          extra: <String, dynamic>{'username': widget.profile.username},
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outlined),
                    onPressed: () async => context.dispatchAsUrl(widget.userSpaceUrl),
                  ),
                ],
              ),
              sizedBoxW16H16,
              // Fix text style lost.
              // ref: https://github.com/flutter/flutter/issues/30647#issuecomment-480980280
              Hero(
                tag: widget.nameHeroTag,
                flightShuttleBuilder:
                    (_, __, ___, ____, toHeroContext) =>
                        DefaultTextStyle(style: DefaultTextStyle.of(toHeroContext).style, child: toHeroContext.widget),
                child: Text(widget.profile.username, style: Theme.of(context).textTheme.titleLarge),
              ),
              sizedBoxW4H4,
              Text(
                'UID ${widget.profile.uid}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              sizedBoxW4H4,
              SizedBox(height: _badgeHeight, child: _buildBadgeRow()),
              sizedBoxW4H4,
              TabBar(
                tabs: [Tab(text: tr.tabName.info), Tab(text: tr.tabName.medals), Tab(text: tr.tabName.signature)],
                controller: tabController,
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [_buildInfoTab(context), _buildMedalsTab(context), _buildSignature(context)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _UserProfileAttrStyle { primary, secondary, tertiary, normal }

class _UserProfilePair extends StatelessWidget {
  const _UserProfilePair(this.iconData, this.name, this.value, {this.style = _UserProfileAttrStyle.normal});

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
        sizedBoxW4H4,
        Text(name, style: TextStyle(color: color)),
        sizedBoxW12H12,
        Expanded(child: Text(value ?? '', style: TextStyle(color: color))),
      ],
    );
  }
}
