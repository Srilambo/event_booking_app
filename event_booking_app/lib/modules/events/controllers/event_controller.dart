import 'package:get/get.dart';
import '../../../domain/usecases/event_usecases.dart';
import '../../../data/models/event_model.dart';

class EventController extends GetxController {
  final GetEventsUseCase _getEventsUseCase;
  final GetEventByIdUseCase _getEventByIdUseCase;
  final CreateEventUseCase _createEventUseCase;
  final UpdateEventUseCase _updateEventUseCase;
  final DeleteEventUseCase _deleteEventUseCase;

  EventController(
    this._getEventsUseCase,
    this._getEventByIdUseCase,
    this._createEventUseCase,
    this._updateEventUseCase,
    this._deleteEventUseCase,
  );

  final RxList<EventModel> events = <EventModel>[].obs;
  final Rx<EventModel?> selectedEvent = Rx<EventModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCity = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      errorMessage.value = '';

      final result = await _getEventsUseCase(
        search: searchQuery.value,
        category: selectedCategory.value,
        city: selectedCity.value,
      );

      events.assignAll(result['events'] as List<EventModel>);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEventDetails(String id) async {
    try {
      isDetailLoading.value = true;
      errorMessage.value = '';
      final event = await _getEventByIdUseCase(id);
      selectedEvent.value = event;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isDetailLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchEvents();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    fetchEvents();
  }

  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    try {
      isSaving.value = true;
      await _createEventUseCase(eventData);
      await fetchEvents(refresh: true);
      Get.back();
      Get.snackbar('Success', 'Event created successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      await _updateEventUseCase(id, data);
      await fetchEvents(refresh: true);
      Get.back();
      Get.snackbar('Success', 'Event updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      await _deleteEventUseCase(id);
      events.removeWhere((e) => e.id == id);
      Get.snackbar('Success', 'Event deleted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
