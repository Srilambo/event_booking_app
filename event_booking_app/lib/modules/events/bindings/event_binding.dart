import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../../../data/services/event_service.dart';
import '../../../data/repositories/event_repository_impl.dart';
import '../../../domain/usecases/event_usecases.dart';
import '../../../core/network/dio_client.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = Get.find<DioClient>();
    final eventService = EventService(dioClient.dio);
    final eventRepo = EventRepositoryImpl(eventService);

    Get.lazyPut(() => GetEventsUseCase(eventRepo));
    Get.lazyPut(() => GetEventByIdUseCase(eventRepo));
    Get.lazyPut(() => CreateEventUseCase(eventRepo));
    Get.lazyPut(() => UpdateEventUseCase(eventRepo));
    Get.lazyPut(() => DeleteEventUseCase(eventRepo));

    Get.put(EventController(
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find(),
    ));
  }
}
