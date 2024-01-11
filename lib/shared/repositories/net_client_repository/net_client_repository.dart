// import 'package:dio/dio.dart';
// import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
// import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
//
// class NetClientRepository {
//   NetClientRepository({String? username, bool disableCookie = false})
//       : _username = username,
//         _disableCookie = disableCookie;
//
//   /// Username fallback value used in every network request;
//   String? _username;
//
//   /// Disable cookie in network request, fallback value in every request.
//   bool _disableCookie = false;
//
//   set username(String? username) => _username = username;
//
//   set disableCookie(bool disableCookie) => _disableCookie = disableCookie;
//
//   /// Make a GET request to [path] with [queryParameters] and return the response.
//   ///
//   /// * Optional [username] to locate stored cookie.
//   /// * Optional [disableCookie] to disable cookie in this request.
//   Future<Response<dynamic>> get(
//     String path, {
//     String? username,
//     bool? disableCookie,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     final cookie = CookieProvider.build(username: username ?? _username);
//     final resp = await NetClientProvider(
//       cookie: cookie,
//       disableCookie: disableCookie ?? _disableCookie,
//     ).get(path, queryParameters: queryParameters);
//
//     return resp;
//   }
//
//   /// Make a POST request to [path] with [data] as body and [queryParameters], return the response.
//   ///
//   /// * Optional [username] to locate stored cookie.
//   /// * Optional [disableCookie] to disable cookie in this request.
//   Future<Response<dynamic>> post(
//     String path, {
//     String? username,
//     bool? disableCookie,
//     Object? data,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     final cookie = CookieProvider.build(username: username ?? _username);
//     final resp = await NetClientProvider(
//       cookie: cookie,
//       disableCookie: disableCookie ?? _disableCookie,
//     ).post(path, data: data, queryParameters: queryParameters);
//     return resp;
//   }
//
//   /// Post a form to [path] with [data] and [queryParameters], return the response.
//   ///
//   /// * Optional [username] to locate stored cookie.
//   /// * Optional [disableCookie] to disable cookie in this request.
//   Future<Response<dynamic>> postForm(
//     String path, {
//     String? username,
//     bool? disableCookie,
//     Object? data,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     final cookie = CookieProvider.build(username: username ?? _username);
//     final resp = await NetClientProvider(
//       cookie: cookie,
//       disableCookie: disableCookie ?? _disableCookie,
//     ).postForm(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//     );
//
//     return resp;
//   }
// }
