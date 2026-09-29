import 'event_model.dart';
import 'user_model.dart';

class BookingModel {
  final String id;
  final UserModel? user;
  final EventModel event;
  final int quantity;
  final double totalPrice;
  final String bookingCode;
  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    this.user,
    required this.event,
    required this.quantity,
    required this.totalPrice,
    required this.bookingCode,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      user: json['user'] is Map<String, dynamic> ? UserModel.fromJson(json['user']) : null,
      event: EventModel.fromJson(json['event'] ?? {}),
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      bookingCode: json['bookingCode'] ?? '',
      status: json['status'] ?? 'confirmed',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
}
