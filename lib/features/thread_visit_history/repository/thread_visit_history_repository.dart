import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';

/// Repository of thread visit bloc feature.
final class ThreadVisitHistoryRepo {
  /// Constructor.
  const ThreadVisitHistoryRepo(this._storageProvider);

  final StorageProvider _storageProvider;

  /// Fetch all history from storage.
  AsyncEither<List<ThreadVisitHistoryModel>> fetchAllHistory() =>
      _storageProvider.fetchAllThreadVisitHistory().map(
            (e) => e
                .map(
                  (entity) => ThreadVisitHistoryModel(
                    uid: entity.uid,
                    threadId: entity.tid,
                    forumId: entity.fid,
                    username: entity.username,
                    threadTitle: entity.threadTitle,
                    forumName: entity.forumName,
                    visitTime: entity.visitTime,
                  ),
                )
                .toList(),
          );

  /// Save history in [model] to storage.
  AsyncVoidEither saveHistory(ThreadVisitHistoryModel model) =>
      AsyncVoidEither(() async {
        await _storageProvider.updateThreadVisitHistory(
          uid: model.uid,
          tid: model.threadId,
          fid: model.forumId,
          username: model.username,
          threadTitle: model.threadTitle,
          forumName: model.forumName,
          visitTime: model.visitTime,
        );
        return rightVoid();
      });
}
