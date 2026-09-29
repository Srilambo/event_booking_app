import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;
import '../storage/secure_storage_service.dart';
import '../constants/api_endpoints.dart';
import '../../routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null) {
          final response = await _dio.post(
            ApiEndpoints.refresh,
            data: {'refreshToken': refreshToken},
            options: Options(headers: {'Authorization': ''}),
          );

          if (response.statusCode == 200 && response.data['success'] == true) {
            final newAccessToken = response.data['data']['tokens']['accessToken'];
            final newRefreshToken = response.data['data']['tokens']['refreshToken'];

            await _storage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final clonedResponse = await _dio.fetch(requestOptions);
            _isRefreshing = false;
            return handler.resolve(clonedResponse);
          }
        }
      } catch (refreshErr) {
        _isRefreshing = false;
        await _storage.clearAll();
        get_x.Get.offAllNamed(AppRoutes.login);
        return handler.next(err);
      }
    }
    _isRefreshing = false;
    return handler.next(err);
  }
}
