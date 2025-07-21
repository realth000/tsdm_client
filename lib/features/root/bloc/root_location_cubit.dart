import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/features/root/models/models.dart';
import 'package:tsdm_client/features/root/stream/root_location_stream.dart';
import 'package:tsdm_client/routes/screen_paths.dart';
import 'package:tsdm_client/utils/logger.dart';

part 'root_location_cubit.mapper.dart';
part 'root_location_state.dart';

/// Cubit to store and control current page route.
///
/// State is a list (more exactly, stack) of screen paths that pages ever
/// enter currently.
///
/// Now this class handles page locations. Every page path saved in state is the page we in or nested in. The global
/// cubit listener is responsible to check pop page logic, ensuring all pop requests are satisfies user settings.
final class RootLocationCubit extends Cubit<RootLocationState> with LoggerMixin {
  /// Constructor.
  RootLocationCubit() : super(const RootLocationState()) {
    _sub = rootLocationStream.stream.listen(
      (event) => switch (event) {
        RootLocationEventEnter(:final path) => () {
          // Already enter new page.
          debug('enter page $path');
          emit(state.copyWith(locations: state.locations.toList()..add(path)));
        }(),
        RootLocationEventLeave(:final path) => () {
          // Already leave the current page.
          debug('leave page $path');
          if (currentPath != path) {
            if (path == ScreenPaths.homepage) {
              // Special case for shelled route.
              //emit(state.toList()..removeWhere((e) => e == path));
              return;
            }

            error(
              'failed to leave page non-current path $path, current '
              'page is $state',
            );
            return;
          }
          emit(state.copyWith(locations: state.locations.toList()..removeLast()));
        }(),
        RootLocationEventLeavingLast() => () {
          // Intend to leave current page.
          debug('leave last page');
          if (state.locations.isEmpty) {
            error('location state already empty');
            return;
          }
          // Till now we do not know it it's find to really leave current page.
          // Instead, update request time to notify the global listener which works on this.
          emit(state.copyWith(lastRequestLeavePageTime: DateTime.now()));
        }(),
      },
    );
  }

  late final StreamSubscription<RootLocationEvent> _sub;

  /// Get the current path;
  String? get currentPath => state.locations.lastOrNull;

  /// Currently in page [path] or not.
  bool isIn(String path) => state.locations.lastOrNull == path;

  /// Ever pushed page [path] in route stack or not.
  bool ever(String path) => state.locations.contains(path);

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
