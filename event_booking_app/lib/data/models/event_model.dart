import 'user_model.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String venue;
  final String city;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String status;
  final UserModel? createdBy;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.venue,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
    this.createdBy,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4',
      venue: json['venue'] ?? '',
      city: json['city'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalSeats: json['totalSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      status: json['status'] ?? 'published',
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? UserModel.fromJson(json['createdBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'venue': venue,
      'city': city,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'price': price,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'status': status,
    };
  }

  bool get isSoldOut => availableSeats <= 0;
  double get occupancyRate => totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;
}
