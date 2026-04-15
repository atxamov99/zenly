import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../local/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;

  ApiClient(this._tokenStorage)
      : dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              await _tokenStorage.clear();
              _isRefreshing = false;
              return handler.next(error);
            }

            final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
            final response = await refreshDio.post(
              ApiConstants.refresh,
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = response.data['accessToken'] as String;
            final newRefreshToken = response.data['refreshToken'] as String;
            await _tokenStorage.updateAccessToken(newAccessToken);
            await _tokenStorage.updateRefreshToken(newRefreshToken);

            final retryRequest = error.requestOptions;
            retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(retryRequest);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          } catch (e) {
            await _tokenStorage.clear();
            _isRefreshing = false;
            return handler.next(error);
          }
        }
        handler.next(error);
      },
    ));
  }
}
