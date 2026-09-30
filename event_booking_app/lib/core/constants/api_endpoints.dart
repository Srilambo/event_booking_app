import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb ? '/api/v1' : 'http://localhost:5000/api/v1',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Events
  static const String events = '/events';

  // Bookings
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/mine';

  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
}
