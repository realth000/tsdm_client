import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Cubit to store and control current page route.
///
/// State is a list (more exactly, stack) of screen paths that pages ever
/// enter currently.
final class RootLocationCubit extends Cubit<List<String>> with LoggerMixin {
  /// Constructor.
  RootLocationCubit() : super(const []) {
    _sub = rootLocationStream.stream.listen(
      (event) => switch (event) {
        RootLocationEventEnter(:final path) => () {
            debug('enter page $path');
            emit(state.toList()..add(path));
          }(),
        RootLocationEventLeave(:final path) => () {
            debug('leave page $path');
            if (state.lastOrNull != path) {
              error('failed to leave page non-current path $path, current '
                  'page is $state');
              return;
            }
            emit(state.toList()..removeLast());
          }(),
      },
    );
  }

  late final StreamSubscription<RootLocationEvent> _sub;

  /// Get the current path;
  String? get current => state.lastOrNull;

  /// Currently in page [path] or not.
  bool isIn(String path) => state.lastOrNull == path;

  /// Ever pushed page [path] in route stack or not.
  bool ever(String path) => state.contains(path);

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
