import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<BookingModel> createBooking(String eventId, int quantity, {String? idempotencyKey});
  Future<List<BookingModel>> getMyBookings({int page = 1, int limit = 20});
  Future<BookingModel> cancelBooking(String bookingId);
}
