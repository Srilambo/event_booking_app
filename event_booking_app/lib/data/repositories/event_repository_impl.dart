import '../../domain/repositories/event_repository.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventService _eventService;

  EventRepositoryImpl(this._eventService);

  @override
  Future<Map<String, dynamic>> getEvents({
    String? search,
    String? category,
    String? city,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _eventService.getEvents(
      search: search,
      category: category,
      city: city,
      page: page,
      limit: limit,
    );

    final events = (response['data']['events'] as List<dynamic>?)
            ?.map((e) => EventModel.fromJson(e))
            .toList() ??
        [];
    final meta = response['meta'] ?? {};

    return {
      'events': events,
      'meta': meta,
    };
  }

  @override
  Future<EventModel> getEventById(String id) => _eventService.getEventById(id);

  @override
  Future<EventModel> createEvent(Map<String, dynamic> eventData) =>
      _eventService.createEvent(eventData);

  @override
  Future<EventModel> updateEvent(String id, Map<String, dynamic> eventData) =>
      _eventService.updateEvent(id, eventData);

  @override
  Future<void> deleteEvent(String id) => _eventService.deleteEvent(id);
}
