import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/image_upload/models/models.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Basic functionality definition of image upload repositories.
final class ImageUploadRepository with LoggerMixin {
  /// Constructor.
  const ImageUploadRepository(this._netClientProvider);

  final NetClientProvider _netClientProvider;

  static const _smmsEndPoint = 'https://smms.app/api/v2/upload';

  /// Parse network response info [SmmsResponse], parse result and return
  /// the image url if success.
  AsyncEither<String> _parseSmmsResponse(Response<dynamic> resp) =>
      AsyncEither<String>(() async {
        final dataMap = resp.data as Map<String, dynamic>?;
        if (dataMap == null) {
          return left(ImageUploadInvalidResponse());
        }
        info('resp of uploading image to smms: $dataMap');
        final smmsResp = SmmsResponseMapper.fromMap(dataMap);
        if (!smmsResp.success || smmsResp.data?.url == null) {
          return left(ImageUploadFailed(smmsResp.message));
        }
        return right(smmsResp.data!.url);
      });

  /// Do the upload action
  AsyncEither<String> uploadToSmms(SmmsRequest req) =>
      _netClientProvider.postMultipartForm(
        _smmsEndPoint,
        header: <String, String>{
          'Authorization': '',
        },
        data: <String, dynamic>{
          'file': MultipartFile.fromBytes(req.data),
          'format': 'json',
        },
      ).flatMap(_parseSmmsResponse);
}
