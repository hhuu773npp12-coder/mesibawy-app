import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class CitizenCraftApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> create({
    required String role,
    required String citizenName,
    required String citizenPhone,
    required String address,
    String? detail,
    double? lat,
    double? lng,
    required int hours,
    required int pricePerHour,
  }) {
    return _dio.post('/crafts', data: {
      'role': role,
      'citizenName': citizenName,
      'citizenPhone': citizenPhone,
      'address': address,
      if (detail != null) 'detail': detail,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'hours': hours,
      'pricePerHour': pricePerHour,
    });
  }

  Future<Response> getOne(String id) => _dio.get('/crafts/$id');
  Future<Response> addHours(String id, int hours) => _dio.post('/crafts/$id/add-hours-citizen', data: {'hours': hours});
  Future<Response> cancel(String id) => _dio.post('/crafts/$id/cancel');
}
