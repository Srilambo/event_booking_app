import '../../domain/repositories/booking_repository.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingService _bookingService;

  BookingRepositoryImpl(this._bookingService);

  @override
  Future<BookingModel> createBooking(String eventId, int quantity, {String? idempotencyKey}) =>
      _bookingService.createBooking(eventId, quantity, idempotencyKey: idempotencyKey);

  @override
  Future<List<BookingModel>> getMyBookings({int page = 1, int limit = 20}) =>
      _bookingService.getMyBookings(page: page, limit: limit);

  @override
  Future<BookingModel> cancelBooking(String bookingId) =>
      _bookingService.cancelBooking(bookingId);
}
