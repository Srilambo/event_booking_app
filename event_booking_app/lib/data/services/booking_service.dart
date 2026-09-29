import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio;

  BookingService(this._dio);

  Future<BookingModel> createBooking(String eventId, int quantity, {String? idempotencyKey}) async {
    try {
      final options = Options();
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
        options.headers = {'Idempotency-Key': idempotencyKey};
      }

      final response = await _dio.post(
        ApiEndpoints.bookings,
        data: {
          'eventId': eventId,
          'quantity': quantity,
        },
        options: options,
      );
      return BookingModel.fromJson(response.data['data']['booking']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<BookingModel>> getMyBookings({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.myBookings,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = (response.data['data']['bookings'] as List<dynamic>?)
              ?.map((b) => BookingModel.fromJson(b))
              .toList() ??
          [];
      return list;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch('${ApiEndpoints.bookings}/$bookingId/cancel');
      return BookingModel.fromJson(response.data['data']['booking']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
