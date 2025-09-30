import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class AdminApi {
  final Dio _dio = ApiClient.I.dio
    ..options.headers.addAll({
      'x-dev-admin': 'true', // TODO: remove in production; rely on JWT roles instead
    });

  // Approvals
  Future<Response> listApprovals({String? status}) {
    return _dio.get('/admin/approvals', queryParameters: {
      if (status != null) 'status': status,
    });
  }

  Future<Response> approve(String id, {required String adminId, String? note}) {
    return _dio.patch('/admin/approvals/$id/approve', data: {
      'adminId': adminId,
      if (note != null) 'note': note,
    });
  }

  Future<Response> reject(String id, {required String adminId, String? note}) {
    return _dio.patch('/admin/approvals/$id/reject', data: {
      'adminId': adminId,
      if (note != null) 'note': note,
    });
  }

  // Codes
  Future<Response> listCodes({String? phone}) {
    return _dio.get('/admin/codes', queryParameters: {
      if (phone != null) 'phone': phone,
    });
  }

  // Users
  Future<Response> listUsers({String? role, bool? approved, String? q}) {
    return _dio.get('/admin/users', queryParameters: {
      if (role != null) 'role': role,
      if (approved != null) 'approved': approved ? 'true' : 'false',
      if (q != null) 'q': q,
    });
  }

  // Campaigns
  Future<Response> createCampaign({
    required String title,
    required String originArea,
    required int seatsTotal,
    required int pricePerSeat,
  }) {
    return _dio.post('/admin/campaigns', data: {
      'title': title,
      'originArea': originArea,
      'seatsTotal': seatsTotal,
      'pricePerSeat': pricePerSeat,
    });
  }

  Future<Response> listCampaigns() => _dio.get('/admin/campaigns');

  Future<Response> shareCampaign(String id) => _dio.post('/admin/campaigns/$id/share');

  Future<Response> listCampaignBookings(String id) => _dio.get('/admin/campaigns/$id/bookings');

  Future<Response> bookCampaign({required String campaignId, required String userId}) {
    return _dio.post('/campaigns/$campaignId/book', data: {
      'userId': userId,
    });
  }

  // Student Lines
  Future<Response> createStudentLine({
    required String name,
    required String originArea,
    required String destinationArea,
    required double distanceKm,
    required String kind, // 'school' | 'university'
  }) {
    return _dio.post('/admin/student-lines', data: {
      'name': name,
      'originArea': originArea,
      'destinationArea': destinationArea,
      'distanceKm': distanceKm,
      'kind': kind,
    });
  }

  Future<Response> listStudentLines() => _dio.get('/admin/student-lines');

  // Student Lines - Public Requests (Admin)
  Future<Response> listStudentLinePublicRequests() => _dio.get('/admin/student-lines/public/requests');
  Future<Response> approveStudentLinePublicRequest(String id, {String? adminId}) =>
      _dio.post('/admin/student-lines/public/$id/approve', data: {
        if (adminId != null) 'adminId': adminId,
      });
  Future<Response> rejectStudentLinePublicRequest(String id, {String? adminId}) =>
      _dio.post('/admin/student-lines/public/$id/reject', data: {
        if (adminId != null) 'adminId': adminId,
      });

  // Orders (Admin)
  Future<Response> listAdminOrders({int? limit, String? category, String? status, String? dateFrom, String? dateTo}) {
    return _dio.get('/admin/orders', queryParameters: {
      if (limit != null) 'limit': limit,
      if (category != null && category.isNotEmpty) 'category': category,
      if (status != null && status.isNotEmpty) 'status': status,
      if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
    });
  }

  // Notifications (Admin)
  Future<Response> notifyBroadcast({required String title, required String message, Map<String, dynamic>? data}) {
    return _dio.post('/admin/notifications/broadcast', data: {
      'title': title,
      'message': message,
      if (data != null) 'data': data,
    });
  }

  Future<Response> notifyUsers({required List<String> userIds, required String title, required String message, Map<String, dynamic>? data}) {
    return _dio.post('/admin/notifications/users', data: {
      'userIds': userIds,
      'title': title,
      'message': message,
      if (data != null) 'data': data,
    });
  }

  Future<Response> notifyByTags({required List<Map<String, dynamic>> tags, required String title, required String message, Map<String, dynamic>? data}) {
    return _dio.post('/admin/notifications/tags', data: {
      'tags': tags,
      'title': title,
      'message': message,
      if (data != null) 'data': data,
    });
  }
}
