// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/main.dart';

void main() {
  testWidgets('Dashboard load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BudgetBuddyApp());

    // Verify that our dashboard elements are present.
    expect(find.text('Budget Buddy'), findsOneWidget);
    expect(find.text('Manage Your Money Wisely'), findsOneWidget);
    
    // Verify that navigation buttons are present.
    expect(find.text('Income Tracker'), findsOneWidget);
    expect(find.text('View Analytics & Reports'), findsOneWidget);
    expect(find.text('Community Tips Forum'), findsOneWidget);
  });
}
