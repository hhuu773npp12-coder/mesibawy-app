import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class CraftApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> listJobs({required String role, String? status}) {
    return _dio.get('/crafts/jobs', queryParameters: {
      'role': role,
      if (status != null) 'status': status,
    });
  }

  Future<Response> accept(String id) => _dio.post('/crafts/$id/accept');
  Future<Response> reject(String id) => _dio.post('/crafts/$id/reject');
  Future<Response> start(String id) => _dio.post('/crafts/$id/start');
  Future<Response> pause(String id) => _dio.post('/crafts/$id/pause');
  Future<Response> resume(String id) => _dio.post('/crafts/$id/resume');
  Future<Response> addHours(String id, double hours) => _dio.post('/crafts/$id/add-hours', data: { 'hours': hours });
  Future<Response> complete(String id) => _dio.post('/crafts/$id/complete');
  Future<Response> notifyUser(String id, String message) => _dio.post('/crafts/$id/notify', data: { 'message': message });
}
