import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/update/models/latest_version_info.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/parsing.dart';

part 'update_cubit.mapper.dart';

/// Url checking for updates.
const updateInfoUrl = '$baseUrl/forum.php?mod=redirect&goto=findpost&ptid=1233425&pid=75311834';

/// The id of node holding latest version info.
const updatePostDomId = 'postmessage_75311834';

/// State of update cubit.
@MappableClass()
final class UpdateCubitState with UpdateCubitStateMappable {
  /// Constructor.
  const UpdateCubitState({this.loading = false, this.latestVersionInfo});

  /// Loading or not.
  final bool loading;

  /// Data.
  final LatestVersionInfo? latestVersionInfo;
}

/// Checking cubit.
final class UpdateCubit extends Cubit<UpdateCubitState> with LoggerMixin {
  /// Constructor.
  UpdateCubit() : super(const UpdateCubitState());

  /// Check app update.
  Future<void> checkUpdate({Duration? delay}) async {
    emit(state.copyWith(loading: true, latestVersionInfo: null));
    if (delay != null) {
      await Future<void>.delayed(delay);
    }

    await getIt
        .get<NetClientProvider>()
        .get(updateInfoUrl)
        .mapHttp((v) => parseHtmlDocument(v.data as String))
        .map((v) => v.querySelector('td#$updatePostDomId > div')?.innerText)
        .handle(
          (e) {
            error('failed to check latest version: $e');
            emit(state.copyWith(loading: false, latestVersionInfo: null));
          },
          (v) {
            if (v == null) {
              emit(state.copyWith(loading: false, latestVersionInfo: null));
              return;
            }

            try {
              final latestVersionInfo = LatestVersionInfoMapper.fromJson(v);
              emit(state.copyWith(loading: false, latestVersionInfo: latestVersionInfo));
            } on Exception catch (e) {
              error('failed to deserialize latest version info: $e');
              emit(state.copyWith(loading: false, latestVersionInfo: null));
            }
          },
        );
  }
}
