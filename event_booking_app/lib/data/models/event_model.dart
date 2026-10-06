import 'user_model.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String venueName;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final int totalSeats;
  final int availableSeats;
  final String organizerName;
  final String status;
  final bool isSample;
  final UserModel? createdBy;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.venueName,
    required this.city,
    this.address = '',
    this.latitude = 6.9271,
    this.longitude = 79.8612,
    required this.startDate,
    required this.endDate,
    required this.price,
    this.currency = 'LKR',
    required this.totalSeats,
    required this.availableSeats,
    this.organizerName = '',
    required this.status,
    this.isSample = false,
    this.createdBy,
  });

  String get venue => venueName;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    double lat = 6.9271;
    double lng = 79.8612;

    if (json['latitude'] != null) {
      lat = (json['latitude'] as num).toDouble();
    } else if (loc != null && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
      lng = (loc['coordinates'][0] as num).toDouble();
      lat = (loc['coordinates'][1] as num).toDouble();
    }

    if (json['longitude'] != null) {
      lng = (json['longitude'] as num).toDouble();
    }

    final venueStr = json['venueName'] ?? json['venue'] ?? 'Colombo Venue';

    return EventModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4',
      venueName: venueStr,
      city: json['city'] ?? 'Colombo',
      address: json['address'] ?? '',
      latitude: lat,
      longitude: lng,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'LKR',
      totalSeats: json['totalSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      organizerName: json['organizerName'] ?? (json['createdBy'] is Map ? json['createdBy']['name'] : null) ?? '',
      status: json['status'] ?? 'published',
      isSample: json['isSample'] ?? false,
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
      'venueName': venueName,
      'venue': venueName,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'price': price,
      'currency': currency,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'organizerName': organizerName,
      'status': status,
      'isSample': isSample,
    };
  }

  bool get isSoldOut => availableSeats <= 0;
  double get occupancyRate => totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;
}
