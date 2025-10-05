import 'dart:io';

import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._internal() {
    final base = _detectBaseUrl();
    _dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: { 'Content-Type': 'application/json' },
    ));

    // Retry + friendly errors interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) {
        // Ensure relative paths so baseUrl path (e.g., /api) is not dropped
        if (opts.path.startsWith('/')) {
          opts.path = opts.path.substring(1);
        }
        handler.next(opts);
      },
      onError: (e, handler) async {
        final req = e.requestOptions;
        final extra = req.extra;
        final attempt = (extra['attempt'] as int?) ?? 0;

        // Retry on transient network errors (no response or 5xx)
        final isNetwork = e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.error is SocketException;
        final status = e.response?.statusCode ?? 0;
        final isServer = status >= 500 && status < 600;

        if ((isNetwork || isServer) && attempt < 3) {
          // exponential backoff: 500ms, 1000ms, 2000ms
          final delayMs = 500 * (1 << attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
          try {
            final opts = Options(
              method: req.method,
              headers: req.headers,
              responseType: req.responseType,
              followRedirects: req.followRedirects,
              validateStatus: req.validateStatus,
              receiveDataWhenStatusError: req.receiveDataWhenStatusError,
              contentType: req.contentType,
              listFormat: req.listFormat,
            );
            final newExtra = Map<String, dynamic>.from(extra);
            newExtra['attempt'] = attempt + 1;
            final response = await _dio.request(
              req.path,
              data: req.data,
              queryParameters: req.queryParameters,
              options: opts.copyWith(extra: newExtra),
              cancelToken: req.cancelToken,
              onReceiveProgress: req.onReceiveProgress,
              onSendProgress: req.onSendProgress,
            );
            return handler.resolve(response);
          } catch (err) {
            // fall through to error formatting below
          }
        }

        // Friendly error message
        final friendly = _friendlyMessage(e);
        handler.reject(DioException(
          requestOptions: req,
          error: friendly,
          type: e.type,
          response: e.response,
        ));
      },
    ));
  }

  static final ApiClient I = ApiClient._internal();
  late final Dio _dio;

  String _detectBaseUrl() {
    // 1) Allow override from build-time define (full URL, e.g., http://192.168.1.10, https://api.example.com)
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    // 2) Fallbacks for emulator/local runs without hardcoded port
    // Android emulator forwards host at 10.0.2.2 → assumes server on default ports (80/443)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2';
    }
    // Other platforms: localhost (default ports)
    return 'http://localhost';
  }

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Dio get dio => _dio;

  String _friendlyMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الاتصال بالخادم، حاول مجدداً لاحقاً';
    }
    if (e.type == DioExceptionType.connectionError || e.error is SocketException) {
      return 'الخادم غير متاح حالياً أو لا يوجد اتصال بالإنترنت';
    }
    final code = e.response?.statusCode ?? 0;
    if (code >= 500) return 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
    if (code == 404) return 'المورد غير موجود (404)';
    if (code == 401) return 'لم يتم التفويض، يرجى تسجيل الدخول مجدداً';
    return 'تعذر تنفيذ الطلب، حاول مرة أخرى';
  }
}
