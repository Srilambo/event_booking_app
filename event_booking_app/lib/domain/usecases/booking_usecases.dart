import '../repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';

class BookEventUseCase {
  final BookingRepository _repository;
  BookEventUseCase(this._repository);

  Future<BookingModel> call(String eventId, int quantity, {String? idempotencyKey}) =>
      _repository.createBooking(eventId, quantity, idempotencyKey: idempotencyKey);
}

class GetMyBookingsUseCase {
  final BookingRepository _repository;
  GetMyBookingsUseCase(this._repository);

  Future<List<BookingModel>> call({int page = 1, int limit = 20}) =>
      _repository.getMyBookings(page: page, limit: limit);
}

class CancelBookingUseCase {
  final BookingRepository _repository;
  CancelBookingUseCase(this._repository);

  Future<BookingModel> call(String bookingId) =>
      _repository.cancelBooking(bookingId);
}
