import '../repositories/event_repository.dart';
import '../../data/models/event_model.dart';

class GetEventsUseCase {
  final EventRepository _repository;
  GetEventsUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    String? search,
    String? category,
    String? city,
    int page = 1,
    int limit = 10,
  }) =>
      _repository.getEvents(
        search: search,
        category: category,
        city: city,
        page: page,
        limit: limit,
      );
}

class GetEventByIdUseCase {
  final EventRepository _repository;
  GetEventByIdUseCase(this._repository);

  Future<EventModel> call(String id) => _repository.getEventById(id);
}

class CreateEventUseCase {
  final EventRepository _repository;
  CreateEventUseCase(this._repository);

  Future<EventModel> call(Map<String, dynamic> eventData) =>
      _repository.createEvent(eventData);
}

class UpdateEventUseCase {
  final EventRepository _repository;
  UpdateEventUseCase(this._repository);

  Future<EventModel> call(String id, Map<String, dynamic> eventData) =>
      _repository.updateEvent(id, eventData);
}

class DeleteEventUseCase {
  final EventRepository _repository;
  DeleteEventUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteEvent(id);
}
