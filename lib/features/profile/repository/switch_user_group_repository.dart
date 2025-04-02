import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// The repository of switching user group.
final class SwitchUserGroupRepository with LoggerMixin {
  /// Constructor.
  const SwitchUserGroupRepository();

  /// Page to fetch available user groups info.
  static const _infoPageUrl = '$baseUrl/home.php?mod=spacecp&ac=usergroup&do=expiry';

  /// Url to submit the user group switching request.
  static String _buildSubmitUrl(int gid) =>
      '$baseUrl/home.php?mod=spacecp&ac=usergroup&do=switch&groupid=$gid&inajax=1';

  /// Fetch the document page of all available user groups.
  AsyncEither<uh.Document> fetchAvailableGroupDocument() =>
      getIt.get<NetClientProvider>().get(_infoPageUrl).mapHttp((v) => parseHtmlDocument(v.data as String));

  /// Submit the switch user group request to server.
  AsyncVoidEither submitSwitchRequest(int gid, String formHash) => getIt
      .get<NetClientProvider>()
      .postForm(
        _buildSubmitUrl(gid),
        data: <String, String>{
          'referer': '$baseUrl/?mod=spacecp&ac=usergroup&do=expiry',
          'groupsubmit': 'true',
          'gid': '',
          'handlekey': 'group',
          'formhash': formHash,
        },
      )
      .mapHttp((resp) => resp.data as String)
      .flatMap((respData) {
        // If succeeded.
        if (respData.contains('succeedhandle_group')) {
          return AsyncEither.right(());
        }

        final xmlDoc = parseXmlDocument(respData);
        final htmlBodyData = xmlDoc.documentElement?.nodes.firstOrNull?.text;
        if (htmlBodyData == null) {
          return AsyncEither.left(SwitchUserGroupFailed('xml not found'));
        }
        final htmlDoc = parseHtmlDocument(htmlBodyData).body;
        // Try find the error message in `<div class="alert_error">`
        final msg = htmlDoc?.querySelector('div.alert_error')?.innerText.trim();
        if (msg == null) {
          error('failed to parse the error message, original data was: ${htmlDoc?.outerHtml}');
          return AsyncEither.left(SwitchUserGroupFailed('unknown error'));
        }
        return AsyncEither.left(SwitchUserGroupFailed(msg));
      });
}
