import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/packet/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// 红包
final class PacketRepository {
  static const _packetDetailUrl = '$baseUrl/plugin.php?id=tsdmbet:awardPacket&action=showaward&tid=';

  /// Receive a packet from [url].
  AsyncEither<uh.Document> receivePacket(String url) =>
      getIt.get<NetClientProvider>().get(url).mapHttp((v) => parseHtmlDocument(v.data as String));

  /// Fetch packet statistics info of a given thread [tid].
  ///
  /// # CAUTION
  ///
  /// **The caller MUST ensure the thread [tid] has a packet.**
  AsyncEither<List<PacketDetailModel>> fetchDetail(int tid) => getIt
      .get<NetClientProvider>()
      .get('$_packetDetailUrl$tid')
      .mapHttp((v) => parseHtmlDocument(v.data as String))
      .flatMap((v) => _parsePacketInfo(v, tid));

  AsyncEither<List<PacketDetailModel>> _parsePacketInfo(uh.Document document, int tid) => AsyncEither(() async {
    final infoTable = document.querySelector('table.pure-table');
    if (infoTable == null) {
      return left(PacketDetailParseFailed(tid, 'info table not found'));
    }

    final data = infoTable.querySelectorAll('tbody > tr').map(PacketDetailModel.fromTr).whereType<PacketDetailModel>();

    return right(data.toList());
  });
}
