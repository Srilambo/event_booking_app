import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_booking_app/core/theme/app_colors.dart';
import 'package:event_booking_app/core/theme/app_text_styles.dart';
import 'package:event_booking_app/core/theme/app_theme.dart';
import 'package:event_booking_app/core/utils/validators.dart';
import 'package:event_booking_app/core/utils/formatters.dart';
import 'package:event_booking_app/data/models/user_model.dart';
import 'package:event_booking_app/data/models/event_model.dart';
import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/data/models/admin_stats_model.dart';
import 'package:event_booking_app/modules/common/widgets/app_button.dart';
import 'package:event_booking_app/modules/common/widgets/category_chip.dart';
import 'package:event_booking_app/modules/common/widgets/seat_progress_bar.dart';
import 'package:event_booking_app/modules/common/widgets/stat_card.dart';
import 'package:event_booking_app/modules/common/widgets/empty_state.dart';
import 'package:event_booking_app/modules/common/widgets/error_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTextStyles.isTestMode = true;

  group('1. Core Utilities & Design System Tests', () {
    test('Validators validate email and password properly', () {
      expect(Validators.email('invalid-email'), 'Enter a valid email address');
      expect(Validators.email('test@eventbook.com'), null);

      expect(Validators.password('short'), 'Password must be at least 8 characters');
      expect(Validators.password('noNumbersHere'), 'Password must contain at least one number');
      expect(Validators.password('Password123!'), null);
    });

    test('Formatters format currency and dates accurately', () {
      expect(Formatters.currency(299), '\$299');
      final date = DateTime(2026, 10, 15);
      expect(Formatters.formatDate(date), 'Thu, Oct 15, 2026');
    });

    test('AppTheme generates valid Light and Dark themes', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.colorScheme.primary, AppColors.primary);
      expect(darkTheme.colorScheme.primary, AppColors.primaryDarkTheme);
    });
  });

  group('2. Data Models Serialization Tests', () {
    test('UserModel serializes JSON correctly and calculates role properties', () {
      final json = {
        'id': 'usr-123',
        'name': 'System Admin',
        'email': 'admin@eventbook.com',
        'role': 'admin',
        'isActive': true
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'usr-123');
      expect(user.isAdmin, true);
      expect(user.isOrganizer, true);
    });

    test('EventModel calculates seat occupancy and sold-out states', () {
      final json = {
        '_id': 'evt-101',
        'title': 'Global Tech Summit',
        'description': 'Tech summit event',
        'category': 'Tech',
        'venue': 'Convention Center',
        'city': 'New York',
        'startDate': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 6)).toIso8601String(),
        'price': 150.0,
        'totalSeats': 100,
        'availableSeats': 0,
        'status': 'published'
      };

      final event = EventModel.fromJson(json);
      expect(event.title, 'Global Tech Summit');
      expect(event.isSoldOut, true);
      expect(event.occupancyRate, 1.0);
    });

    test('BookingModel parses status and total price', () {
      final json = {
        '_id': 'bk-202',
        'event': {
          '_id': 'evt-101',
          'title': 'Tech Summit',
          'description': 'Desc',
          'category': 'Tech',
          'venue': 'Hall',
          'city': 'City',
          'startDate': DateTime.now().toIso8601String(),
          'endDate': DateTime.now().toIso8601String(),
          'price': 100.0,
          'totalSeats': 50,
          'availableSeats': 40,
          'status': 'published'
        },
        'quantity': 2,
        'totalPrice': 200.0,
        'bookingCode': 'EVT-TEST-123',
        'status': 'confirmed',
        'createdAt': DateTime.now().toIso8601String()
      };

      final booking = BookingModel.fromJson(json);
      expect(booking.isConfirmed, true);
      expect(booking.bookingCode, 'EVT-TEST-123');
    });

    test('AdminStatsModel parses aggregate stats correctly', () {
      final json = {
        'stats': {
          'totalEvents': 15,
          'totalBookings': 42,
          'totalRevenue': 5480.0,
          'totalUsers': 8,
          'monthlyRevenue': [
            {'_id': 10, 'revenue': 5480.0, 'bookings': 42}
          ]
        }
      };

      final stats = AdminStatsModel.fromJson(json);
      expect(stats.totalEvents, 15);
      expect(stats.totalRevenue, 5480.0);
      expect(stats.monthlyRevenue.length, 1);
    });
  });

  group('3. UI Component Widget Tests', () {
    testWidgets('AppButton renders text and triggers onPressed', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.text('Click Me'));
      expect(pressed, true);
    });

    testWidgets('CategoryChip renders label and handles tap', (WidgetTester tester) async {
      bool selected = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              label: 'Music',
              isSelected: false,
              onTap: () => selected = true,
            ),
          ),
        ),
      );

      expect(find.text('Music'), findsOneWidget);
      await tester.tap(find.text('Music'));
      expect(selected, true);
    });

    testWidgets('SeatProgressBar renders seat counts correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeatProgressBar(
              availableSeats: 15,
              totalSeats: 100,
            ),
          ),
        ),
      );

      expect(find.text('15 seats left'), findsOneWidget);
      expect(find.text('15/100'), findsOneWidget);
    });

    testWidgets('StatCard renders title, value and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Revenue',
              value: '\$5,480',
              icon: Icons.attach_money,
              iconColor: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('\$5,480'), findsOneWidget);
    });

    testWidgets('EmptyState renders message and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'No Data',
              message: 'Nothing to display right now',
            ),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Nothing to display right now'), findsOneWidget);
    });

    testWidgets('ErrorState renders error message and retry button', (WidgetTester tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Server connection error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Server connection error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });
  });
}
