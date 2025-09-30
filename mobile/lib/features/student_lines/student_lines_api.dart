import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class StudentLinesApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> createPublicRequest({
    required String citizenName,
    required String citizenPhone,
    required String kind, // school | university
    required int count,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required double distanceKm,
  }) {
    return _dio.post('/admin/student-lines/public/request', data: {
      'citizenName': citizenName,
      'citizenPhone': citizenPhone,
      'kind': kind,
      'count': count,
      'originLat': originLat,
      'originLng': originLng,
      'destLat': destLat,
      'destLng': destLng,
      'distanceKm': distanceKm,
    });
  }

  Future<Response> listPublicRequests() => _dio.get('/admin/student-lines/public/requests');
}
