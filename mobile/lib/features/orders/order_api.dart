import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class OrderApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> estimateAndCreate({
    String? userId,
    required String category,
    required double distanceKm,
    double? durationMin,
  }) {
    return _dio.post('/orders/estimate-and-create', data: {
      if (userId != null && userId.isNotEmpty) 'userId': userId,
      'category': category,
      'distanceKm': distanceKm,
      if (durationMin != null) 'durationMin': durationMin,
    });
  }
}
