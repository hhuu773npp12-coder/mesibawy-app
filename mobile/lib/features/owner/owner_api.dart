import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class OwnerApi {
  final Dio _dio = ApiClient.I.dio;

  // Wallet
  Future<Response> getWallet() => _dio.get('/owner/wallet');

  // Topup Cards
  Future<Response> generateTopupCards({required int count}) {
    return _dio.post('/owner/topup-cards/generate', data: { 'count': count });
  }
  Future<Response> listTopupCards() => _dio.get('/owner/topup-cards');

  // Restaurant settlements
  Future<Response> listRestaurantSettlements() => _dio.get('/owner/restaurant-settlements');
  Future<Response> markSettlementPaid(String id) => _dio.post('/owner/restaurant-settlements/$id/pay');

  // Energy offers
  Future<Response> createEnergyOffer({
    required String title,
    required String brand,
    required String details,
    String? imageUrl,
    List<String>? imageUrls,
  }) {
    return _dio.post('/owner/energy/offers', data: {
      'title': title,
      'brand': brand,
      'details': details,
      if (imageUrls != null && imageUrls.isNotEmpty) 'images': imageUrls,
      // keep single field for backward compatibility (use first if multiple provided)
      if (imageUrl != null) 'imageUrl': imageUrl,
      if ((imageUrl == null || imageUrl.isEmpty) && (imageUrls != null && imageUrls.isNotEmpty)) 'imageUrl': imageUrls.first,
    });
  }
  Future<Response> listEnergyRequests() => _dio.get('/owner/energy/requests');
}
