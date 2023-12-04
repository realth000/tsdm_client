import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/screen_state_provider.g.dart';

enum ScreenStateEvent {
  empty,
  refresh,
  goToTop,
}

/// a [ProviderContainer] to help access [screenStateProvider].
///
/// Using this separate [ProviderContainer] because this provider shall be
/// accessible just in state disposing where a regular [Ref] was disposed before.
final screenStateContainer = ProviderContainer();

/// Save screen state stream, provide methods to control the current state of
/// current screen.
@Riverpod(keepAlive: true)
class ScreenState extends _$ScreenState {
  @override
  void build() {}

  /// The other side of this stream sink should be held by current screen, so
  /// when this [_sink] add events, current page can act to it.
  StreamSink<ScreenStateEvent>? _sink;

  /// Add an event to the stream.
  void add(ScreenStateEvent event) {
    _sink?.add(event);
  }

  /// Set the [_sink] to [sink].
  /// Call this after current state changes (and it need interact with other
  /// widgets), before adding any events to [_sink].
  void sink(StreamSink<ScreenStateEvent> sink) {
    _sink = sink;
  }

  /// Set the [_sink] to null.
  /// Call this when widget is disposing.
  /// Note that when in widget state's dispose method, ref was already disposed
  /// so use [screenStateContainer] to access this provider notifier, also use
  /// it when calling other methods in this notifier.
  void clearSink() {
    _sink = null;
  }
}
