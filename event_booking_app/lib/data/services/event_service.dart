import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/event_model.dart';

class EventService {
  final Dio _dio;

  EventService(this._dio);

  Future<Map<String, dynamic>> getEvents({
    String? search,
    String? category,
    String? city,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category != 'All') queryParams['category'] = category;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;

      final response = await _dio.get(
        ApiEndpoints.events,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<EventModel> getEventById(String id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.events}/$id');
      return EventModel.fromJson(response.data['data']['event']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.events,
        data: eventData,
      );
      return EventModel.fromJson(response.data['data']['event']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<EventModel> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.events}/$id',
        data: eventData,
      );
      return EventModel.fromJson(response.data['data']['event']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.events}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
