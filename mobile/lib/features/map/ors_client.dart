import 'package:dio/dio.dart';

class OrsClient {
  OrsClient(this.apiKey) : _dio = Dio(BaseOptions(baseUrl: 'https://api.openrouteservice.org'));
  final String apiKey;
  final Dio _dio;

  Future<Map<String, dynamic>> route(
    List<double> startLngLat,
    List<double> endLngLat, {
    String profile = 'driving-car',
  }) async {
    final res = await _dio.post(
      '/v2/directions/$profile/geojson',
      options: Options(headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      }),
      data: {
        'coordinates': [startLngLat, endLngLat],
      },
    );
    return res.data as Map<String, dynamic>;
  }
}
