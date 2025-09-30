import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class DriverApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> listJobs({required String role, String? status}) {
    return _dio.get('/driver-jobs/jobs', queryParameters: {
      'role': role,
      if (status != null) 'status': status,
    });
  }

  Future<Response> accept(String id) => _dio.post('/driver-jobs/$id/accept');
  Future<Response> reject(String id) => _dio.post('/driver-jobs/$id/reject');
  Future<Response> complete(String id) => _dio.post('/driver-jobs/$id/complete');
  Future<Response> notifyAdminReject(String id) => _dio.post('/driver-jobs/$id/notify-admin-reject');
  Future<Response> notifyArrived(String id) => _dio.post('/driver-jobs/$id/notify-arrived');
  // Bike-specific
  Future<Response> notifyArrivedRestaurant(String id) => _dio.post('/driver-jobs/$id/notify-arrived-restaurant');
  Future<Response> notifyPickedUp(String id, String driverName) => _dio.post('/driver-jobs/$id/notify-picked-up', data: { 'driverName': driverName });
  Future<Response> notifyArrivedCitizen(String id) => _dio.post('/driver-jobs/$id/notify-arrived-citizen');
}
