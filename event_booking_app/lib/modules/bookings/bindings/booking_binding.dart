import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/usecases/booking_usecases.dart';
import '../../../core/network/dio_client.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = Get.find<DioClient>();
    final bookingService = BookingService(dioClient.dio);
    final bookingRepo = BookingRepositoryImpl(bookingService);

    Get.lazyPut(() => BookEventUseCase(bookingRepo));
    Get.lazyPut(() => GetMyBookingsUseCase(bookingRepo));
    Get.lazyPut(() => CancelBookingUseCase(bookingRepo));

    Get.put(BookingController(
      Get.find(),
      Get.find(),
      Get.find(),
    ));
  }
}
