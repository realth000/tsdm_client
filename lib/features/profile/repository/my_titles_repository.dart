import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/profile/models/secondary_title.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/parsing.dart';

/// The repository for user titles.
final class MyTitlesRepository {
  /// Fetch all available secondary titles for current user.
  AsyncEither<List<SecondaryTitle>> fetchSecondaryTitles() => getIt
      .get<NetClientProvider>()
      .get('$baseUrl/plugin.php?id=tsdmtitle:tsdmtitle')
      .mapHttp((v) => parseHtmlDocument(v.data as String))
      .map((doc) {
        final allAvailableTitles = doc
            .querySelectorAll('div#ct_shell > div > table:nth-child(2) > tbody > tr')
            .skip(1) // Skip table header.
            .map(SecondaryTitle.fromTr)
            .whereType<SecondaryTitle>()
            .toList();
        final currentTitleId = doc
            .querySelector('div#ct_shell > div > table:nth-child(3) > tbody > tr:nth-child(2) > td')
            ?.innerText
            .parseToInt();
        final idx = allAvailableTitles.indexWhere((v) => v.id == currentTitleId);
        if (idx >= 0) {
          allAvailableTitles[idx] = allAvailableTitles[idx].copyWith(activated: true);
        }
        return allAvailableTitles;
      });

  /// Switch to the secondary title specified by [id].
  AsyncVoidEither setSecondaryTitle(int id) => getIt.get<NetClientProvider>().get(
    '$baseUrl/plugin.php?id=tsdmtitle:tsdmtitle&action=setTitle&setTitleId=$id',
  );

  /// Unset user specified secondary title, set to default one.
  AsyncVoidEither unsetSecondaryTitle() => getIt.get<NetClientProvider>().get(
    '$baseUrl/plugin.php?id=tsdmtitle:tsdmtitle&action=setTitle&setTitleId=0',
  );
}
