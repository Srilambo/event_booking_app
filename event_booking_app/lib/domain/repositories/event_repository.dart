import '../../data/models/event_model.dart';

abstract class EventRepository {
  Future<Map<String, dynamic>> getEvents({
    String? search,
    String? category,
    String? city,
    int page = 1,
    int limit = 10,
  });
  Future<EventModel> getEventById(String id);
  Future<EventModel> createEvent(Map<String, dynamic> eventData);
  Future<EventModel> updateEvent(String id, Map<String, dynamic> eventData);
  Future<void> deleteEvent(String id);
}
