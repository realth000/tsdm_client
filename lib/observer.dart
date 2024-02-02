import 'package:bloc/bloc.dart';
import 'package:tsdm_client/utils/debug.dart';

/// Bloc observer for debugging.
class Observer extends BlocObserver {
  /// Constructor.
  const Observer();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debug('[debug][bloc]: ${bloc.runtimeType} $change');
  }
}
