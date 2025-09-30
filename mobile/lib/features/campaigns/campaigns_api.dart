import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class CampaignsApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> list() => _dio.get('/campaigns');

  Future<Response> book({required String campaignId, required String userId, int count = 1, double? originLat, double? originLng, double? destLat, double? destLng}) {
    return _dio.post('/campaigns/$campaignId/book', data: {
      'userId': userId,
      if (count > 1) 'count': count,
      if (originLat != null) 'originLat': originLat,
      if (originLng != null) 'originLng': originLng,
      if (destLat != null) 'destLat': destLat,
      if (destLng != null) 'destLng': destLng,
    });
  }
}
