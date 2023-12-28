import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

part '../generated/providers/upgrade_provider.g.dart';

/// State of upgrade action.
enum UpgradeState {
  /// Now stopped.
  stopped,

  /// Fetching latest version info.
  fetching,

  /// Downloading the latest application.
  downloading,
}

@immutable
class UpgradeModel {
  const UpgradeModel({
    required this.releaseVersion,
    required this.releaseNotes,
    required this.assetsMap,
    required this.releaseUrl,
  });

  final String releaseVersion;
  final String releaseNotes;
  final Map<String, String> assetsMap;
  final String releaseUrl;
}

@Riverpod(dependencies: [NetClient])
class Upgrade extends _$Upgrade {
  static const _githubReleaseInfoUrl =
      'https://github.com/realth000/tsdm_client/releases/latest';
  static const _githubReleaseAssetUrl =
      'https://github.com/realth000/tsdm_client/releases/expanded_assets/';

  UpgradeModel? _upgradeModel;

  @override
  UpgradeState build() {
    return UpgradeState.stopped;
  }

  /// Fetch the latest version info from github.
  Future<UpgradeModel?> fetchLatestInfo() async {
    state = UpgradeState.fetching;
    final resp = await ref
        .read(NetClientProvider(disableCookie: true))
        .get(_githubReleaseInfoUrl);
    if (resp.statusCode != HttpStatus.ok) {
      state = UpgradeState.stopped;
      return Future.error('${resp.statusCode}');
    }

    final document = parseHtmlDocument(resp.data as String);
    final model = await _parseUpgradeModel(document);
    if (model == null) {
      return null;
    }
    state = UpgradeState.stopped;
    _upgradeModel = model;
    return model;
  }

  UpgradeModel? latestVersion() {
    return _upgradeModel;
  }

  Future<UpgradeModel?> _parseUpgradeModel(uh.Document document) async {
    final originalTitle =
        document.querySelector('h1.d-inline.mr-3')?.firstEndDeepText();
    final releaseVersion = originalTitle?.replaceFirst('v', '');
    final releaseNotes =
        document.querySelector('div.markdown-body.my-3')?.outerHtml;
    if (releaseVersion == null || releaseNotes == null) {
      return null;
    }

    // The assets info is not in the previous release page.
    final resp = await ref
        .read(NetClientProvider(disableCookie: true))
        .get('$_githubReleaseAssetUrl/$originalTitle');
    if (resp.statusCode != HttpStatus.ok) {
      debug('bad assets request status: ${resp.statusCode}');
      return null;
    }
    final assetsDocument = parseHtmlDocument(resp.data as String);
    final assetsEntries =
        assetsDocument.querySelectorAll('a.Truncate').map((e) {
      final link = e.attributes['href']?.prepend('https://github.com');
      final name = e.querySelector('span')?.firstEndDeepText();
      if (link == null || name == null || name == 'Source code') {
        return null;
      }
      return MapEntry(name, link);
    }).whereType<MapEntry<String, String>>();
    final assetsMap = Map<String, String>.fromEntries(assetsEntries);
    return UpgradeModel(
      releaseVersion: releaseVersion,
      releaseNotes: releaseNotes,
      assetsMap: assetsMap,
      releaseUrl: _githubReleaseInfoUrl,
    );
  }
}
