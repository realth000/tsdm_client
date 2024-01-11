import 'package:bloc/bloc.dart';
import 'package:tsdm_client/utils/debug.dart';

class Observer extends BlocObserver {
  const Observer();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debug('[debug][bloc]: ${bloc.runtimeType} $change');
  }
}
