import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../domain/usecases/booking_usecases.dart';
import '../../../data/models/booking_model.dart';
import '../../../routes/app_routes.dart';

class BookingController extends GetxController {
  final BookEventUseCase _bookEventUseCase;
  final GetMyBookingsUseCase _getMyBookingsUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;

  BookingController(
    this._bookEventUseCase,
    this._getMyBookingsUseCase,
    this._cancelBookingUseCase,
  );

  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final Rx<BookingModel?> latestConfirmedBooking = Rx<BookingModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isBookingInProcess = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  Future<void> fetchMyBookings({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      errorMessage.value = '';
      final list = await _getMyBookingsUseCase();
      bookings.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bookTickets(String eventId, int quantity) async {
    try {
      isBookingInProcess.value = true;
      errorMessage.value = '';

      // Generate a unique idempotency key for this booking attempt
      final idempotencyKey = 'IDEM-${DateTime.now().millisecondsSinceEpoch}';

      final booking = await _bookEventUseCase(eventId, quantity, idempotencyKey: idempotencyKey);
      latestConfirmedBooking.value = booking;
      bookings.insert(0, booking);

      Get.offNamed(AppRoutes.bookingSuccess);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Booking Failed', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isBookingInProcess.value = false;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final updatedBooking = await _cancelBookingUseCase(bookingId);
      final index = bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        bookings[index] = updatedBooking;
      }
      Get.snackbar('Cancelled', 'Booking cancelled successfully', backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Cancellation Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
