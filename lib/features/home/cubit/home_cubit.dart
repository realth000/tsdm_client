import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'home_cubit.mapper.dart';

part 'home_state.dart';

/// Cubit of the home page of the app.
///
/// Not the home tab nor the homepage of website.
class HomeCubit extends Cubit<HomeState> {
  /// Constructor.
  HomeCubit() : super(const HomeState());

  /// Change the current home page state.
  void setTab(HomeTab tab) => emit(state.copyWith(tab: tab));

  /// Update in home flag.
  void setHomeState({required bool? inHome}) {
    emit(state.copyWith(inHome: inHome));
  }
}
