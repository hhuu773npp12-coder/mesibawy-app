import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class RestaurantApi {
  final Dio _dio = ApiClient.I.dio;

  Future<Response> listOffers() {
    return _dio.get('/restaurant/offers');
  }

  Future<Response> createOffer({required String name, required int price, required String imageUrl}) {
    return _dio.post('/restaurant/offers', data: {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  // Orders
  Future<Response> listOrders({String? stage}) {
    return _dio.get('/restaurant/orders', queryParameters: {
      if (stage != null && stage.isNotEmpty) 'stage': stage,
    });
  }

  Future<Response> updateOrderStage({required String id, required String stage}) {
    return _dio.patch('/restaurant/orders/$id/status', data: {
      'stage': stage,
    });
  }
}
