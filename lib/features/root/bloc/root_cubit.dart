import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'root_cubit.mapper.dart';
part 'root_state.dart';

/// Cubit of the feature.
///
/// Note that this cubit is used in top-level in app, upstream of all features.
/// when defining state, MUST make sure values in state this is as less as
/// possible.
final class RootCubit extends Cubit<RootState> {
  /// Constructor.
  RootCubit() : super(const RootState());

  /// Show the auto checkin status at the bottom of this page.
  void showBottomAutoCheckinStatus() =>
      emit(state.copyWith(showBottomAutoCheckinStatus: true));

  /// Hide the auto checkin status at the bottom of this page.
  void hideBottomAutoCheckinStatus() =>
      emit(state.copyWith(showBottomAutoCheckinStatus: false));
}
