import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_booking_app/core/theme/app_text_styles.dart';
import 'package:event_booking_app/modules/common/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState widget smoke test', (WidgetTester tester) async {
    AppTextStyles.isTestMode = true;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Events Found',
            message: 'Check back later for exciting events!',
            icon: Icons.event_busy,
          ),
        ),
      ),
    );

    expect(find.text('No Events Found'), findsOneWidget);
    expect(find.text('Check back later for exciting events!'), findsOneWidget);
    expect(find.byIcon(Icons.event_busy), findsOneWidget);
  });
}
