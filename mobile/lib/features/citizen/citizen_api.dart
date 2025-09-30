import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class CitizenApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> listEnergyOffers() => _dio.get('/owner/public/energy/offers');

  Future<Response> createEnergyRequest({
    required String name,
    required String phone,
    String? location,
    double? lat,
    double? lng,
    String? offerId,
  }) {
    return _dio.post('/owner/public/energy/requests', data: {
      'name': name,
      'phone': phone,
      if (location != null) 'location': location,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (offerId != null) 'offerId': offerId,
    });
  }
}
