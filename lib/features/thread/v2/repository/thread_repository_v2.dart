import 'dart:convert';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/thread/v2/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';

/// The repository of thread feature v2 version.
final class ThreadRepositoryV2 {
  /// Constructor.
  const ThreadRepositoryV2();

  String _buildUrl({required String tid, required int page}) =>
      '$baseUrl/forum.php?mobile=yes&tsdmapp=1&mod=viewthread&tid=$tid&page=$page';

  /// Fetch thread [tid]'s content in the given [page].
  AsyncEither<ThreadV2> fetchThreadContent({required String tid, required int page}) =>
      getIt.get<NetClientProvider>().get(_buildUrl(tid: tid, page: page)).andThenHttp((v) {
        final result = jsonDecode(v.data as String) as Map<String, dynamic>;
        final status = result['status'];
        if (status == null || status is! int || status != 0) {
          return AsyncEither.right(ThreadV2Mapper.fromJson(v.data as String));
        }
        return AsyncEither.left(ServerRespFailure(status: 1, message: null));
      });
}
