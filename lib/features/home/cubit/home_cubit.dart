import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/routes/screen_paths.dart';

part 'home_state.dart';

/// Cubit of the home page of the app.
///
/// Not the home tab nor the homepage of website.
class HomeCubit extends Cubit<HomeState> {
  /// Constructor.
  HomeCubit() : super(const HomeState());

  /// Change the current home page state.
  void setTab(HomeTab tab) => emit(HomeState(tab: tab));
}
