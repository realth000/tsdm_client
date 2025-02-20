part of 'auto_checkin_bloc.dart';

/// Base class of all auto checkin events.
@MappableClass()
sealed class AutoCheckinEvent with AutoCheckinEventMappable {
  /// Constructor.
  const AutoCheckinEvent();
}

/// Start the progress.
@MappableClass()
final class AutoCheckinStartRequested extends AutoCheckinEvent with AutoCheckinStartRequestedMappable {
  /// Constructor.
  const AutoCheckinStartRequested();
}

/// INTERNAL event ONLY intended to be used in bloc itself.
///
/// Triggers state update with latest user checkin state.
@MappableClass()
final class AutoCheckinUserStateChanged extends AutoCheckinEvent with AutoCheckinUserStateChangedMappable {
  /// Constructor.
  const AutoCheckinUserStateChanged(this.checkinInfo);

  /// Latest checkin state.
  final AutoCheckinInfo checkinInfo;
}
