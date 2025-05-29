import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/features/update/cubit/update_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/widgets/tips.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page for app update.
class UpdatePage extends StatefulWidget {
  /// Constructor.
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    final tr = context.t.updatePage;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.title),
        actions: [
          BlocSelector<UpdateCubit, UpdateCubitState, bool>(
            selector: (state) => state.loading,
            builder: (context, state) => IconButton(
              icon: state ? sizedCircularProgressIndicator : const Icon(Icons.refresh_outlined),
              tooltip: tr.checkLatest,
              onPressed: state ? null : () async => context.read<UpdateCubit>().checkUpdate(),
            ),
          ),
        ],
        bottom: Tips(tr.fDroidTip, sizePreferred: true),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: Text(tr.announcementThread),
            onTap: () async => context.dispatchAsUrl('forum.php?mod=viewthread&tid=628244'),
          ),
          ListTile(
            leading: Icon(MdiIcons.github),
            title: const Text('GitHub'),
            onTap: () async => launchUrl(Uri.parse(upgradeGithubReleaseUrl), mode: LaunchMode.externalApplication),
          ),
          ListTile(
            leading: SvgPicture.asset(assetsFDroidLogoPath, width: 22, height: 22),
            title: const Text('F-Droid'),
            onTap: () async => launchUrl(Uri.parse(upgradeFDroidHomepageUrl), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
    );
  }
}
